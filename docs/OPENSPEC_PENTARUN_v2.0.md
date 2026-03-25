# OPENSPEC PENTARUN — v2.0

> **Kinetic Axiom / KAFORGE**
> Version : 2.0 — Plateforme Compétitive en Ligne
> Précédente version : 1.4 (outil local mono-dispositif)
> Date : 24 Mars 2026
> Frameworks : OPENSPEC · SPEC-KIT v1.0 · A2UI v1.3

---

## §0 — Frameworks

Ce document suit les conventions **OPENSPEC** (vérité unique, traçabilité totale) et **SPEC-KIT** (matrice de conformité, élagage documenté). Tout écart au présent document constitue soit un bug à corriger, soit un errata à documenter.

---

## §1 — Vision v2.0 : De l'Outil Local à la Plateforme

### §1.1 — État v1.x (acquis)
PENTARUN v1.4 est un **outil de chronométrage local** :
- Une tablette · un juge · une vague
- Aucun backend · aucune persistance
- Déployé sur Netlify (app Flutter statique)

### §1.2 — Ambition v2.0
PENTARUN v2.0 devient une **plateforme de compétition connectée** :
- Identité numérique persistante pour chaque athlète
- Vagues simultanées synchronisées en temps réel
- Historique individuel des performances
- Classement général segmenté par profil
- Intégration cardiofréquencemètre (BLE) pour métriques physiologiques réelles

### §1.3 — Principe directeur
> L'athlète est propriétaire de son identité. Il crée son compte avant la compétition. L'organisateur l'invite. Le juge le chronomètre. La plateforme se souvient.

---

## §2 — Architecture Technique

### §2.1 — Vue d'ensemble

```
┌─────────────────────────────────────────────────────┐
│                   DISPOSITIFS                       │
│                                                     │
│  Tablette Juge    Tablette Juge    Vue Directeur    │
│  (Flutter Web)    (Flutter Web)    (Flutter Web)    │
│       │                │                │           │
└───────┼────────────────┼────────────────┼───────────┘
        │                │                │
        ▼                ▼                ▼
┌─────────────────────────────────────────────────────┐
│              NETLIFY (Frontend statique)            │
│              app Flutter compilée                   │
└─────────────────────────────┬───────────────────────┘
                              │ HTTPS / WebSocket
                              ▼
┌─────────────────────────────────────────────────────┐
│                  SUPABASE (Backend)                 │
│                                                     │
│  Auth (email/Google/SSO)                            │
│  PostgreSQL (données persistantes)                  │
│  Realtime (synchronisation multi-juges)             │
│  Row Level Security (isolation par rôle)            │
└─────────────────────────────────────────────────────┘
        │
        │ BLE (optionnel, local)
        ▼
┌───────────────────────┐
│  Cardiofréquencemètre │
│  (Polar H10, Garmin…) │
│  GATT 0x180D          │
└───────────────────────┘
```

### §2.2 — Infrastructure par phase

| Phase | Infrastructure | Données |
|---|---|---|
| **2.1 → 2.3** | Supabase Cloud (supabase.com) | Hébergées Supabase |
| **3+** | Migration optionnelle VPS auto-hébergé | Souveraineté KAFORGE |

**Migration Phase 2 → Phase 3 :** un seul changement dans le code Flutter (URL + anon key). Export/import PostgreSQL standard (`pg_dump` / `pg_restore`).

---

## §3 — Authentification et Rôles

### §3.1 — Méthodes d'authentification

| Méthode | Support Supabase | Priorité |
|---|---|---|
| Email / Mot de passe | ✅ Natif | Phase 2.1 |
| Google OAuth (Gmail) | ✅ Natif | Phase 2.1 |
| SSO (SAML/OpenID) | ✅ Natif | Phase 3 |

### §3.2 — Rôles plateforme

| Rôle | Description | Droits |
|---|---|---|
| **Athlète** | Crée son compte, consulte son historique | Lecture propre profil + résultats |
| **Juge** | Gère une vague le jour de compétition | Écriture résultats de sa vague |
| **Organisateur** | Crée compétitions, assigne juges, gère athlètes | Écriture compétition complète |
| **Spectateur** | Suit les résultats en direct | Lecture seule, pas de compte requis |
| **Admin** | Gestion plateforme KAFORGE | Tous droits |

### §3.3 — Parcours athlète

```
1. Inscription plateforme (email ou Gmail)
2. Renseigne profil : nom, sexe, date de naissance, poids, taille
3. Choisit son niveau habituel et KB habituel
4. Reçoit invitation d'un organisateur pour une compétition
5. Confirmé dans la vague → profil pré-rempli chez le juge
6. Post-course : résultat enregistré automatiquement dans son historique
```

---

## §4 — Modèle de Données

### §4.1 — Entités principales

```
athletes
  id, auth_id (Supabase Auth), nom, prenom
  sexe, date_naissance, poids_kg, taille_cm
  niveau_habituel, kb_habituel_kg
  created_at

competitions
  id, nom, lieu, date, organisateur_id, statut
  (draft | open | live | closed)

waves
  id, competition_id, juge_id, numero_vague
  statut (pending | racing | finished)
  start_time

wave_athletes
  id, wave_id, athlete_id
  level, weight_kb_kg, coeff_kb
  categorie_age, coeff_age, coeff_sexe

results
  id, wave_athlete_id
  final_time_ms, official_score, platform_score
  splits (JSON array de timestamps)
  no_count_events, energy_breakdown (JSON)
  hr_data (JSON, nullable) — cf. §6
  sealed_at, judge_signature, athlete_signature

rankings
  Vue PostgreSQL calculée automatiquement
  depuis results + wave_athletes
```

### §4.2 — Catégories d'âge

| Catégorie | Tranche d'âge |
|---|---|
| Junior | < 18 ans |
| Espoir | 18 – 21 ans |
| Senior | 22 – 39 ans |
| Master 1 | 40 – 49 ans |
| Master 2 | 50 – 59 ans |
| Master 3 | 60 ans et + |

---

## §5 — Formule de Classement

### §5.1 — Philosophie : effort relatif intra-niveau

**Principe :** Le classement général compare uniquement des athlètes du **même niveau de difficulté**. Un CHALLENGER ne concourt pas contre un DÉCOUVERTE dans le ranking — ils n'ont pas fait la même épreuve.

Le score récompense **l'effort relatif au profil physiologique** de l'athlète.

### §5.2 — Formule score plateforme

```
scorePlateforme = finalTimeMs × coeff_KB × coeff_age × coeff_sexe
```

Plus le score est bas, meilleur est le classement.

**Athlète de référence OPENSPEC :** Senior homme · CHALLENGER · 24 kg KB
→ coeff_KB = 0.800 · coeff_age = 1.000 · coeff_sexe = 1.000

### §5.3 — coeff_KB (existant, inchangé)

Issu de `kettlebell.dart` — récompense l'utilisation de KB plus lourd.
Référence : 8 kg = 1.000

| KB (kg) | coeff_KB |
|---|---|
| 8 | 1.000 |
| 16 | 0.900 |
| 24 | 0.800 |
| 32 | 0.700 |
| 40 | 0.600 |

### §5.4 — coeff_age

**Base scientifique :** Déclin VO2max avec l'âge.
Références : Tanaka & Seals (2003), Fitzgerald et al. (1997).
Déclin moyen : ~1%/an après 25 ans, s'accélère après 50 ans.

| Catégorie | coeff_age | Justification physiologique |
|---|---|---|
| Junior (< 18) | 0.980 | Développement physique en cours, capacité aérobie non encore au pic |
| Espoir (18–21) | 0.990 | Proche du pic VO2max mais pas encore Senior |
| **Senior (22–39)** | **1.000** | **Référence — pic VO2max** |
| Master 1 (40–49) | 0.915 | ~8–10% déclin VO2max mesuré |
| Master 2 (50–59) | 0.855 | ~15–20% déclin VO2max mesuré |
| Master 3 (60+) | 0.775 | ~25–35% déclin VO2max mesuré |

### §5.5 — coeff_sexe

**Base scientifique :** Différentiel force/endurance homme/femme.
PENTARUN = événement mixte (~70% force KB + ~30% aérobie).

- Capacité aérobie : femmes ≈ 85% des hommes (VO2max normalisé au poids corporel)
- Force membre supérieur : femmes ≈ 60–65% des hommes
- Différentiel combiné KB biathlon : ≈ 87%

| Sexe | coeff_sexe |
|---|---|
| **Homme** | **1.000** |
| Femme | 0.870 |

### §5.6 — Structure des classements

| Classement | Segmentation |
|---|---|
| **Classement général** | Par niveau + catégorie âge + sexe |
| **Classement OPEN** | Par niveau + sexe (toutes tranches d'âge) |
| **Record plateforme** | Meilleur score absolu par niveau/sexe/âge |
| **Progression individuelle** | Évolution du scorePlateforme dans le temps |

---

## §6 — Intégration Cardiofréquencemètre (BLE)

### §6.1 — Principe

L'intégration HR est **optionnelle** pour l'athlète. En son absence, les coefficients statiques §5.4 et §5.5 s'appliquent. En sa présence, un coefficient physiologique dynamique enrichit le profil de l'athlète.

### §6.2 — Protocole BLE

| Paramètre | Valeur |
|---|---|
| Standard | Bluetooth Low Energy (BLE) |
| Service GATT | Heart Rate Service — UUID `0x180D` |
| Caractéristique | Heart Rate Measurement — UUID `0x2A37` |
| Compatibilité | Polar H10, Garmin HRM, ceintures BLE standard |
| Package Flutter | `flutter_blue_plus` |
| Connexion | Optionnelle, initiée par l'athlète avant le départ |

### §6.3 — Métriques capturées

| Métrique | Description | Calcul |
|---|---|---|
| `fc_moy` | Fréquence cardiaque moyenne course | Moyenne des mesures BLE |
| `fc_max_atteinte` | FC maximale atteinte | Max des mesures BLE |
| `fc_repos` | FC repos déclarée (profil athlète) | Saisie manuelle profil |
| `trimp` | Training Impulse (charge cardiaque totale) | Voir §6.4 |
| `fc_recovery_60s` | FC à 60s post-effort | Mesure optionnelle post-course |

### §6.4 — Calcul TRIMP (Bannister 1991)

```
TRIMP = durée_min × (FC_moy / FC_max_theorique) × e^(b × FC_moy/FC_max_theorique)
```

Où :
- `FC_max_theorique = 208 - (0.7 × âge)` — formule Tanaka (2001), plus précise que 220-âge
- `b = 1.92` pour les hommes
- `b = 1.67` pour les femmes (Bannister 1991)

### §6.5 — Coefficient physiologique dynamique

Quand les données HR sont disponibles, le `coeff_age` statique est remplacé par :

```
coeff_physio = (FC_moy / FC_max_theorique) × coeff_age_statique
```

Ce coefficient reflète l'intensité **réelle** de l'effort par rapport à la capacité maximale théorique de l'athlète, individualisée plutôt que basée sur une moyenne de population.

La formule devient :

```
scorePlateforme_HR = finalTimeMs × coeff_KB × coeff_physio × coeff_sexe
```

### §6.6 — Règle de cohérence

Si `hr_data` est présent dans `results` :
→ `scorePlateforme_HR` est calculé et affiché en priorité
→ `scorePlateforme` (statique) reste calculé pour comparaison historique

Si `hr_data` est absent :
→ `scorePlateforme` (statique) est utilisé

**Les deux scores coexistent** — le classement général utilise `scorePlateforme` pour garantir la comparabilité entre athlètes avec et sans capteur.

---

## §7 — Synchronisation Temps Réel Multi-Vagues

### §7.1 — Principe

Supabase Realtime (basé PostgreSQL LISTEN/NOTIFY + WebSocket) assure la synchronisation entre les dispositifs sans code serveur custom.

### §7.2 — Canaux de synchronisation

| Canal | Émetteur | Récepteurs | Événements |
|---|---|---|---|
| `competition:{id}` | Organisateur | Tous | Statut compétition, ouverture/fermeture |
| `wave:{id}` | Juge de la vague | Directeur, spectateurs | Validation station, finish, no-count |
| `results:{competition_id}` | Système | Tous | Nouveaux résultats officiels |

### §7.3 — Gestion déconnexion réseau

Gymnases = wifi instable. Règle critique :
- Le juge continue de fonctionner **offline** (état local Flutter)
- À la reconnexion : synchronisation automatique via Supabase Realtime
- Horodatage absolu (DateTime.now()) — anti-drift §4.2 v1.x conservé

---

## §8 — Roadmap Phasée v2.x

### Phase 2.1 — Identité & Profils
- Intégration Supabase Auth (email + Google OAuth)
- Création profil athlète (nom, sexe, âge, poids, taille, niveau, KB)
- Historique personnel des performances
- Page "Mon PENTARUN"
- Migration `setup_screen` : recherche profil existant

### Phase 2.2 — Compétition Connectée
- Création compétition par organisateur
- Inscription athlètes à une vague
- Synchronisation temps réel juges ↔ serveur
- Vue directeur (toutes vagues simultanées)
- Résultats live spectateurs

### Phase 2.3 — Classements & Communauté
- `scorePlateforme` calculé sur tous les résultats
- Ranking général segmenté (niveau + âge + sexe)
- Records plateforme par catégorie
- Progression individuelle dans le temps

### Phase 3 — HR & Coefficients Dynamiques
- Intégration BLE `flutter_blue_plus`
- Capture FC temps réel pendant la course
- Calcul TRIMP post-course
- `coeff_physio` dynamique
- `scorePlateforme_HR` en complément du score statique

### Phase 4 — Infrastructure Souveraine
- Migration Supabase Cloud → VPS auto-hébergé
- Infrastructure KAFORGE propriétaire

### Phase 5 — Module Coaching Solaris
- VMA, Vitesse Critique (élagués v1.x, réservés ici)
- Recommandations entraînement basées sur TRIMP + historique
- Planification périodisation

---

## §9 — SPEC-KIT v2.0 — Matrice de Conformité

### §9.1 — Phase 2.1

| Exigence | Référence | État |
|---|---|---|
| Auth email/Google | §3.1 | ✅ Implémenté |
| Profil athlète | §3.3 | ✅ Implémenté |
| Historique performances | §4.1 | ✅ Implémenté |
| Catégories d'âge | §4.2 | ✅ Implémenté |
| coeff_age + coeff_sexe | §5.4 §5.5 | ✅ Implémenté |
| scorePlateforme | §5.2 | ✅ Implémenté |
| Classement en ligne filtrable | §5.6 | ✅ Implémenté |

### §9.2 — Phase 2.2

| Exigence | Référence | État |
|---|---|---|
| Multi-vagues temps réel | §7.1 | 📋 Phase 2.2 |
| Vue directeur | §7.2 | 📋 Phase 2.2 |
| Gestion offline/reconnexion | §7.3 | 📋 Phase 2.2 |

### §9.3 — Phase 3

| Exigence | Référence | État |
|---|---|---|
| BLE GATT 0x180D | §6.2 | 📋 Phase 3 |
| Métriques HR (fc_moy, fc_max, trimp) | §6.3 §6.4 | 📋 Phase 3 |
| coeff_physio dynamique | §6.5 | 📋 Phase 3 |
| scorePlateforme_HR | §6.6 | 📋 Phase 3 |

### §9.4 — Élagage documenté

| Feature | Justification | Réservé |
|---|---|---|
| VMA / Vitesse Critique | Complexité coaching — hors scope plateforme compétition | Phase 5 |
| SSO SAML | Utile seulement pour fédérations sportives formelles | Phase 3 |
| Export PDF | Dépendance librairie PDF non testée en WASM | Phase 2.3 |
| ANT+ (capteurs Garmin pro) | Requiert hardware spécial non BLE standard | Phase 4+ |

---

## §10 — Errata v1.x conservés

Tous les errata des versions précédentes restent en vigueur :

| Errata | Version | Statut |
|---|---|---|
| η musculaire 0.20, EPOC 1.30, h_oh 1.22 | v1.4 §3.2 | ✅ Intégré |
| gris2 interdit pour texte (WCAG AA) | v1.4 §6 | ✅ Intégré |

---

## §11 — Errata v2.0

### §11.1 — ERRATA v2.0 — Thème A2UI (texte noir sur fond noir)

**Problème** : `ThemeData(textTheme: TextTheme(...))` avec seulement 3 styles explicites laissait tous les autres variants (`titleSmall`, `headlineSmall`, `displaySmall`, etc.) hériter de `Colors.black` (couleur par défaut du système). Résultat : texte invisible sur fond sombre dans le bilan métabolique et d'autres widgets sans couleur explicite.

**Correction** : `a2ui_theme.dart` utilise désormais `ThemeData.dark().textTheme.apply(bodyColor: blanc, displayColor: blanc)` comme base, garantissant que **tous** les variants de texte héritent de `A2Colors.blanc` par défaut.

**Règle** : Toute future modification du `textTheme` doit partir de `ThemeData.dark().textTheme` et ne pas remplacer le `TextTheme` entier.

### §11.2 — ERRATA v2.0 — Spinner invisible état loading

**Problème** : `ElevatedButton(onPressed: null)` (état désactivé pendant un chargement) perd sa couleur `backgroundColor` définie dans le thème et bascule sur `colorScheme.onSurface.withOpacity(0.12)` (gris très sombre). Le `CircularProgressIndicator(color: Colors.black)` à l'intérieur devenait alors invisible sur fond sombre.

**Correction** : En état loading, le bouton force explicitement `backgroundColor: A2Colors.cyanDark` et le spinner utilise `color: A2Colors.blanc`. Applicable à `auth_screen.dart` et `profile_screen.dart`.

**Règle** : Tout bouton avec spinner de chargement doit maintenir une couleur de fond explicite et utiliser `color: A2Colors.blanc` pour le `CircularProgressIndicator`.

---

*OPENSPEC PENTARUN v2.0 · KAFORGE · Kinetic Axiom*
*Conforme SPEC-KIT v1.0 · A2UI v1.3*
