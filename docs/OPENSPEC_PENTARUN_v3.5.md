# OPENSPEC PENTARUN — v2.0

> **Kinetic Axiom / KAFORGE**
> Version : 3.5 — CV Assist + HR Dynamique + Classements
> Précédente version : 2.2 (Compétition Connectée Complète)
> Date : 26 Mars 2026
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
- Comptage automatique des répétitions par computer vision (CV Assist)

### §1.3 — Principe directeur
> L'athlète est propriétaire de son identité. Il crée son compte avant la compétition. L'organisateur l'invite. Le juge le chronomètre. La plateforme se souvient.

---

## §2 — Architecture Technique

### §2.1 — Vue d'ensemble

```
┌──────────────────────────────────────────────────────────────────┐
│                         DISPOSITIFS                              │
│                                                                  │
│  Tablette Juge    Tablette Juge    Vue Directeur    Spectateur   │
│  (Flutter Web)    (Flutter Web)    (Flutter Web)   (navigateur)  │
│       │                │                │               │        │
└───────┼────────────────┼────────────────┼───────────────┼────────┘
        │                │                │               │
        ▼                ▼                ▼               ▼
┌──────────────────────────────────────────────────────────────────┐
│                  NETLIFY (Frontend statique)                     │
│                  app Flutter compilée                            │
│   pentarun.netlify.app  |  pentarun.netlify.app/#/live/{id}      │
└──────────────────────────────┬───────────────────────────────────┘
                               │ HTTPS / WebSocket
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                     SUPABASE (Backend)                           │
│                                                                  │
│  Auth (email/Google/SSO)                                         │
│  PostgreSQL (données persistantes)                               │
│  Realtime (synchronisation multi-juges + spectateurs)            │
│  Row Level Security (isolation par rôle + accès anon spectateur) │
│  Edge Functions (delete-account)                                 │
└──────────────────────────────────────────────────────────────────┘
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
| **2.1 → 4** | Supabase Cloud (supabase.com) | Hébergées Supabase |
| **5+** | Migration optionnelle VPS auto-hébergé | Souveraineté KAFORGE |

**Migration Phase 4 → Phase 5 :** un seul changement dans le code Flutter (URL + anon key). Export/import PostgreSQL standard (`pg_dump` / `pg_restore`).

---

## §3 — Authentification et Rôles

### §3.1 — Méthodes d'authentification

| Méthode | Support Supabase | Priorité |
|---|---|---|
| Email / Mot de passe | ✅ Natif | Phase 2.1 |
| Google OAuth (Gmail) | ✅ Natif | Phase 2.1 |
| SSO (SAML/OpenID) | ✅ Natif | Phase 5 |

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
4. Peut modifier son profil à tout moment (bouton compte — écran principal)
5. Reçoit invitation d'un organisateur pour une compétition
6. Confirmé dans la vague → profil pré-rempli chez le juge
7. Post-course : résultat enregistré automatiquement dans son historique
```

### §3.4 — Suppression de compte

La suppression de compte est irréversible et déclenche une cascade complète :

```
auth.users (supprimé via Edge Function delete-account)
      │  ON DELETE CASCADE
      ▼
profiles (supprimé automatiquement)
      │  ON DELETE CASCADE
      ▼
results (tous les résultats supprimés)
```

**Implémentation** : Edge Function Supabase (`delete-account`) appelée avec le JWT de l'utilisateur connecté. La fonction vérifie le JWT via le client anonyme, puis supprime l'utilisateur via le client `service_role`. Après suppression, la session est effacée localement (`SignOutScope.local`) sans appel réseau, l'utilisateur étant déjà invalidé côté serveur.

**Accès** : Écran "Modifier mon profil" → bouton "SUPPRIMER MON COMPTE" (avec dialog de confirmation).

---

## §4 — Modèle de Données

### §4.1 — Entités principales

```
profiles
  id, auth_id (Supabase Auth), nom, prenom
  sexe, date_naissance, poids_kg, taille_cm
  niveau_habituel, kb_habituel_kg
  features TEXT[] DEFAULT '{}'        -- feature flags (ex: 'cv_rep_counting')
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
  display_name (dénormalisé)

results
  id, wave_athlete_id
  final_time_ms, official_score, platform_score
  splits (JSON array de timestamps en ms)
  no_count_events, energy_breakdown (JSON)
  -- Phase 3 : métriques cardiaques (nullable)
  fc_moy INTEGER                       -- FC moyenne course (bpm)
  fc_max_atteinte INTEGER              -- FC maximale atteinte
  trimp NUMERIC(8,2)                   -- TRIMP Bannister 1991
  coeff_physio NUMERIC(6,4)            -- (FC_moy/FC_max_theo) × coeff_age
  platform_score_hr NUMERIC(15,3)      -- score avec coeff_physio
  hr_data JSONB                        -- buffer brut BLE (nullable)
  -- Phase 3.5 : CV Assist (nullable)
  cv_rep_count INTEGER                 -- reps détectées par CV sur la course
  sealed_at, judge_signature, athlete_signature

records  (vue PostgreSQL)
  DISTINCT ON (level, coeff_sexe, coeff_age)
  ORDER BY platform_score ASC
  → meilleur platform_score par catégorie
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
| **Record plateforme** | Meilleur score absolu par niveau/sexe/âge (vue `records`) |
| **Progression individuelle** | Évolution du scorePlateforme dans le temps (graphique CustomPaint) |

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
| Package Flutter | `flutter_blue_plus` (natif Android/iOS — stub no-op sur Web) |
| Connexion | Optionnelle, initiée par l'athlète avant le départ via SetupScreen |

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

**`RealtimeService`** (lib/services/realtime_service.dart) — API statique :
- `subscribeToWave(waveId, {onAthleteUpdated, onWaveUpdated?})` — s'abonne aux tables `wave_athletes` et `waves` filtrées par `wave_id`
- `unsubscribe(key)` / `unsubscribeAll()` — gestion cycle de vie

### §7.2 — Canaux de synchronisation

| Canal | Émetteur | Récepteurs | Événements |
|---|---|---|---|
| `wave:{id}` | Juge de la vague | Directeur, spectateurs | Validation station, finish, no-count, statut vague |

**Abonnement par vague** (non par compétition) : chaque vague a son canal `wave:{waveId}`. Le DirectorScreen et le SpectatorScreen s'abonnent à toutes les vagues d'une compétition via un `Future.wait` + boucle `subscribeToWave`.

**Écrans concernés :**

| Écran | Rôle | Accès auth | Abonnements |
|---|---|---|---|
| `RacingScreen` | Juge | Oui | Aucun (émetteur uniquement via `WaveService.pushProgress`) |
| `DirectorScreen` | Organisateur | Oui | Toutes les vagues de la compétition |
| `SpectatorScreen` | Public | **Non** | Toutes les vagues de la compétition |

**URL Spectateur** : `https://pentarun.netlify.app/#/live/{competitionId}`
- Fragment `#/live/{id}` détecté dans `main()` avant `runApp()` → bypass `_AuthGate` → `SpectatorScreen` directement
- RLS Supabase : politiques `anon SELECT` sur `competitions` / `waves` / `wave_athletes` (uniquement `statut = 'en_cours'`)
- `display_name` dénormalisé dans `wave_athletes` à l'inscription → pas de jointure `profiles` pour le spectateur

### §7.3 — Gestion déconnexion réseau (Offline Queue)

Gymnases = wifi instable. Architecture :

**Offline Queue** (lib/services/offline_queue.dart) — import conditionnel stub/web :
- Sur Flutter Web : stockage localStorage (`pentarun_offline_queue`) via `dart:html`
- Sur autres plateformes : no-op stub

**Comportement dans AppState :**
1. `validateStation()` → `WaveService.pushProgress()` :
   - **Succès** → `offlineFlush()` rejoue les entrées en attente
   - **Échec réseau** → `offlineEnqueue({waveAthleteId, stationActuelle, splitsMs, ...})`
2. À chaque push réussi, la file est vidée automatiquement (idempotent : la dernière progression écrase les précédentes en BDD)

**Règle** : Le chrono local est toujours prioritaire. `pushProgress` est **fire-and-forget** — jamais de `await` bloquant dans `validateStation`.

**Horodatage absolu** (DateTime.now()) — anti-drift §4.2 v1.x conservé.

---

## §8 — Roadmap Phasée v2.x

### Phase 2.1 — Identité & Profils ✅
- Intégration Supabase Auth (email + Google OAuth)
- Création profil athlète (nom, sexe, âge, poids, taille, niveau, KB)
- Historique personnel des performances
- Page "Mon PENTARUN"
- Migration `setup_screen` : recherche profil existant

### Phase 2.2 — Compétition Connectée ✅
- **Sprint 1** : Schéma Supabase — tables `competitions`, `waves`, `wave_athletes` + RLS + Realtime publication + migration `results.wave_id`
- **Sprint 2** : `CompetitionListScreen` + `CompetitionCreateScreen` — création compétition, gestion vagues, inscription athlètes (`_EnrollAthleteDialog`)
- **Sprint 3** : `WaveJoinScreen` — le juge rejoint une vague connectée en 3 étapes (compétition → vague → athlètes) puis démarre le chrono
- **Sprint 4** : `DirectorScreen` — tableau de bord temps réel multi-vagues, chronos live, classements provisoires, barre progression stations
- **Sprint 5** : `SpectatorScreen` (URL publique `/#/live/{id}`) + `OfflineQueue` (localStorage outbox pour pushProgress sur wifi instable)

### Phase 2.3 — Classements & Communauté ✅
- **Sprint 1** : `RankingScreen` — podium top-3 visuel 🥇🥈🥉, onglet CLASSEMENT
- **Sprint 2** : Onglet RECORDS — grille `AgeCategory × Sex`, meilleur `platform_score` par catégorie via vue PostgreSQL `records` (`DISTINCT ON` + `ORDER BY platform_score ASC`)
- **Sprint 3** : `HistoryScreen` — `_ProgressionChart` CustomPaint, axe Y inversé (score bas = haut = mieux), PB en ambre
- **Sprint 4** : Export PDF fiche résultat (`pdf ^3.12.0`, téléchargement dart:html Blob URL)

### Phase 3 — HR & Coefficients Dynamiques ✅
- **Sprint 1** : BLE infrastructure — `BleService` stub/native, `HrSessionService`, `HrSample`, `HrDevice`, `_HrPairingCard` dans SetupScreen
- **Sprint 2** : Moteur TRIMP — `HrCalculator.compute()`, formule Bannister 1991, FC max théo Tanaka 2001, migration `004_hr_data.sql`
- **Sprint 3** : `coeff_physio` dynamique, `scorePlateforme_HR`, section HR dans `AthleteResultCard`, champs HR dans `RaceResult`

### Phase 3.5 — CV Assist : Comptage Automatique des Répétitions ✅

> **Jalon stratégique — Feature Gold (compte root/premium)**

#### Objectif
Assister le juge en comptant automatiquement les répétitions KB via computer vision on-device. Le juge conserve la **décision finale** (validation / no-count). La CV est une assistance, jamais un remplacement.

#### Architecture retenue : On-Device (MediaPipe Pose Landmarker)

**Technologie :** Google MediaPipe Pose Landmarker
- Détection de 33 points de pose corporels (landmarks)
- Traitement local sur le device (CPU/GPU du téléphone/tablette)
- Framework : `google_mlkit_pose_detection` (Flutter, Android + iOS)
- Latence : < 20ms — compatible avec 30fps en temps réel

**Contrainte plateforme :**
`google_mlkit_pose_detection` fonctionne sur Android et iOS uniquement.
Flutter Web = non supporté pour le ML temps réel.
→ Implémenté via pattern stub/native (`dart.library.io`) — Web reçoit un badge informatif, natif reçoit l'implémentation complète (commentée, prête à activer).

#### Algorithme de détection de répétition (implémenté)

```
Caméra (30fps) → MediaPipe Pose → Landmarks articulaires
→ Angle épaule-coude-poignet (bras droit + gauche)
  angleDeg = acos(dot(v1, v2) / (|v1| × |v2|)) × 180/π
→ Machine à états angulaire avec debounce :
    BASSE  : angle < seuil_bas  (ex: 60°)
    HAUTE  : angle > seuil_haut (ex: 150°)
    Transition BASSE→HAUTE confirmée → HAUTE→BASSE = +1 répétition
→ Score de confiance par rep (qualité du mouvement)
→ _CvBadge : alerte ambre si |cvReps − expectedReps| > 2
```

Calibration par type de mouvement KB biathlon :
- Snatch / Jerk / Long Cycle → profils angulaires distincts via `RepCounterConfig`
- Seuils configurables par niveau (amplitude différente DÉCOUVERTE vs TITAN)

#### Feature Flag par compte

```sql
ALTER TABLE profiles ADD COLUMN features TEXT[] DEFAULT '{}';
-- Ex : features = ARRAY['cv_rep_counting', 'hr_advanced']
```

```dart
bool get hasCvFeature => features.contains('cv_rep_counting');
```

Activation par l'admin via le dashboard Supabase (`UPDATE profiles SET features = ...`).

#### Intégration dans RacingScreen

- `_CvBadge` sur `AthleteRaceCard` : compteur CV vs attendu, alerte ambre si écart > 2 reps
- `CvRepSession` singleton : accumule `stationReps` (reset au VALIDER) + `totalReps`
- `AppState.updateCvRep(athleteId)` mis à jour à chaque RepEvent depuis le stream
- `validateStation` : accumule `cvTotalReps += stationReps`, reset `cvStationReps` via `copyWith(resetCvStation: true)`

#### Ce que la CV ne fait PAS
- Ne valide pas automatiquement les stations (le juge appuie toujours sur VALIDER)
- Ne remplace pas le bouton NO COUNT (le juge juge)
- Ne transmet pas de vidéo à un serveur externe
- Ne fonctionne pas si le device n'a pas de caméra frontale/arrière accessible

### Phase 4 — Module Coaching Solaris
- VMA, Vitesse Critique (élagués v1.x, réservés ici)
- Charge hebdomadaire : TRIMP cumulé sur 7 jours (nécessite Phase 3)
- Périodisation : cycles charge / récupération basés sur le TRIMP
- Recommandations : volume, intensité, fréquence selon le niveau et l'historique
- Nécessite Phase 3 (données HR + TRIMP) ✅ livré
- Phase 5 (VPS) recommandée pour les calculs serveur, non bloquante

### Phase 5 — Infrastructure Souveraine
- Migration Supabase Cloud → VPS auto-hébergé KAFORGE
- **Stack cible** : Hetzner / Scaleway (EU, RGPD)
  - PostgreSQL self-hosted + pgBouncer (pooler connexions)
  - GoTrue self-hosted (même lib qu'Supabase Auth)
  - Supabase Realtime self-hosted (open-source)
  - MinIO (stockage compatible S3)
- Migration Flutter : un seul changement (`SupabaseConfig.supabaseUrl` + `anonKey`)
- Migration données : `pg_dump` / `pg_restore` standard — sans transformation

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
| Schéma Supabase (competitions / waves / wave_athletes) | §7.1 | ✅ Implémenté Sprint 1 |
| RLS organisateur + juge + résultats | §7.1 | ✅ Implémenté Sprint 1 |
| Création / gestion compétition | §8 Phase 2.2 | ✅ Implémenté Sprint 2 |
| Inscription athlètes à une vague | §7.1 | ✅ Implémenté Sprint 2 |
| WaveJoinScreen — juge rejoint une vague | §7.2 | ✅ Implémenté Sprint 3 |
| Synchronisation temps réel juges ↔ serveur | §7.1 §7.2 | ✅ Implémenté Sprint 3 |
| DirectorScreen — toutes vagues simultanées | §7.2 | ✅ Implémenté Sprint 4 |
| Chronos live + classements provisoires | §7.2 | ✅ Implémenté Sprint 4 |
| SpectatorScreen — résultats live sans auth | §7.2 | ✅ Implémenté Sprint 5 |
| URL publique `/#/live/{competitionId}` | §7.2 | ✅ Implémenté Sprint 5 |
| Offline Queue (localStorage outbox) | §7.3 | ✅ Implémenté Sprint 5 |
| Replay automatique au retour réseau | §7.3 | ✅ Implémenté Sprint 5 |
| RLS anon SELECT spectateurs | §7.2 §7.3 | ✅ Migration 002 |
| display_name dénormalisé wave_athletes | §7.2 | ✅ Migration 002 |

### §9.2bis — Phase 2.3

| Exigence | Référence | État |
|---|---|---|
| Podium top-3 visuel (🥇🥈🥉) — RankingScreen onglet CLASSEMENT | §5.6 | ✅ Implémenté Sprint 1 |
| Vue records PostgreSQL (`DISTINCT ON` + `ORDER BY platform_score`) | §5.6 | ✅ Migration 003 |
| Onglet RECORDS — grille AgeCategory × Sex | §5.6 | ✅ Implémenté Sprint 2 |
| Graphique progression individuelle CustomPaint (PB en ambre) | §5.6 | ✅ Implémenté Sprint 3 |
| Export PDF fiche résultat (`pdf ^3.12.0`) | §9.4 → livré | ✅ Implémenté Sprint 4 |
| Téléchargement PDF dart:html Blob URL (stub/web) | §9.4 → livré | ✅ Implémenté Sprint 4 |
| Badge HR sur carte résultat (`fcMoy`, `scoreHR`) | §6.6 | ✅ Implémenté Sprint 4 |

### §9.3 — Phase 3

| Exigence | Référence | État |
|---|---|---|
| BLE GATT 0x180D — `BleService` stub/native | §6.2 | ✅ Implémenté Sprint 1 |
| `HrSessionService` — buffer + computeMetrics() | §6.3 | ✅ Implémenté Sprint 1 |
| `_HrPairingCard` dans SetupScreen | §6.2 | ✅ Implémenté Sprint 1 |
| `HrCalculator.compute()` — TRIMP Bannister 1991 | §6.4 | ✅ Implémenté Sprint 2 |
| FC max théorique Tanaka 2001 (if/else chain) | §6.4 | ✅ Implémenté Sprint 2 |
| Migration 004 — colonnes fc_*, trimp, coeff_physio, platform_score_hr | §6.3 §6.5 | ✅ Migration 004 |
| `coeff_physio` dynamique | §6.5 | ✅ Implémenté Sprint 3 |
| `scorePlateforme_HR` | §6.6 | ✅ Implémenté Sprint 3 |
| Section HR dans `AthleteResultCard` | §6.6 | ✅ Implémenté Sprint 3 |
| Champs HR dans `RaceResult` (fromJson / toJson) | §6.3 | ✅ Implémenté Sprint 3 |
| Champ `hrMetrics` dans `Athlete` | §6.3 | ✅ Implémenté Sprint 3 |

### §9.3bis — Phase 3.5

| Exigence | Référence | État |
|---|---|---|
| `PoseLandmark`, `RepEvent`, `RepState`, `RepSide` | §8 Phase 3.5 | ✅ Implémenté Sprint 1 |
| `RepCounterConfig` — seuils par mouvement × niveau | §8 Phase 3.5 | ✅ Implémenté Sprint 1 |
| `RepCounterEngine` — machine à états angulaire + debounce | §8 Phase 3.5 | ✅ Implémenté Sprint 2 |
| Calcul angle par produit scalaire (shoulder/elbow/wrist) | §8 Phase 3.5 | ✅ Implémenté Sprint 2 |
| `CvService` stub/native (dart.library.io) | §8 Phase 3.5 | ✅ Implémenté Sprint 2 |
| `CvRepSession` singleton — stationReps + totalReps | §8 Phase 3.5 | ✅ Implémenté Sprint 2 |
| `features TEXT[]` sur profiles + `hasCvFeature` getter | §8 Phase 3.5 | ✅ Migration 005 + Sprint 3 |
| `cv_rep_count` sur results | §8 Phase 3.5 | ✅ Migration 005 |
| `_CvBadge` overlay sur AthleteRaceCard — alerte ambre écart > 2 | §8 Phase 3.5 | ✅ Implémenté Sprint 3 |
| `AppState.cvEnabled` + `toggleCv()` + `updateCvRep()` | §8 Phase 3.5 | ✅ Implémenté Sprint 3 |
| Reset `cvStationReps` au VALIDER, accumulation `cvTotalReps` | §8 Phase 3.5 | ✅ Implémenté Sprint 3 |
| `flutter_blue_plus ^1.35.0` activé pubspec + permissions Android | §6.2 Natif | ✅ Activé natif |
| `google_mlkit_pose_detection ^0.12.0` + `camera ^0.11.0` activés | §8 Phase 3.5 Natif | ✅ Activé natif |
| AndroidManifest — BLUETOOTH_SCAN/CONNECT + CAMERA | §6.2 §3.5 | ✅ Activé natif |
| APK Android release 95.9 MB | §6.2 §3.5 | ✅ Build validé |

### §9.4 — Élagage documenté

| Feature | Justification | Réservé |
|---|---|---|
| VMA / Vitesse Critique | Complexité coaching — hors scope plateforme compétition | Phase 4 |
| SSO SAML | Utile seulement pour fédérations sportives formelles | Phase 5 |
| ANT+ (capteurs Garmin pro) | Requiert hardware spécial non BLE standard | Phase 5+ |
| Calibration terrain CV (seuils par niveau) | Nécessite données gymnase réelles — phase test terrain | Phase 3.5 v2 |
| Calculs coaching serveur | Calculs périodisation lourds — recommandé sur VPS Phase 5 | Phase 4 optionnel |

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

### §11.3 — ERRATA v2.1 — Google OAuth spinner infini (window.open bloqué)

**Problème** : `supabase_flutter.signInWithOAuth()` appelle en interne `url_launcher` → `window.open(url, '_self', 'noopener,noreferrer')`. Après les `await` du flow PKCE (écriture du code verifier dans SharedPreferences), le navigateur considère que le contexte "user activation" est expiré. `window.open` est alors bloqué **silencieusement** par le popup blocker — sans exception, sans valeur de retour `false`. La `Future` ne se complète jamais, le spinner tourne indéfiniment.

**Correction** : Remplacer `signInWithOAuth()` par `getOAuthSignInUrl()` (construction locale de l'URL PKCE, pas d'appel réseau) puis naviguer via `window.location.href = url` (implémenté dans `lib/utils/web_redirect_web.dart` via import conditionnel `dart.library.html`). Cette navigation directe ne nécessite pas de user-activation et ne peut pas être bloquée par le popup blocker.

**Règle** : Sur Flutter Web, tout OAuth redirect doit utiliser `window.location.href` et non `window.open`. Ne jamais déléguer la navigation OAuth à `url_launcher` sur web.

### §11.4 — ERRATA v2.1 — Code PKCE non échangé au retour OAuth

**Problème** : Après redirection OAuth Google, l'URL contient `?code=<uuid>`. `supabase_flutter._handleInitialUri()` est censé détecter ce paramètre et appeler `exchangeCodeForSession()` automatiquement. En pratique, le mécanisme `app_links` qui capture l'URL initiale échoue silencieusement (timing d'instantiation) → la session n'est jamais établie → `_AuthGate` affiche `AuthScreen` en boucle malgré un code PKCE valide dans l'URL.

**Correction** : Échange explicite dans `main()` avant `runApp()` :
```dart
if (kIsWeb) {
  final code = Uri.base.queryParameters['code'];
  if (code != null) {
    try {
      await Supabase.instance.client.auth.exchangeCodeForSession(code);
    } catch (_) {}
  }
}
```
Ce code s'exécute avant la construction de `_AuthGate`, garantissant que la session est présente dès le premier `build()`.

**Règle** : Sur Flutter Web PKCE, toujours ajouter l'échange explicite du code dans `main()` en complément du mécanisme automatique `supabase_flutter`.

### §11.5 — ERRATA v2.1 — Spinner infini après suppression compte (signOut hang)

**Problème** : Après `DeleteAccountService.deleteAccount()`, la Edge Function supprime l'utilisateur dans `auth.users`. L'appel suivant `_client.auth.signOut()` tente de POST sur `/auth/v1/logout` avec un JWT appartenant à un utilisateur inexistant. La requête peut lever une exception ou ne jamais se résoudre → le `finally` absent dans la version initiale laissait `_loading = true` → spinner infini.

**Correction** :
1. `SignOutScope.local` : efface uniquement la session locale sans appel réseau, évitant le POST sur `/auth/v1/logout`.
2. `.timeout(const Duration(seconds: 10))` sur `functions.invoke` pour débloquer si le réseau est lent.
3. Bloc `finally` dans `_confirmDeleteAccount` pour garantir `_loading = false` dans tous les cas.

**Règle** : Après toute opération serveur qui invalide le compte utilisateur, utiliser `signOut(scope: SignOutScope.local)` et non `signOut()`.

### §11.6 — ERRATA v2.2 — uuid_generate_v4() inexistant dans le contexte migration

**Problème** : La migration SQL initiale utilisait `uuid_generate_v4()` (extension `uuid-ossp`) pour les PRIMARY KEY par défaut. Dans le contexte d'exécution des migrations Supabase (`supabase db push`), l'extension n'est pas chargée → `ERROR: function uuid_generate_v4() does not exist`.

**Correction** : Remplacer par `gen_random_uuid()`, fournie nativement par l'extension `pgcrypto` toujours disponible dans PostgreSQL ≥ 13 (dont Supabase).

**Règle** : Toutes les colonnes `UUID DEFAULT ...` doivent utiliser `gen_random_uuid()` dans les migrations PENTARUN. Ne jamais utiliser `uuid_generate_v4()`.

### §11.7 — ERRATA v2.2 — FilterType inexistant (realtime_client 2.7.1)

**Problème** : Le package `realtime_client 2.7.1` (inclus via `supabase_flutter ^2.8.4`) a renommé l'enum `FilterType` en `PostgresChangeFilterType`. L'ancien nom n'existe plus → erreur de compilation `Undefined name 'FilterType'`.

**Correction** : Utiliser `PostgresChangeFilterType.eq` dans tous les appels `PostgresChangeFilter(type: ...)`.

**Règle** : Lors de toute mise à jour de `supabase_flutter`, vérifier les renommages d'enum dans `realtime_client`. Le nom `PostgresChangeFilterType` est le nom stable depuis 2.7.x.

### §11.8 — ERRATA v3.x — withOpacity deprecated (Flutter 3.x)

**Problème** : `Color.withOpacity(double)` est marqué deprecated depuis Flutter 3.x au profit de `Color.withValues(alpha: double)` pour éviter les pertes de précision dans l'espace colorimétrique étendu.

**Correction** : Remplacer tous les appels `color.withOpacity(x)` par `color.withValues(alpha: x)`.

**Règle** : Utiliser exclusivement `withValues(alpha:)` pour les opacités dynamiques. `withOpacity` est interdit dans tout nouveau code PENTARUN.

---

*OPENSPEC PENTARUN v3.5.1 · KAFORGE · Kinetic Axiom*
*Conforme SPEC-KIT v1.0 · A2UI v1.3 — Phase 4 = Coaching Solaris · Phase 5 = Infrastructure Souveraine*
