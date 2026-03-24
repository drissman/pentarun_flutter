# PENTARUN — Module Multi-Chronomètre

> **Projet Solaris** · Entité : **Kinetic Axiom / KAFORGE**
> Version : **1.3.0** · Statut : Actif — En Développement

Application de chronométrage et d'analyse métabolique multi-athlètes dédiée au **PENTARUN** — discipline combinant course à pied et kettlebell (5 stations techniques).

---

## Frameworks Méthodologiques

Ce projet est conçu et maintenu selon deux frameworks propriétaires KAFORGE :

### OPENSPEC
Cahier des charges fonctionnel et technique vivant. Chaque release du code est alignée sur une version OPENSPEC qui définit le comportement attendu, les formules biomécaniques, les contraintes ergonomiques et la roadmap. Voir [`docs/OPENSPEC_FRAMEWORK.md`](docs/OPENSPEC_FRAMEWORK.md).

### SPEC-KIT
Boîte à outils de conformité et de validation. Permet de vérifier l'alignement code ↔ spec, de générer les matrices de conformité et de piloter les phases de développement. Voir [`docs/SPECKIT_GUIDE.md`](docs/SPECKIT_GUIDE.md).

---

## Fonctionnalités

### Phase 1 — Chambre d'Appel (SETUP)
- Saisie des données athlètes : nom, niveau, poids kettlebells, taille, masse
- **Prédicteur Énergétique** : visualisation de la dépense calorique théorique avant départ (Course / Acier / EPOC)
- Niveaux compétitifs : DÉCOUVERTE / ACTIF / CHALLENGER / ELITE / TITAN

### Phase 2 — L'Arène A2UI (RACING)
- Chronomètre anti-drift (timestamp absolu `DateTime.now()`)
- **Bague de Progression Circulaire** par athlète (0 → 5 stations)
- **Splits intermédiaires en temps réel** par station
- Bouton VALIDER Fat Finger (144px) — utilisable avec gants
- Bouton NO-COUNT (pénalité rouge) + Undo
- Grille responsive (1/2/3 colonnes)

### Phase 3 — Bilan Métabolique et Légal (SUMMARY)
- Score officiel PENTARUN = Temps brut × Coefficient acier
- **Podium classement** multi-athlètes (Or / Argent / Bronze)
- **Graphique Splits par Station** — analyse analytique (CustomPainter)
- Bilan EPOC : E_run + E_acier + E_total (×1.15)
- Module signature vectorielle (Juge + Athlète) — verrouillage légal Base64
- **Actions Rapides** : Nouvelle vague / Export PDF (Phase 5) / Partager (Phase 5)

---

## Moteur Biomécanique

Moteur thermodynamique déterministe conforme OPENSPEC v1.3 :

| Variable | Formule | Description |
|---|---|---|
| `h_rack` | `H × 0.80` | Position rack |
| `h_oh` | `H × 1.15` | Overhead bras tendu |
| `h_dip` | `H × 0.15` | Amplitude dip |
| `E_run` | `1.03 × M × D(km)` | Dépense course |
| `E_total` | `(E_run + E_kb) × 1.15` | Avec facteur EPOC |

---

## Design System — A2UI

Protocol d'interface **Axiom Adaptive User Interface** :
- Dark Mode strict (`#090909`) — élimination fatigue oculaire en gymnase
- Cyan `#06B6D4` — actions / validation
- Vert `#10B981` — terminé / score
- Rouge `#EF4444` — pénalité / No-Count
- Ambre `#F59E0B` — énergie / podium
- Typographie monospace pour les valeurs temporelles (anti-tremblement)
- Fat Finger Design — boutons ≥ 9rem (utilisable sous stress compétitif)

---

## Stack Technique

| Élément | Technologie |
|---|---|
| Frontend | Flutter / Dart |
| Target | Web (WASM Phase 2) + Mobile |
| State Management | `InheritedNotifier` (AppState) |
| Graphiques | `CustomPainter` natif Flutter |
| Signatures | Canvas vectoriel → Base64 PNG |
| Infrastructure | Google Antigravity + CDN Edge |

---

## Structure du Projet

```
lib/
├── engine/
│   └── energy_calculator.dart    # Moteur thermodynamique OPENSPEC
├── models/
│   ├── athlete.dart              # Modèle athlète + status
│   ├── energy_breakdown.dart     # Résultat calcul énergétique
│   ├── kettlebell.dart           # Coefficients et poids
│   ├── level.dart                # Niveaux compétitifs
│   └── station.dart              # 5 stations PENTARUN
├── screens/
│   ├── setup_screen.dart         # Phase 1 — Chambre d'Appel
│   ├── racing_screen.dart        # Phase 2 — L'Arène
│   └── summary_screen.dart       # Phase 3 — Bilan
├── state/
│   └── app_state.dart            # État global + transitions de phase
├── theme/
│   ├── a2ui_colors.dart          # Palette A2UI complète
│   └── a2ui_theme.dart           # ThemeData Flutter
├── utils/
│   └── time_formatter.dart       # Format MM:SS.cc
└── widgets/
    ├── athlete_form.dart         # Formulaire saisie athlète
    ├── athlete_race_card.dart    # Carte racing (bague + splits)
    ├── athlete_result_card.dart  # Carte résultats (graphique)
    ├── athlete_setup_card.dart   # Carte setup
    ├── signature_pad.dart        # Canvas signature vectorielle
    ├── station_progress_bar.dart # Barre 5 segments
    ├── toast_overlay.dart        # Notifications
    └── send_dialog.dart          # Dialog envoi résultats

docs/
├── OPENSPEC_FRAMEWORK.md         # Méthodologie OPENSPEC
└── SPECKIT_GUIDE.md              # Guide SPEC-KIT
```

---

## Roadmap

| Phase | Contenu | Statut |
|---|---|---|
| **1.3** (actuelle) | Enrichissements UX : Prédicteur, Bague, Splits, Podium, Graphique | 🔧 En cours |
| **2** | Migration WASM + persistance Isar/Hive + historique | 📋 Planifié |
| **3** | PWA + Service Worker offline | 📋 Planifié |
| **4** | Module Coaching Solaris — VMA / VC / Réserve Anaérobie | 📋 Planifié |
| **5** | Export PDF + sync Antigravity + partage natif | 📋 Planifié |

---

*Généré par **KAFORGE** — Kinetic Axiom Factory for Optimized Real-time Generative Engineering*
*OPENSPEC v1.3 · SPEC-KIT v1.0*
