# A2UI — Axiom Adaptive User Interface

> Design System propriétaire **KAFORGE / Kinetic Axiom**
> Conforme OPENSPEC v1.3 · SPEC-KIT v1.0

---

## 1. Principe

**A2UI** est le protocole d'interface conçu pour les applications opérées en conditions dégradées : gymnase, compétition, stress, gants, luminosité variable. Il maximise la lisibilité et minimise la charge cognitive des utilisateurs (juges, athlètes, organisateurs).

**Deux impératifs absolus :**
1. **Contraste maximal** — aucune ambiguïté visuelle possible
2. **Fat Finger Design** — chaque action interactive est atteignable sans précision tactile

---

## 2. Palette de Couleurs

Fichier source : `lib/theme/a2ui_colors.dart`

### Fonds et Surfaces

| Token | Hex | Usage |
|---|---|---|
| `bg` | `#090909` | Fond principal — dark mode strict |
| `card` | `#111111` | Surface cards |
| `surface` | `#181818` | Couches intermédiaires |
| `surfaceDark` | `#0A0A0A` | Headers de cards |
| `border` | `#1F1F1F` | Contours subtils |
| `border2` | `#2A2A2A` | Contours actifs |

### Couleurs Sémantiques

| Token | Hex | Sémantique |
|---|---|---|
| `cyan` | `#06B6D4` | Action principale / Validation / Chrono actif |
| `cyanDark` | `#0891B2` | État pressed du bouton Valider |
| `vert` | `#10B981` | Terminé / Score / Bague complète |
| `rouge` | `#EF4444` | Pénalité / No-Count / DNF / Clôturer |
| `ambre` | `#F59E0B` | Énergie / EPOC / Podium Rang 1 |
| `blanc` | `#F0F0F0` | Textes principaux |
| `gris1` | `#9CA3AF` | Labels secondaires |
| `gris2` | `#4B5563` | Labels tertiaires / séparateurs |

### Couleurs Podium (v1.3)

| Token | Hex | Usage |
|---|---|---|
| `ambre` | `#F59E0B` | Rang 1 — Or |
| `argent` | `#9CA3AF` | Rang 2 — Argent |
| `bronze` | `#B45309` | Rang 3 — Bronze |

---

## 3. Typographie

### Valeurs Temporelles — Monospace obligatoire
```dart
// Anti-tremblement : les chiffres monospace ont une largeur fixe
// Le chrono ne "tremble" pas quand les millisecondes changent
style: TextStyle(
  fontFamily: 'monospace', // JetBrains Mono recommandé
  fontWeight: FontWeight.w900,
)
```

### Données Textuelles — Sans-Serif Heavy
```dart
// Noms athlètes, labels d'action, scores
style: TextStyle(
  fontWeight: FontWeight.w900, // 900 uniquement
  letterSpacing: 1.5,          // espacement pour lisibilité
)
```

### Microtypo — Labels secondaires
```dart
style: TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w700,
  letterSpacing: 2,    // uppercase + tracking large
  color: A2Colors.gris2,
)
```

---

## 4. Fat Finger Design

### Règle fondamentale
> Tout élément interactif doit être activable sans précision tactile, avec des gants, sous stress compétitif.

### Spécifications minimales

| Élément | Taille minimale | Implémentation |
|---|---|---|
| Bouton VALIDER | 144px (9rem) | `height: 144` |
| Bouton NO-COUNT | 40px | `padding: vertical 10` |
| Bouton UNDO | 40×40px | `IconButton` |
| Tuiles Actions Rapides | 80px hauteur | `padding: vertical 18` |

### Application dans le code
```dart
// SPEC-KIT §4.2 — Fat Finger : ≥ 9rem
SizedBox(
  width: double.infinity,
  height: 144,
  child: ElevatedButton(...)
)
```

---

## 5. Composants A2UI

### 5.1 Card Standard
```
Fond: A2Colors.card (#111111)
Border: 1px A2Colors.border2
Border-radius: 16px
Header: A2Colors.surfaceDark avec padding 16px
```

### 5.2 Bague de Progression Circulaire
- Ring gauge `CustomPainter`
- Stroke: 6px
- Fond anneau: `#2A2A2A`
- Progression: cyan → vert (quand terminé)
- Animation: `strokeCap: StrokeCap.round`
- Taille: 72×72px minimum

### 5.3 Bouton Action Principale
```
Fond: A2Colors.cyanDark
Texte: Colors.black (contraste maximal)
Border-radius: 12px
FontWeight: w900
LetterSpacing: 1.5
```

### 5.4 Bouton Danger / Pénalité
```
Fond: #1A0505
Border: #5A1A1A
Texte: A2Colors.rouge
Style: OutlinedButton
```

### 5.5 Tags Metadata
```
Fond: #1A1A1A
Border: couleur × 0.2 opacity
Border-radius: 4px
Padding: 8px × 3px
FontSize: 10px
FontWeight: w700
```

---

## 6. Responsive A2UI

Le protocole A2UI est conçu pour fonctionner sur tablette (principal) et desktop. Breakpoints :

| Largeur | Colonnes athlètes | Colonnes form |
|---|---|---|
| < 560px | 1 | 2 |
| 560–900px | 2 | 3 |
| > 900px | 3 | 6 |

Implémentation via `LayoutBuilder` + `Wrap` — jamais de `MediaQuery` en dur.

---

## 7. Règles Inviolables

1. **Jamais de light mode** — A2UI est dark-only
2. **Jamais de couleur hex en dur** — passer par `A2Colors` uniquement
3. **Jamais de fontWeight < 700** pour les données compétitives
4. **Jamais de police proportionnelle** pour les valeurs temporelles
5. **Toujours `letterSpacing ≥ 1.5`** pour les labels uppercase
6. **Jamais de fond blanc ou gris clair** sur un overlay
7. **Jamais `gris2` comme couleur de texte lisible** — `gris2` est réservé aux bordures et séparateurs décoratifs. Tout texte secondaire utilise au minimum `gris1` (#9CA3AF, ratio ~5.8:1). `gris2` (#4B5563) ne passe pas le seuil WCAG AA sur fond `#111111`.

## 8. Règle de Contraste Texte (v1.4)

| Rôle du texte | Couleur minimale | Ratio | WCAG |
|---|---|---|---|
| Texte principal | `blanc` (#F0F0F0) | 14.5:1 | AAA ✅ |
| Texte secondaire (labels) | `gris1` (#9CA3AF) | 5.8:1 | AA ✅ |
| Texte désactivé | `gris1` (#9CA3AF) | 5.8:1 | AA ✅ |
| Bordures / séparateurs | `gris2` (#4B5563) | décoratif | — |
| **INTERDIT texte** | `gris2` (#4B5563) | 3.2:1 | ❌ fail |

---

*A2UI Design System v1.3 · KAFORGE · Kinetic Axiom*
*Conforme OPENSPEC v1.3 · SPEC-KIT v1.0*
