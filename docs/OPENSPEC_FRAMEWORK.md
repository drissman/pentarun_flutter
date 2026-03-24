# OPENSPEC — Framework de Spécification KAFORGE

> **Kinetic Axiom / KAFORGE** · Version du framework : 1.0
> Dernière mise à jour : 24 Mars 2026

---

## 1. Définition

**OPENSPEC** (Open Specification) est le framework de cahier des charges vivant utilisé par KAFORGE pour piloter le développement de ses produits. Il s'agit d'un document structuré et versionné qui sert de **contrat permanent** entre la vision fonctionnelle et le code produit.

Contrairement à un cahier des charges classique figé à la livraison, l'OPENSPEC évolue avec le produit : chaque correction de bug, nouvelle fonctionnalité ou ajustement biomécanique se traduit par une nouvelle version du document, maintenant la cohérence totale entre la spec et l'implémentation.

---

## 2. Principes Fondateurs

### 2.1 Idéalité (TRIZ)
Chaque fonctionnalité doit tendre vers la forme la plus simple possible qui accomplit l'objectif. Aucune complexité non nécessaire n'est tolérée. L'élagage volontaire (§7.2 OPENSPEC) matérialise ce principe.

### 2.2 Qualité Locale
Chaque composant de l'interface (bouton, carte, chrono) est spécifié indépendamment avec ses propres exigences de taille, couleur et comportement. Pas de style global ambigu.

### 2.3 Vérité Unique
Les formules mathématiques (biomécaniques, énergétiques) sont définies une seule fois dans l'OPENSPEC et copiées telles quelles dans le code. Aucune divergence tolérée. Les errata documentent explicitement les corrections (ex: h_oh v1.0 → v1.2).

### 2.4 Traçabilité Totale
Chaque ligne de code critique peut être référencée à un paragraphe OPENSPEC (ex: `§3.2`, `§4.2`). Les matrices de conformité (§7.1) assurent cette traçabilité.

---

## 3. Structure d'un Document OPENSPEC

Un document OPENSPEC suit obligatoirement cette structure :

```
OPENSPEC — [Titre]
├── En-tête : Version, Date, Statut, Entité
├── ERRATA : Corrections par rapport à la version précédente
├── §1. Vision et Objectifs Stratégiques
├── §2. Architecture Technologique
├── §3. Moteur Mathématique / Règles Métier
├── §4. Spécifications Fonctionnelles IHM
│   ├── §4.1 Phase 1 (Setup / Entrée)
│   ├── §4.2 Phase 2 (Opération principale)
│   └── §4.3 Phase 3 (Sortie / Résultats)
├── §5. Modélisation des Données (Schema)
├── §6. Exigences Ergonomiques
└── §7. Conformité et Roadmap
    ├── §7.1 Matrice de Conformité
    ├── §7.2 Élagage Volontaire
    └── §7.3 Roadmap SPEC-KIT
```

---

## 4. Cycle de Vie d'une Version OPENSPEC

```
[Idée / Bug / Évolution]
        ↓
[Rédaction ERRATA]
        ↓
[Mise à jour §§ concernés]
        ↓
[Mise à jour Matrice Conformité §7.1]
        ↓
[Tag version : vX.Y]
        ↓
[Implémentation code]
        ↓
[Validation conformité via SPEC-KIT]
        ↓
[Release]
```

---

## 5. Conventions de Versioning

| Format | Signification |
|---|---|
| `v1.0` | Version initiale |
| `v1.1` | Correction mineure (bug formule, label) |
| `v1.2` | Correction conformité / errata significatif |
| `v1.3` | Enrichissement fonctionnel (nouvelles features) |
| `v2.0` | Refonte architecturale majeure |

La version OPENSPEC est indépendante de la version applicative (semver `1.3.0+3`). Les deux doivent être explicitement référencées dans le code et les commits.

---

## 6. Intégration dans le Code Flutter

Chaque constante ou formule critique inclut un commentaire de référence OPENSPEC :

```dart
// OPENSPEC §3.2 — h_oh = H × 1.15 (CORRIGÉ v1.2, était 1.25)
final double hOh = h * 1.15;

// OPENSPEC §4.2 — Fat Finger Design : hauteur minimale 9rem
height: 144, // 9rem × 16px
```

---

## 7. Document OPENSPEC actif

Le document OPENSPEC actif pour ce projet est :

**`OPENSPEC_PENTARUN_v1.3.docx`** (dossier Downloads)

Il constitue la source de vérité pour toute décision de développement.

---

*Framework OPENSPEC · KAFORGE · Kinetic Axiom*
