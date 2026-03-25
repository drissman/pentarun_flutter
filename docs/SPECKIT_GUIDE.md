# SPEC-KIT — Guide de Conformité et Validation KAFORGE

> **Kinetic Axiom / KAFORGE** · Version : 1.0
> Dernière mise à jour : 25 Mars 2026

---

## 1. Définition

**SPEC-KIT** est le kit opérationnel qui accompagne l'OPENSPEC. Là où l'OPENSPEC définit *ce qui doit être fait*, le SPEC-KIT fournit les outils et processus pour vérifier *que c'est bien fait*.

Le SPEC-KIT se compose de :
- La **Matrice de Conformité** (§7.1 de chaque OPENSPEC)
- Le **Protocole d'Élagage** (§7.2)
- La **Roadmap Phasée** (§7.3)
- Les **règles de nommage** et **conventions de code**
- Ce guide d'utilisation

---

## 2. La Matrice de Conformité

La matrice de conformité est le cœur du SPEC-KIT. Elle cartographie chaque exigence OPENSPEC avec son état d'implémentation réel dans le code.

### Format d'une ligne

| Référence OPENSPEC | Exigence | État Code | Action |
|---|---|---|---|
| `§3.2` | `h_oh = H × 1.15` | ✅ Implémenté | — |
| `§4.2 [NEW]` | Bague Progression Circulaire | ❌ Absent | Créer `RingGaugeWidget` |

### États possibles

| Symbole | Signification |
|---|---|
| ✅ | Conforme — implémenté et vérifié |
| ⚠️ | Partiel — logique OK mais UI/UX manquante |
| ❌ | Non implémenté |
| 🔧 | En cours d'implémentation |
| 📋 | Planifié (roadmap) |

### Règle d'or
**La matrice ne ment jamais.** Si le code diverge de la spec, c'est soit un bug à corriger, soit un errata à documenter dans l'OPENSPEC.

---

## 3. Protocole d'Élagage Volontaire

Le SPEC-KIT inclut un mécanisme d'élagage explicite : toute fonctionnalité décidée comme hors-scope doit être documentée dans le §7.2 de l'OPENSPEC, avec justification.

**Règles d'élagage :**
1. Toute feature exclue doit apparaître en §7.2 (jamais silencieusement supprimée)
2. La justification doit être fonctionnelle (ex: "préserver légèreté A2UI") et non technique
3. Les features élagées sont candidates à une phase ultérieure de la Roadmap

**Exemple PENTARUN :**
> "Les calculs VMA et Vitesse Critique sont élagués du module chrono pour préserver la légèreté A2UI. Réservés au Module Coaching Solaris (Phase 4)."

---

## 4. La Roadmap Phasée

Le SPEC-KIT structure le développement en phases numérotées. Chaque phase a un périmètre fermé — on ne commence pas la Phase N+1 tant que la Phase N n'est pas en statut `✅`.

### Phase actuelle : 2.2

#### Phase 1.3 — Dashboard UX ✅

| Fonctionnalité | Référence OPENSPEC | Statut |
|---|---|---|
| Prédicteur Énergétique Visuel | §4.1 | ✅ Implémenté v1.3 |
| Bague de Progression Circulaire | §4.2 | ✅ Implémenté v1.3 |
| Splits intermédiaires live | §4.2 | ✅ Implémenté v1.3 |
| Podium Classement | §4.3 | ✅ Implémenté v1.3 |
| Graphique Splits par Station | §4.3 | ✅ Implémenté v1.3 |
| Panneau Actions Rapides | §4.3 | ✅ Implémenté v1.3 |
| Couleurs Podium (Or/Argent/Bronze) | §6 | ✅ Implémenté v1.3 |

#### Phase 1.4 — ERRATA Biomécanique & Lisibilité ✅

| Fonctionnalité | Référence OPENSPEC | Statut |
|---|---|---|
| Correction η musculaire (0.20) | §3.2 ERRATA v1.4 | ✅ Implémenté v1.4 |
| Correction facteur excentrique (×1.25) | §3.2 ERRATA v1.4 | ✅ Implémenté v1.4 |
| Correction EPOC HIIT (1.15→1.30) | §3.2 ERRATA v1.4 | ✅ Implémenté v1.4 |
| Recalibration hauteurs KB (rack/oh/dip) | §3.2 ERRATA v1.4 | ✅ Implémenté v1.4 |
| Lisibilité WCAG AA (gris2→gris1) | §6 ERRATA v1.4 | ✅ Implémenté v1.4 |
| Commentaires traçabilité SPEC-KIT | §5.2 | ✅ Implémenté v1.4 |
| Affichage EPOC ×1.30 (était ×1.15) | §3.2 ERRATA v1.4 | ✅ Corrigé v1.4 |
| Affichage h_oh=H×1.22 (était ×1.15) | §3.2 ERRATA v1.4 | ✅ Corrigé v1.4 |

#### Phase 2.1 — Identité & Profils ✅

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| Auth email / Google OAuth | §3.1 | ✅ Implémenté |
| Profil athlète persistant | §3.3 | ✅ Implémenté |
| Catégories d'âge (Junior→Master 3) | §4.2 | ✅ Implémenté |
| coeff_age + coeff_sexe | §5.4 §5.5 | ✅ Implémenté |
| scorePlateforme | §5.2 | ✅ Implémenté |
| Historique performances | §4.1 | ✅ Implémenté |
| Classement en ligne filtrable | §5.6 | ✅ Implémenté |
| Fix deadlock onAuthStateChange (Future.delayed) | §3.1 | ✅ Corrigé v2.0 |
| Fix validation + timeout 15s auth | §3.1 | ✅ Corrigé v2.0 |
| Fix sex.dbValue uppercase (constraint PostgreSQL) | §3.3 | ✅ Corrigé v2.0 |
| Fix TRIMP formula exp(b×ratio) | §6.4 | ✅ Corrigé v2.0 |
| Fix getRanking() join profiles sans age_category | §5.6 | ✅ Corrigé v2.0 |
| Fix thème texte noir sur fond noir (§11.1 ERRATA) | §6 A2UI | ✅ Corrigé v2.0 |
| Fix spinner visible état loading (§11.2 ERRATA) | §3.1 §3.3 | ✅ Corrigé v2.0 |
| Fix Google OAuth spinner infini (§11.3 ERRATA) | §3.1 | ✅ Corrigé v2.1 |
| Fix PKCE code non échangé retour OAuth (§11.4 ERRATA) | §3.1 | ✅ Corrigé v2.1 |
| Modification profil depuis l'app (icône compte SetupScreen) | §3.3 | ✅ Implémenté v2.1 |
| Suppression compte + cascade profiles/results (§3.4) | §3.4 | ✅ Implémenté v2.1 |
| Fix spinner infini suppression compte (§11.5 ERRATA) | §3.4 | ✅ Corrigé v2.1 |

#### Phase 2.2 — Compétition Connectée ✅

**Sprint 1 — Schéma Supabase**

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| Table `competitions` + RLS organisateur | §7.1 | ✅ Implémenté v2.2 |
| Table `waves` + RLS | §7.1 | ✅ Implémenté v2.2 |
| Table `wave_athletes` + RLS + Realtime | §7.1 | ✅ Implémenté v2.2 |
| Colonne nullable `results.wave_id` | §7.1 | ✅ Implémenté v2.2 |
| Migration 001 (`gen_random_uuid()` — §11.6) | §11.6 ERRATA | ✅ Corrigé v2.2 |
| Fix `PostgresChangeFilterType` (§11.7) | §11.7 ERRATA | ✅ Corrigé v2.2 |

**Sprint 2 — Gestion compétitions (organisateur)**

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| `CompetitionCreateScreen` | §8 Phase 2.2 | ✅ Implémenté v2.2 |
| `CompetitionListScreen` (mes compétitions) | §8 Phase 2.2 | ✅ Implémenté v2.2 |
| `_CompetitionDetailScreen` + statuts LANCER/CLÔTURER | §8 Phase 2.2 | ✅ Implémenté v2.2 |
| `_AddWaveDialog` (numéro + niveau) | §7.1 | ✅ Implémenté v2.2 |
| `_EnrollAthleteDialog` (recherche profil + KB) | §7.1 | ✅ Implémenté v2.2 |
| `CompetitionService` + `WaveService` | §7.1 | ✅ Implémenté v2.2 |

**Sprint 3 — Juge rejoint une vague**

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| `WaveJoinScreen` (3 étapes : comp → vague → athlètes) | §7.2 | ✅ Implémenté v2.2 |
| `AppState.setCompetitionContext()` + `addAthleteFromWave()` | §7.2 | ✅ Implémenté v2.2 |
| Push progression Realtime dans `validateStation()` | §7.1 §7.2 | ✅ Implémenté v2.2 |
| Push scellement dans `sealAthlete()` | §7.1 | ✅ Implémenté v2.2 |
| Bouton "REJOINDRE UNE VAGUE CONNECTÉE" SetupScreen | §7.2 | ✅ Implémenté v2.2 |
| Profil complet joint (poids/taille/sexe/âge → coeff) | §5.4 §5.5 | ✅ Implémenté v2.2 |

**Sprint 4 — Vue Directeur temps réel**

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| `DirectorScreen` — toutes vagues en temps réel | §7.2 | ✅ Implémenté v2.2 |
| Chargement parallèle vagues + athlètes (`Future.wait`) | §7.2 | ✅ Implémenté v2.2 |
| Abonnement Realtime par vague (`subscribeToWave`) | §7.1 | ✅ Implémenté v2.2 |
| Chrono live par vague (Ticker flutter/scheduler) | §7.2 | ✅ Implémenté v2.2 |
| `_WavePanel` — header statut + chrono + liste athlètes | §7.2 | ✅ Implémenté v2.2 |
| `_AthleteRow` — barre stations + podium + temps final | §7.2 | ✅ Implémenté v2.2 |
| Layout responsive (1/2/3 colonnes) | §7.2 | ✅ Implémenté v2.2 |
| `_PulseDot` LIVE animé | §7.2 | ✅ Implémenté v2.2 |
| Icône moniteur CompetitionDetailScreen (si actif) | §7.2 | ✅ Implémenté v2.2 |

**Sprint 5 — Spectateurs live + offline queue**

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| `SpectatorScreen` — vue publique sans authentification | §7.2 | ✅ Implémenté v2.2 |
| URL publique `/#/live/{competitionId}` (fragment hash) | §7.2 | ✅ Implémenté v2.2 |
| Bypass `_AuthGate` — détection fragment dans `main()` | §7.2 | ✅ Implémenté v2.2 |
| RLS anon SELECT (migrations 002) | §7.2 §7.3 | ✅ Implémenté v2.2 |
| `display_name` dénormalisé (pas de jointure profiles anon) | §7.2 | ✅ Implémenté v2.2 |
| Offline Queue (localStorage outbox) | §7.3 | ✅ Implémenté v2.2 |
| Replay automatique (`offlineFlush`) au prochain push réussi | §7.3 | ✅ Implémenté v2.2 |
| Bouton copier lien spectateurs (icône link CompetitionDetailScreen) | §7.2 | ✅ Implémenté v2.2 |

#### Phase 2.3 — Classements & Communauté 📋

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| Ranking général segmenté | §5.6 | 📋 Phase 2.3 |
| Records plateforme par catégorie | §5.6 | 📋 Phase 2.3 |
| Progression individuelle | §5.6 | 📋 Phase 2.3 |
| Export PDF fiche résultat | §9.4 Élagage | 📋 Phase 2.3 |

#### Phase 3.5 — CV Assist : Comptage Automatique des Répétitions 📋

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| Intégration google_mlkit_pose_detection | §3.5 | 📋 Phase 3.5 |
| Accès caméra Flutter (camera package) | §3.5 | 📋 Phase 3.5 |
| Extraction landmarks + angles articulaires | §3.5.2 | 📋 Phase 3.5 |
| Machine à états angulaire (snatch/jerk/long cycle) | §3.5.3 | 📋 Phase 3.5 |
| Overlay UI RacingScreen + compteur CV | §3.5.4 | 📋 Phase 3.5 |
| Feature flag cv_rep_counting (profiles.features[]) | §3.5.5 | 📋 Phase 3.5 |
| Calibration terrain (seuils par niveau) | §3.5.6 | 📋 Phase 3.5 |

#### Phase 3 — HR & Coefficients Dynamiques 📋

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| Intégration BLE GATT 0x180D | §6.2 | 📋 Phase 3 |
| Capture FC temps réel | §6.3 | 📋 Phase 3 |
| Calcul TRIMP (Bannister 1991) | §6.4 | 📋 Phase 3 |
| coeff_physio dynamique | §6.5 | 📋 Phase 3 |
| scorePlateforme_HR | §6.6 | 📋 Phase 3 |

#### Phase 4+ — Infrastructure & Coaching 📋

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| Migration VPS auto-hébergé | §2.2 | 📋 Phase 4 |
| Module Coaching Solaris (VMA, VO2) | §9.4 Élagage | 📋 Phase 5 |

---

## 5. Conventions de Code SPEC-KIT

### 5.1 Nommage des fichiers
```
screens/     → [phase]_screen.dart  (setup, racing, summary)
widgets/     → [entity]_[type].dart  (athlete_race_card, station_progress_bar)
engine/      → [function]_[type].dart (energy_calculator)
theme/       → a2ui_[category].dart
```

### 5.2 Commentaires de référence obligatoires
Toute implémentation d'une règle OPENSPEC doit porter son référence :

```dart
// SPEC-KIT §4.2 — Moteur Anti-Drift : timestamp absolu
_startTime = DateTime.now();

// SPEC-KIT §3.2 ERRATA v1.2 — h_oh corrigé de 1.25 → 1.15
final double hOh = h * 1.15;

// SPEC-KIT §6 — Fat Finger : ≥ 9rem (144px)
height: 144,
```

### 5.3 Couleurs — jamais de valeur hex en dur
Toutes les couleurs passent par `A2Colors` (tokens SPEC-KIT) :
```dart
// CORRECT
color: A2Colors.cyan

// INTERDIT
color: const Color(0xFF06B6D4) // hors fichier a2ui_colors.dart
```

### 5.4 Gestion des phases
La machine à états `AppPhase` est le reflet direct du §4 OPENSPEC :
```dart
enum AppPhase { setup, racing, summary }
// §4.1 → setup | §4.2 → racing | §4.3 → summary
```

---

## 6. Checklist de Release

Avant tout merge / release, valider :

- [ ] Matrice de conformité §7.1 mise à jour
- [ ] Aucun `❌` non justifié dans la matrice
- [ ] Errata documenté si formule ou comportement modifié
- [ ] Commentaires `// OPENSPEC §X.Y` présents sur toutes les règles métier
- [ ] Couleurs via `A2Colors` uniquement
- [ ] Pas de `print()` ou code de debug en production
- [ ] Version `pubspec.yaml` synchronisée avec la version OPENSPEC

---

## 7. Anti-Patterns SPEC-KIT

| Pattern interdit | Raison |
|---|---|
| Modifier une formule sans errata | Perd la traçabilité biomécanique |
| Hard-coder une couleur hex | Contourne le design system A2UI |
| Utiliser `gris2` comme couleur de texte | Ratio 3.2:1 — fail WCAG AA sur fond dark |
| Ajouter une feature non spécifiée | Hors-scope = dette technique non contrôlée |
| Supprimer silencieusement une feature | Doit figurer en §7.2 Élagage |
| Commit sans référence OPENSPEC sur règle métier | Perd la traçabilité code ↔ spec |
| `ThemeData(textTheme: TextTheme(...))` partiel | Variants non couverts héritent de Colors.black → §11.1 ERRATA |
| `CircularProgressIndicator(color: Colors.black)` dans bouton | Invisible sur fond sombre en état désactivé → §11.2 ERRATA |
| Appel DB Supabase synchrone dans `onAuthStateChange` | Deadlock client interne supabase_flutter → utiliser Future.delayed(Duration.zero) |
| `url_launcher` pour OAuth redirect sur Flutter Web | window.open bloqué silencieusement après await PKCE → utiliser window.location.href → §11.3 ERRATA |
| Compter sur `supabase_flutter._handleInitialUri()` seul pour PKCE | app_links échoue silencieusement → échange explicite dans main() obligatoire → §11.4 ERRATA |
| `signOut()` après suppression serveur du compte | POST /auth/v1/logout avec JWT invalide → hang → utiliser SignOutScope.local → §11.5 ERRATA |
| `uuid_generate_v4()` dans migration SQL | Extension uuid-ossp non chargée dans supabase db push → utiliser gen_random_uuid() → §11.6 ERRATA |
| `FilterType.eq` dans PostgresChangeFilter | Renommé PostgresChangeFilterType.eq depuis realtime_client 2.7.1 → §11.7 ERRATA |
| `await WaveService.pushProgress()` dans validateStation | Bloque le chrono si réseau lent → toujours fire-and-forget + catchError → §7.3 |
| Jointure `profiles!inner(...)` pour accès spectateur | Nécessite auth → utiliser display_name dénormalisé + anon SELECT → §7.2 |
| Politiques RLS manquantes pour `anon` | Spectateur voit "permission denied" → ajouter policies TO anon sur competitions/waves/wave_athletes → §7.2 |

---

*SPEC-KIT v1.0 · KAFORGE · Kinetic Axiom — Phase 2.2 complète*
