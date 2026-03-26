# PENTARUN v3.5 — Plateforme de Compétition Connectée

> **Projet Solaris** · Entité : **Kinetic Axiom / KAFORGE**
> Version : **3.5.0** · Statut : **Phase 3.5 livrée — Phase 4 planifiée**

Plateforme de chronométrage et de compétition connectée pour le **PENTARUN** — discipline combinant course à pied et kettlebell (5 stations techniques). Plusieurs juges, plusieurs vagues, résultats en temps réel pour l'organisateur et les spectateurs. Score physiologique dynamique via cardiofréquencemètre BLE. Comptage assisté des répétitions par computer vision on-device.

🌐 **[pentarun.netlify.app](https://pentarun.netlify.app)**

---

## Frameworks Méthodologiques

### OPENSPEC
Cahier des charges fonctionnel et technique vivant. Chaque release est alignée sur une version OPENSPEC. → [`docs/OPENSPEC_PENTARUN_v3.5.md`](docs/OPENSPEC_PENTARUN_v3.5.md)

### SPEC-KIT
Matrice de conformité, protocole d'élagage, conventions de code. → [`docs/SPECKIT_GUIDE.md`](docs/SPECKIT_GUIDE.md)

---

## Fonctionnalités

### ✅ Chronomètre local (v1.x)
- Anti-drift (timestamp absolu `DateTime.now()`)
- Bague de progression circulaire par athlète (0 → 5 stations)
- Splits intermédiaires en temps réel
- Bouton VALIDER Fat Finger (144px) — utilisable avec gants
- Bouton NO-COUNT (pénalité) + Undo
- Bilan métabolique : E_run + E_acier + EPOC
- Signatures vectorielles juge + athlète (scellement légal)

### ✅ Identité & Profils (v2.1)
- Auth **email / Google OAuth** (PKCE Flutter Web)
- Profil athlète persistant : nom, sexe, âge, poids, taille, niveau, KB habituel
- **Historique performances** personnel dans Supabase
- Modification de profil depuis l'app · Suppression de compte (cascade complète)

### ✅ Compétition Connectée (v2.2)
- **Création de compétition** par l'organisateur (nom, lieu, date, vagues, niveaux)
- **Inscription athlètes** à une vague via recherche profil
- **Juge connecté** : rejoindre une vague en 3 étapes → chrono local synchronisé en temps réel
- **Vue Directeur** : tableau de bord multi-vagues simultanées, chronos live, classements provisoires
- **Vue Spectateur** : URL publique `/#/live/{competitionId}` sans compte requis
- **Offline Queue** : le chrono continue même sans réseau — replay automatique à la reconnexion

### ✅ Classements & Communauté (v2.3)
- **Podium top-3** visuel (🥇🥈🥉) sur `RankingScreen` — onglet CLASSEMENT
- **Records plateforme** par catégorie âge × sexe — onglet RECORDS
- **Graphique de progression** individuelle (`_ProgressionChart` CustomPaint — PB en ambre)
- **Export PDF** de la fiche résultat (`pdf ^3.12.0`) — téléchargement direct sur Flutter Web
- Vue `records` PostgreSQL (`DISTINCT ON level, coeff_sexe, coeff_age ORDER BY platform_score ASC`)

### ✅ HR & Coefficients Dynamiques (v3)
- **Appairage BLE** cardiofréquencemètre (Polar H10, Garmin HRM — GATT `0x180D`) depuis SetupScreen
- **Capture FC temps réel** pendant la course via `HrSessionService`
- **Calcul TRIMP** post-course (Bannister 1991 : `durée × ratio_FC × e^(b×ratio_FC)`)
- **`coeff_physio`** dynamique = `(FC_moy / FC_max_théo) × coeff_age_statique`
- **`scorePlateforme_HR`** = `finalTimeMs × coeffKb × coeffPhysio × coeffSexe`
- Métriques HR affichées dans `AthleteResultCard` et sauvegardées dans Supabase

### ✅ CV Assist — Feature Gold (v3.5)
- **`RepCounterEngine`** : machine à états angulaire BASSE→HAUTE→BASSE (+1 rep) avec debounce
- Angle calculé par produit scalaire sur les landmarks épaule/coude/poignet (MediaPipe)
- **`RepCounterConfig`** : seuils par mouvement (snatch / jerk / long cycle) × niveau
- **`CvService`** : pattern stub/native — Flutter Web = badge informatif, Android/iOS = MLKit prêt
- **`_CvBadge`** overlay sur `AthleteRaceCard` — alerte ambre si `|cvReps − expectedReps| > 2`
- Feature flag `cv_rep_counting` dans `profiles.features TEXT[]` — activé par l'admin

---

## Formule de Score

```
scorePlateforme = finalTimeMs × coeff_KB × coeff_age × coeff_sexe
```

Quand cardiofréquencemètre disponible :
```
scorePlateforme_HR = finalTimeMs × coeff_KB × coeff_physio × coeff_sexe
coeff_physio = (FC_moy / FC_max_théo) × coeff_age_statique
```

Plus le score est bas, meilleur est le classement.

| coeff | Valeur de référence |
|---|---|
| `coeff_KB` | 0.800 (24 kg KB) |
| `coeff_age` | 1.000 (Senior 22–39 ans) |
| `coeff_sexe` | 1.000 (Homme) · 0.870 (Femme) |

---

## Stack Technique

| Élément | Technologie |
|---|---|
| Frontend | Flutter 3.x / Dart — compilé en Web |
| Déploiement | Netlify (SPA statique) |
| Backend | Supabase (Auth · PostgreSQL · Realtime · Edge Functions) |
| State Management | `InheritedNotifier` (AppState) |
| Temps réel | Supabase Realtime — WebSocket PostgreSQL LISTEN/NOTIFY |
| Offline | localStorage (dart:html) — OfflineQueue pattern stub/web |
| Design System | A2UI v1.3 (dark mode strict · Fat Finger · typographie monospace) |
| PDF | `pdf ^3.12.0` — génération Flutter, téléchargement dart:html (web) |
| BLE HR | `flutter_blue_plus` (natif Android/iOS) — stub no-op sur Flutter Web |
| CV Assist | `google_mlkit_pose_detection` (natif Android/iOS) — stub no-op sur Flutter Web |

---

## Architecture

```
Juge 1          Juge 2          Directeur       Spectateur
(Flutter Web)   (Flutter Web)   (Flutter Web)   (navigateur, sans auth)
     │               │               │               │
     └───────────────┴───────────────┴───────────────┘
                             │
                      NETLIFY (CDN)
                      pentarun.netlify.app
                      pentarun.netlify.app/#/live/{id}
                             │ HTTPS / WebSocket
                      SUPABASE (Backend)
                      Auth · PostgreSQL · Realtime · RLS
                             │
                      BLE (optionnel, local)
                      Polar H10 · Garmin HRM (GATT 0x180D)
```

---

## Structure du Projet

```
lib/
├── engine/
│   ├── energy_calculator.dart         # Moteur thermodynamique OPENSPEC
│   ├── hr_calculator.dart             # TRIMP Bannister 1991 + coeff_physio
│   └── rep_counter_engine.dart        # Machine à états angulaire CV Assist
├── models/
│   ├── athlete.dart                   # Modèle athlète local (course)
│   ├── athlete_profile.dart           # Profil persistant Supabase + features[]
│   ├── competition.dart               # Compétition Supabase
│   ├── energy_breakdown.dart          # Bilan métabolique
│   ├── hr_device.dart                 # Appareil BLE (id, name, rssi)
│   ├── hr_metrics.dart                # Métriques cardiaques post-course
│   ├── hr_sample.dart                 # Échantillon BLE (bpm, timestamp)
│   ├── level.dart                     # Niveaux PENTARUN + repsPerStation
│   ├── pose_landmark.dart             # Landmarks MediaPipe + RepEvent/RepState
│   ├── race_result.dart               # Résultat persistant Supabase (HR + CV)
│   ├── rep_counter_config.dart        # Config seuils angulaires par mouvement/niveau
│   ├── wave.dart                      # Vague (statut, niveau, started_at)
│   └── wave_athlete.dart              # Athlète inscrit + progression live
├── screens/
│   ├── auth_screen.dart               # Auth email / Google OAuth
│   ├── competition_create_screen.dart # Création compétition
│   ├── competition_list_screen.dart   # Gestion compétitions (organisateur)
│   ├── director_screen.dart           # Vue directeur temps réel
│   ├── history_screen.dart            # Historique + graphique progression + export PDF
│   ├── profile_screen.dart            # Profil athlète
│   ├── racing_screen.dart             # L'Arène (chrono live)
│   ├── ranking_screen.dart            # Classement podium + records par catégorie
│   ├── setup_screen.dart              # Chambre d'Appel + appairage BLE
│   ├── spectator_screen.dart          # Vue spectateur publique (sans auth)
│   ├── summary_screen.dart            # Bilan + scellement
│   └── wave_join_screen.dart          # Rejoindre une vague connectée
├── services/
│   ├── auth_service.dart              # Auth Supabase
│   ├── ble_service.dart               # Export conditionnel BLE stub/natif
│   ├── ble_service_native.dart        # flutter_blue_plus (commenté — prêt à activer)
│   ├── ble_service_stub.dart          # No-op (Flutter Web)
│   ├── competition_service.dart       # CRUD compétitions + vagues
│   ├── cv_rep_session.dart            # Singleton accumulation reps CV par station
│   ├── cv_service.dart                # Export conditionnel CV stub/natif
│   ├── cv_service_native.dart         # MLKit PoseDetection (commenté — prêt à activer)
│   ├── cv_service_stub.dart           # No-op (Flutter Web)
│   ├── hr_session_service.dart        # Buffer BLE + computeMetrics() post-course
│   ├── offline_queue.dart             # File d'attente offline (localStorage)
│   ├── pdf_export_service.dart        # Génération PDF fiche résultat
│   ├── profile_service.dart           # Profils athlètes
│   ├── realtime_service.dart          # Abonnements Supabase Realtime
│   ├── results_service.dart           # Sauvegarde + getRecords()
│   └── wave_service.dart              # Progression live + pushProgress
├── state/
│   └── app_state.dart                 # État global + CV flag + HR metrics
├── theme/
│   ├── a2ui_colors.dart               # Palette A2UI
│   └── a2ui_theme.dart                # ThemeData Flutter
├── utils/
│   ├── pdf_download.dart              # Export conditionnel PDF stub/web
│   ├── pdf_download_stub.dart         # No-op (natif)
│   ├── pdf_download_web.dart          # dart:html Blob URL download
│   ├── time_formatter.dart            # Format MM:SS.cc
│   ├── web_gotrue_storage.dart        # localStorage auth (pas SharedPrefs)
│   └── web_redirect.dart             # window.location.href (OAuth)
└── widgets/
    ├── athlete_race_card.dart         # Carte course + _CvBadge + _StationRingPainter
    ├── athlete_result_card.dart       # Carte résultat + section HR
    └── station_progress_bar.dart      # Barre stations horizontale

supabase/
├── migrations/
│   ├── 001_phase22_competition.sql    # Tables competitions/waves/wave_athletes
│   ├── 002_spectator_access.sql       # RLS anon + display_name
│   ├── 003_records_view.sql           # Vue records (DISTINCT ON par catégorie)
│   ├── 004_hr_data.sql                # Colonnes HR + index platform_score_hr
│   └── 005_cv_feature_flag.sql        # features[] sur profiles + cv_rep_count
└── functions/
    └── delete-account/                # Edge Function suppression compte
```

---

## Roadmap

| Phase | Contenu | Statut |
|---|---|---|
| **v1.x** — Chrono local | Chrono, splits, bilan métabolique, signatures | ✅ Livré |
| **v2.1** — Identité & Profils | Auth, profil, historique, suppression compte | ✅ Livré |
| **v2.2** — Compétition Connectée | Multi-vagues, directeur, spectateurs, offline | ✅ Livré |
| **v2.3** — Classements & Communauté | Ranking segmenté, records, progression individuelle, PDF | ✅ Livré |
| **v3** — HR & Coefficients Dynamiques | BLE cardiofréquencemètre, TRIMP, coeff_physio | ✅ Livré |
| **v3.5** — CV Assist *(Feature Gold)* | MediaPipe on-device, comptage automatique répétitions KB | ✅ Livré |
| **v4** — Module Coaching Solaris | Planification entraînement, périodisation TRIMP, VMA | 🔵 Prochain |
| **v5** — Infrastructure Souveraine | Migration VPS auto-hébergé, sortie Supabase Cloud | 📋 Planifié |

→ Détail des issues : **[github.com/drissman/pentarun_flutter/issues](https://github.com/drissman/pentarun_flutter/issues)**

---

## Design System — A2UI v1.3

Dark Mode strict (`#090909`) — conçu pour les gymnases, lumière artificielle, utilisation sous stress compétitif.

| Token | Couleur | Usage |
|---|---|---|
| `cyan` | `#06B6D4` | Actions · validation · mode connecté |
| `vert` | `#10B981` | Terminé · score · succès |
| `rouge` | `#EF4444` | Chrono live · pénalité · No-Count |
| `ambre` | `#F59E0B` | Énergie · podium Or · alerte CV |
| `blanc` | `#F1F5F9` | Texte principal |
| `gris1` | `#94A3B8` | Texte secondaire |

**Fat Finger Design** — boutons ≥ 144px, utilisables avec gants de kettlebell.

---

## Errata Majeurs Résolus

| Errata | Description |
|---|---|
| §11.1 | Thème A2UI : texte noir sur fond noir → `ThemeData.dark().textTheme.apply()` |
| §11.2 | Spinner invisible en état loading → `backgroundColor` explicite + `color: blanc` |
| §11.3 | Google OAuth : `window.open` bloqué → `window.location.href` |
| §11.4 | Code PKCE non échangé au retour OAuth → échange explicite dans `main()` |
| §11.5 | Spinner infini après suppression compte → `SignOutScope.local` |
| §11.6 | `uuid_generate_v4()` inexistant en migration → `gen_random_uuid()` |
| §11.7 | `FilterType` renommé `PostgresChangeFilterType` (realtime_client 2.7.1) |

---

*Généré par **KAFORGE** — Kinetic Axiom Factory for Optimized Real-time Generative Engineering*
*OPENSPEC v3.5 · SPEC-KIT v1.0 · A2UI v1.3*
