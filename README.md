# PENTARUN v2.2 — Plateforme de Compétition Connectée

> **Projet Solaris** · Entité : **Kinetic Axiom / KAFORGE**
> Version : **2.2.0** · Statut : **Actif — Phase 2.3 en cours**

Plateforme de chronométrage et de compétition connectée pour le **PENTARUN** — discipline combinant course à pied et kettlebell (5 stations techniques). Plusieurs juges, plusieurs vagues, résultats en temps réel pour l'organisateur et les spectateurs.

🌐 **[pentarun.netlify.app](https://pentarun.netlify.app)**

---

## Frameworks Méthodologiques

### OPENSPEC
Cahier des charges fonctionnel et technique vivant. Chaque release est alignée sur une version OPENSPEC. → [`docs/OPENSPEC_PENTARUN_v2.0.md`](docs/OPENSPEC_PENTARUN_v2.0.md)

### SPEC-KIT
Matrice de conformité, protocole d'élagage, conventions de code. → [`docs/SPECKIT_GUIDE.md`](docs/SPECKIT_GUIDE.md)

---

## Fonctionnalités

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

### ✅ Chronomètre local (v1.x)
- Anti-drift (timestamp absolu `DateTime.now()`)
- Bague de progression circulaire par athlète (0 → 5 stations)
- Splits intermédiaires en temps réel
- Bouton VALIDER Fat Finger (144px) — utilisable avec gants
- Bouton NO-COUNT (pénalité) + Undo
- Bilan métabolique : E_run + E_acier + EPOC
- Signatures vectorielles juge + athlète (scellement légal)

---

## Formule de Score

```
scorePlateforme = finalTimeMs × coeff_KB × coeff_age × coeff_sexe
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
```

---

## Structure du Projet

```
lib/
├── engine/
│   └── energy_calculator.dart         # Moteur thermodynamique OPENSPEC
├── models/
│   ├── athlete.dart                   # Modèle athlète local (course)
│   ├── competition.dart               # Compétition Supabase
│   ├── wave.dart                      # Vague (statut, niveau, started_at)
│   └── wave_athlete.dart              # Athlète inscrit + progression live
├── screens/
│   ├── setup_screen.dart              # Chambre d'Appel
│   ├── racing_screen.dart             # L'Arène (chrono live)
│   ├── summary_screen.dart            # Bilan + scellement
│   ├── competition_list_screen.dart   # Gestion compétitions (organisateur)
│   ├── competition_create_screen.dart # Création compétition
│   ├── director_screen.dart           # Vue directeur temps réel
│   ├── spectator_screen.dart          # Vue spectateur publique (sans auth)
│   ├── wave_join_screen.dart          # Rejoindre une vague connectée
│   ├── auth_screen.dart               # Auth email / Google OAuth
│   ├── profile_screen.dart            # Profil athlète
│   ├── history_screen.dart            # Historique performances
│   └── ranking_screen.dart            # Classement en ligne
├── services/
│   ├── competition_service.dart       # CRUD compétitions + vagues
│   ├── wave_service.dart              # Progression live + pushProgress
│   ├── realtime_service.dart          # Abonnements Supabase Realtime
│   ├── offline_queue.dart             # File d'attente offline (localStorage)
│   ├── auth_service.dart              # Auth Supabase
│   ├── profile_service.dart           # Profils athlètes
│   └── results_service.dart           # Sauvegarde résultats
├── state/
│   └── app_state.dart                 # État global + transitions de phase
├── theme/
│   ├── a2ui_colors.dart               # Palette A2UI
│   └── a2ui_theme.dart                # ThemeData Flutter
└── utils/
    ├── time_formatter.dart            # Format MM:SS.cc
    ├── web_redirect.dart              # window.location.href (OAuth)
    └── web_gotrue_storage.dart        # localStorage auth (pas SharedPrefs)

supabase/
├── migrations/
│   ├── 001_phase22_competition.sql    # Tables competitions/waves/wave_athletes
│   └── 002_spectator_access.sql       # RLS anon + display_name
└── functions/
    └── delete-account/                # Edge Function suppression compte
```

---

## Roadmap

| Phase | Contenu | Statut |
|---|---|---|
| **v2.1** — Identité & Profils | Auth, profil, historique, suppression compte | ✅ Livré |
| **v2.2** — Compétition Connectée | Multi-vagues, directeur, spectateurs, offline | ✅ Livré |
| **v2.3** — Classements & Communauté | Ranking segmenté, records, progression individuelle | 🔵 Prochain |
| **v3** — HR & Coefficients Dynamiques | BLE cardiofréquencemètre, TRIMP, coeff_physio | 📋 Planifié |
| **v3.5** — CV Assist *(Feature Gold)* | MediaPipe on-device, comptage automatique répétitions KB | 📋 Planifié |
| **v4** — Infrastructure Souveraine | Migration VPS auto-hébergé, sortie Supabase Cloud | 📋 Planifié |
| **v5** — Module Coaching Solaris | Planification entraînement, périodisation, VMA | 📋 Planifié |

→ Détail des issues : **[github.com/drissman/pentarun_flutter/issues](https://github.com/drissman/pentarun_flutter/issues)**

---

## Design System — A2UI v1.3

Dark Mode strict (`#090909`) — conçu pour les gymnases, lumière artificielle, utilisation sous stress compétitif.

| Token | Couleur | Usage |
|---|---|---|
| `cyan` | `#06B6D4` | Actions · validation · mode connecté |
| `vert` | `#10B981` | Terminé · score · succès |
| `rouge` | `#EF4444` | Chrono live · pénalité · No-Count |
| `ambre` | `#F59E0B` | Énergie · podium Or |
| `blanc` | `#F1F5F9` | Texte principal |
| `gris1` | `#94A3B8` | Texte secondaire |

**Fat Finger Design** — boutons ≥ 144px, utilisables avec gants de kettlebell.

---

## Errata Majeurs Résolus

| Errata | Description |
|---|---|
| §11.3 | Google OAuth : `window.open` bloqué → `window.location.href` |
| §11.4 | Code PKCE non échangé au retour OAuth → échange explicite dans `main()` |
| §11.5 | Spinner infini après suppression compte → `SignOutScope.local` |
| §11.6 | `uuid_generate_v4()` inexistant en migration → `gen_random_uuid()` |
| §11.7 | `FilterType` renommé `PostgresChangeFilterType` (realtime_client 2.7.1) |

---

*Généré par **KAFORGE** — Kinetic Axiom Factory for Optimized Real-time Generative Engineering*
*OPENSPEC v2.2 · SPEC-KIT v1.0 · A2UI v1.3*
