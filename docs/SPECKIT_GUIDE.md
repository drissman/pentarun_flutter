# SPEC-KIT — Guide de Conformité et Validation KAFORGE

> **Kinetic Axiom / KAFORGE** · Version : 1.0
> Dernière mise à jour : 26 Mars 2026
> **Phase actuelle : 3.5 livrée — Phase 4 planifiée**

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
> "Les calculs VMA et Vitesse Critique sont élagués du module chrono pour préserver la légèreté A2UI. Réservés au Module Coaching Solaris (Phase 5)."

---

## 4. La Roadmap Phasée

Le SPEC-KIT structure le développement en phases numérotées. Chaque phase a un périmètre fermé — on ne commence pas la Phase N+1 tant que la Phase N n'est pas en statut `✅`.

---

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

#### Phase 2.3 — Classements & Communauté ✅

**Sprint 1 — Podium**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| `RankingScreen` — onglet CLASSEMENT + podium 🥇🥈🥉 | §5.6 | ✅ Implémenté v2.3 |
| `_PodiumWidget` / `_PodiumCard` — ordre visuel 2-1-3 | §5.6 | ✅ Implémenté v2.3 |
| Filtre par niveau (TabController) | §5.6 | ✅ Implémenté v2.3 |

**Sprint 2 — Records**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| Vue PostgreSQL `records` (`DISTINCT ON` + `ORDER BY platform_score`) | §5.6 | ✅ Migration 003 |
| Onglet RECORDS — grille `AgeCategory × Sex` | §5.6 | ✅ Implémenté v2.3 |
| `_RecordCell` — meilleur score + nom + date | §5.6 | ✅ Implémenté v2.3 |
| `ResultsService.getRecords({level})` | §5.6 | ✅ Implémenté v2.3 |

**Sprint 3 — Progression individuelle**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| `_ProgressionChart` CustomPaint dans `HistoryScreen` | §5.6 | ✅ Implémenté v2.3 |
| Axe Y inversé (score bas = position haute = meilleur) | §5.6 | ✅ Implémenté v2.3 |
| Point PB en ambre avec label "PB" | §5.6 | ✅ Implémenté v2.3 |

**Sprint 4 — Export PDF**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| `PdfExportService.exportResult(RaceResult)` (`pdf ^3.12.0`) | §9.4 → livré | ✅ Implémenté v2.3 |
| `pdf_download_web.dart` — dart:html Blob URL download | §9.4 → livré | ✅ Implémenté v2.3 |
| Bouton PDF sur chaque fiche dans `HistoryScreen` | §9.4 → livré | ✅ Implémenté v2.3 |
| Badge HR dans `HistoryScreen` (`fcMoy`, `scoreHR`) | §6.6 | ✅ Implémenté v2.3 |

#### Phase 3 — HR & Coefficients Dynamiques ✅

**Sprint 1 — BLE Infrastructure**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| `HrSample`, `HrDevice` — modèles BLE | §6.2 §6.3 | ✅ Implémenté v3.0 |
| `BleService` stub/native (`dart.library.io`) | §6.2 | ✅ Implémenté v3.0 |
| `HrSessionService` singleton — buffer + computeMetrics() | §6.3 | ✅ Implémenté v3.0 |
| `_HrPairingCard` dans SetupScreen (scan, connect, disconnect) | §6.2 | ✅ Implémenté v3.0 |
| Badge "WEB — NON DISPO" sur Flutter Web | §6.2 | ✅ Implémenté v3.0 |

**Sprint 2 — Moteur TRIMP**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| `HrCalculator.compute()` — TRIMP Bannister 1991 | §6.4 | ✅ Implémenté v3.0 |
| `HrCalculator.fcMaxTheorique()` — Tanaka 2001 (if/else chain) | §6.4 | ✅ Implémenté v3.0 |
| `HrCalculator.platformScoreHr()` | §6.5 §6.6 | ✅ Implémenté v3.0 |
| Migration 004 — colonnes HR sur `results` + index | §6.3 | ✅ Migration 004 |

**Sprint 3 — coeff_physio + Data model + UI**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| `HrMetrics` — modèle post-course complet | §6.3 | ✅ Implémenté v3.0 |
| `Athlete.hrMetrics` nullable | §6.3 | ✅ Implémenté v3.0 |
| `RaceResult` — 5 champs HR nullable (fromJson/toJson) | §6.3 §6.5 §6.6 | ✅ Implémenté v3.0 |
| `sealAthlete` enrichit `RaceResult` avec HR via `HrSessionService` | §6.6 | ✅ Implémenté v3.0 |
| Section HR dans `AthleteResultCard` (`_hrSection`) | §6.6 | ✅ Implémenté v3.0 |

#### Phase 3.5 — CV Assist : Comptage Automatique des Répétitions ✅

**Sprint 1 — Modèles & Config**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| `PoseLandmark`, `RepEvent`, `RepState`, `RepSide` | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| Indices landmarks statiques (shoulder/elbow/wrist L+R) | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| `KbMovement` enum (snatch, jerk, longCycle) | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| `RepCounterConfig.forMovement(movement, level)` | §8 Phase 3.5 | ✅ Implémenté v3.5 |

**Sprint 2 — Engine + Services**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| `RepCounterEngine.angleDegrees(a, b, c)` — produit scalaire | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| `RepCounterEngine.processFrame({landmarks, side})` — machine à états | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| `RepCounterEngine.processFrameBothSides(landmarks)` | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| `CvService` stub/native (`dart.library.io`) | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| `CvRepSession` singleton — stationReps + totalReps + repStream | §8 Phase 3.5 | ✅ Implémenté v3.5 |

**Sprint 3 — Feature Flag + Overlay UI**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| Migration 005 — `features TEXT[]` sur profiles + `cv_rep_count` sur results | §8 Phase 3.5 | ✅ Migration 005 |
| `AthleteProfile.features` + `hasCvFeature` getter | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| `Athlete.cvStationReps`, `cvTotalReps` nullable | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| `RaceResult.cvRepCount` nullable | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| `AppState.cvEnabled` + `toggleCv()` + `setCvStationReps(id, reps)` | §8 Phase 3.5 | ✅ v3.5 / corrigé §11.9 |
| `validateStation` — reset cvStationReps + accumulation cvTotalReps | §8 Phase 3.5 | ✅ Implémenté v3.5 |
| `_CvCounter` grand format (56px, barre progression, cyan/vert/ambre) | §8 Phase 3.5 | ✅ v3.5 / corrigé §11.9 |
| Couleur `withValues(alpha:)` — fix deprecation Flutter 3.x (§11.8) | §11.8 ERRATA | ✅ Corrigé v3.5 |
| `flutter_blue_plus ^1.35.0` activé pubspec + permissions Android | §6.2 Natif | ✅ Activé natif |
| `google_mlkit_pose_detection ^0.12.0` + `camera ^0.11.0` activés | §8 Phase 3.5 Natif | ✅ Activé natif |
| AndroidManifest BLE (BLUETOOTH_SCAN/CONNECT) + CAMERA | §6.2 §3.5 | ✅ Activé natif |
| APK Android release 95.9 MB | §6.2 §3.5 | ✅ Build validé |

**Sprint 4 — Ergonomie Racing + Auto-Reconnect BLE (ERRATA §11.9)**

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| BLE auto-reconnect — 5 tentatives, délai croissant 2–10s | §6.2 §11.9 ERRATA | ✅ Corrigé v3.5.1 |
| MTU timeout Samsung/Huawei — try-catch non bloquant | §6.2 §11.9 ERRATA | ✅ Corrigé v3.5.1 |
| Scan BLE réduit à 5s (was 10s) | §6.2 §11.9 ERRATA | ✅ Corrigé v3.5.1 |
| `CvServiceImpl.buildPreview()` — stub (SizedBox) + native (FittedBox cover) | §8 Phase 3.5 §11.9 | ✅ Corrigé v3.5.1 |
| `toggleCv()` → démarre uniquement l'aperçu caméra (pas le comptage) | §8 Phase 3.5 §11.9 | ✅ Corrigé v3.5.1 |
| `_startCvCounting()` appelé par `startRacing()` (comptage auto au départ) | §8 Phase 3.5 §11.9 | ✅ Corrigé v3.5.1 |
| `_CvSetupCard` dans SetupScreen — toggle CV avant la course | §8 Phase 3.5 §11.9 | ✅ Corrigé v3.5.1 |
| Caméra plein écran translucide (Stack Positioned.fill, 0.58 alpha) | §4.2 §8 §11.9 | ✅ Corrigé v3.5.1 |
| 1 athlète max si CV actif — `addAthlete()` bloque avec toast | §8 Phase 3.5 §11.9 | ✅ Corrigé v3.5.1 |
| Layout responsive toutes tailles écran (phone/phablet/tablet) | §4.1 §4.2 §11.9 | ✅ Corrigé v3.5.1 |
| `_buildHeader()` extrait — LIVE dot + BPM StreamBuilder + chrono FittedBox | §4.2 §11.9 | ✅ Corrigé v3.5.1 |

#### Phase 4 — Module Coaching Solaris 📋

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| Charge hebdomadaire TRIMP cumulé 7 jours | §8 Phase 4 | 📋 Phase 4 |
| Périodisation cycles charge / récupération TRIMP | §8 Phase 4 | 📋 Phase 4 |
| Recommandations volume / intensité / fréquence | §8 Phase 4 | 📋 Phase 4 |
| VMA / Vitesse Critique (réintégrés depuis §9.4 Élagage) | §9.4 Élagage | 📋 Phase 4 |

#### Phase 5 — Infrastructure Souveraine 📋

| Fonctionnalité | Référence OPENSPEC v3.5 | Statut |
|---|---|---|
| Migration VPS auto-hébergé (Hetzner / Scaleway EU, RGPD) | §2.2 | 📋 Phase 5 |
| PostgreSQL + pgBouncer + GoTrue + Realtime self-hosted | §2.2 | 📋 Phase 5 |
| MinIO stockage compatible S3 | §2.2 | 📋 Phase 5 |
| Migration données pg_dump / pg_restore | §2.2 | 📋 Phase 5 |

---

## 5. Conventions de Code SPEC-KIT

### 5.1 Nommage des fichiers
```
screens/     → [phase]_screen.dart  (setup, racing, summary)
widgets/     → [entity]_[type].dart  (athlete_race_card, station_progress_bar)
engine/      → [function]_[type].dart (energy_calculator, rep_counter_engine)
services/    → [feature]_service[_stub|_native].dart  (ble_service_stub, cv_service_native)
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

// SPEC-KIT §3.5.4 — Phase 3.5 : badge CV Assist si feature activée
if (state.cvEnabled && athlete.cvStationReps != null) ...
```

### 5.3 Couleurs — jamais de valeur hex en dur
Toutes les couleurs passent par `A2Colors` (tokens SPEC-KIT) :
```dart
// CORRECT
color: A2Colors.cyan
color: A2Colors.ambre.withValues(alpha: 0.4)

// INTERDIT
color: const Color(0xFF06B6D4) // hors fichier a2ui_colors.dart
color: A2Colors.vert.withOpacity(0.5) // deprecated Flutter 3.x → §11.8
```

### 5.4 Gestion des phases
La machine à états `AppPhase` est le reflet direct du §4 OPENSPEC :
```dart
enum AppPhase { setup, racing, summary }
// §4.1 → setup | §4.2 → racing | §4.3 → summary
```

### 5.5 Pattern stub/native (BLE + CV)
Toute feature native-only doit utiliser le pattern d'import conditionnel :
```dart
// [feature].dart — sélecteur
export '[feature]_stub.dart'
    if (dart.library.io) '[feature]_native.dart';

// [feature]_stub.dart — no-op Flutter Web
class FeatureImpl { bool get isSupported => false; ... }

// [feature]_native.dart — implémentation commentée, prête à activer
// TODO: décommenter + ajouter package au pubspec
class FeatureImpl { ... }
```

---

## 6. Checklist de Release

Avant tout merge / release, valider :

- [ ] Matrice de conformité §7.1 mise à jour
- [ ] Aucun `❌` non justifié dans la matrice
- [ ] Errata documenté si formule ou comportement modifié
- [ ] Commentaires `// OPENSPEC §X.Y` présents sur toutes les règles métier
- [ ] Couleurs via `A2Colors` uniquement — `withValues(alpha:)` et non `withOpacity`
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
| `color.withOpacity(x)` dans tout nouveau code | Deprecated Flutter 3.x — pertes de précision colorimétrique → utiliser `color.withValues(alpha: x)` → §11.8 ERRATA |
| Toggle CV dans RacingScreen | UX incorrecte — la caméra doit être activée AVANT le départ (Setup), pas pendant la course → §11.9 ERRATA |
| `updateCvRep(athleteId)` sans paramètre reps | API incomplète — remplacé par `setCvStationReps(athleteId, reps)` → §11.9 ERRATA |
| `_CvBadge` (alerte ambre) sans compteur visible | Juge ne peut pas suivre le décompte en temps réel → remplacé par `_CvCounter` 56px → §11.9 ERRATA |
| `buildPreview()` absent du service CV | Le widget Racing ne peut pas afficher la caméra sans cette méthode sur stub ET native → §11.9 ERRATA |
| Camera full-screen absente pendant la course | L'athlète ne peut pas cadrer face caméra et les boutons sont trop petits → Stack Positioned.fill obligatoire → §11.9 ERRATA |
| `device.connect()` sans try-catch | Samsung Galaxy A54 / Huawei : requestMtu lance une exception non bloquante → wrapper en try-catch → §11.9 ERRATA |
| BLE sans auto-reconnect | Reconnexion perdue = session HR perdue en pleine course → `_scheduleReconnect()` obligatoire → §11.9 ERRATA |
| Feature native-only sans pattern stub/native | BLE et CV ne compilent pas sur Flutter Web → toujours stub + conditional export dart.library.io |
| Web Bluetooth sans HTTPS | getUserMedia() et Web Bluetooth bloqués sur HTTP → Phase 3.6/3.7 nécessitent HTTPS (Netlify OK) → §6.7 §6.8 |
| requestDevice() hors gesture utilisateur | Web Bluetooth exige un gesture (clic) pour ouvrir le popup — appel programmatique silencieusement ignoré → §6.7 |
| JS interop Promise sans .toDart | Les API navigateur retournent des JS Promise — utiliser `.toDart` (dart:js_interop) pour les convertir en Future → §6.7 §6.8 |
| MediaPipe avant chargement WASM | PoseLandmarker.create() est async — appeler detectForVideo() avant le chargement WASM provoque un crash silencieux → §6.8 |
| `const Map<double, double>` avec clés double | Dart interdit les const map avec clés double (équality non primitive) → utiliser if/else chain → cf. HrCalculator |

---

---

## 8. Roadmap Phase 3.6 + 3.7 — Parité Web/APK

### Phase 3.6 — BLE Web (Chrome/Edge) ✅ — Livrée le 27 Mars 2026

> Rend le cardio BLE (Polar H10) fonctionnel depuis Chrome/Edge sur laptop et smartphone.
> Déployée sur https://pentarun.netlify.app — Deploy ID : 69c6f8eeba4976cb24f03724

| Sprint | Livrable | Durée | Statut |
|---|---|---|---|
| Sprint 1 | `web_bluetooth.dart` — JS interop BluetoothDevice / GATT / DataView | 5 j | ✅ Livré |
| Sprint 2 | `ble_service_web.dart` — scan, connect, hrStream, disconnect | 5 j | ✅ Livré |
| Sprint 3 | `_HrPairingCard` Web — bouton CONNECTER, badge WEB—CHROME, auto-connect | 3 j | ✅ Livré |
| Sprint 4 | Reconnexion `gattserverdisconnected` + catégorisation erreurs (NotFoundError, SecurityError, NotSupportedError) | 3 j | ✅ Livré |
| Sprint 5 | Tests terrain — Chrome Desktop + Polar H10, Chrome Android, scénarios reconnexion | 4 j | 🔧 En cours |

**Contraintes :** Chrome/Edge uniquement (Web Bluetooth W3C) · HTTPS requis · Popup pairing obligatoire

### Phase 3.7 — CV Web (MediaPipe, tous navigateurs) — 23 jours estimés

> Rend le comptage de reps par caméra fonctionnel dans tous les navigateurs modernes.

| Sprint | Livrable | Durée |
|---|---|---|
| Sprint 1 | `mediapipe_web.dart` + chargement WASM dans `web/index.html` | 3 j |
| Sprint 2 | Accès caméra `getUserMedia()` + `HtmlElementView` Flutter Web | 4 j |
| Sprint 3 | Pipeline `PoseLandmarker.detectForVideo()` + conversion landmarks | 5 j |
| Sprint 4 | `cv_service_web.dart` complet — `buildPreview()`, `startCamera()`, `stopCamera()` | 4 j |
| Sprint 5 | UI — aperçu webcam SetupScreen Web | 2 j |
| Sprint 6 | Tests performance WASM (cible 15–30 fps) + validation RepCounterEngine | 5 j |

**Compatible :** Chrome ✅ · Edge ✅ · Firefox ✅ · Safari ✅ · HTTPS requis

### Couverture cible après 3.6 + 3.7

| Plateforme | BLE Cardio | CV Reps | Score |
|---|---|---|---|
| Chrome / Edge (laptop + Android) | ✅ | ✅ | 10/10 |
| Firefox / Safari | ❌ (W3C) | ✅ | 9/10 |
| Android APK | ✅ | ✅ | 10/10 |

---

*SPEC-KIT v1.1 · KAFORGE · Kinetic Axiom — Phase 3.5 livrée · Phase 3.6 = BLE Web ✅ livrée 2026-03-27 · Phase 3.7 = CV Web 📋 · Phase 4 = Coaching Solaris · Phase 5 = Infrastructure Souveraine*
