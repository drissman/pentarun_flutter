# SPEC-KIT — Guide de Conformité et Validation KAFORGE

> **Kinetic Axiom / KAFORGE** · Version : 1.0
> Dernière mise à jour : 24 Mars 2026

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

### Phase actuelle : 1.4

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

#### Phase 2.2 — Compétition Connectée 📋

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| Multi-vagues temps réel (Supabase) | §7.1 | 📋 Phase 2.2 |
| Vue directeur compétition | §7.2 | 📋 Phase 2.2 |
| Gestion offline / reconnexion | §7.3 | 📋 Phase 2.2 |
| Résultats live spectateurs | §7.2 | 📋 Phase 2.2 |

#### Phase 2.3 — Classements & Communauté 📋

| Fonctionnalité | Référence OPENSPEC v2.0 | Statut |
|---|---|---|
| Ranking général segmenté | §5.6 | 📋 Phase 2.3 |
| Records plateforme par catégorie | §5.6 | 📋 Phase 2.3 |
| Progression individuelle | §5.6 | 📋 Phase 2.3 |
| Export PDF fiche résultat | §9.4 Élagage | 📋 Phase 2.3 |

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

---

*SPEC-KIT v1.0 · KAFORGE · Kinetic Axiom*
