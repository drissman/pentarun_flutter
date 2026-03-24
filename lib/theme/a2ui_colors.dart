import 'package:flutter/material.dart';

// SPEC-KIT §6 — Palette A2UI complète (A2UI Design System v1.3)
// Règle inviolable : jamais de valeur hex en dur hors de ce fichier.
class A2Colors {
  A2Colors._();

  // ─── Fonds & Surfaces ──────────────────────────────────────────────────────
  static const Color bg          = Color(0xFF090909); // Fond principal — dark-only
  static const Color card        = Color(0xFF111111); // Surface cards
  static const Color surface     = Color(0xFF181818); // Couches intermédiaires
  static const Color surfaceDark = Color(0xFF0A0A0A); // Headers de cards
  static const Color border      = Color(0xFF1F1F1F); // Contours subtils
  static const Color border2     = Color(0xFF2A2A2A); // Contours actifs

  // ─── Couleurs Sémantiques ──────────────────────────────────────────────────
  static const Color cyan     = Color(0xFF06B6D4); // Action principale / Chrono actif
  static const Color cyanDark = Color(0xFF0891B2); // État pressed bouton Valider
  static const Color vert     = Color(0xFF10B981); // Terminé / Score / Bague complète
  static const Color rouge    = Color(0xFFEF4444); // Pénalité / No-Count / DNF / Clôturer
  static const Color ambre    = Color(0xFFF59E0B); // Énergie / EPOC / Podium Or
  static const Color blanc    = Color(0xFFF0F0F0); // Textes principaux — ratio 14.5:1 AAA

  // ─── Gris — WCAG AA (ERRATA v1.4 §6) ─────────────────────────────────────
  // gris1 : texte secondaire — ratio 5.8:1 sur #111111 → WCAG AA ✅
  static const Color gris1 = Color(0xFF9CA3AF);
  // gris2 : DÉCORATION UNIQUEMENT (bordures, séparateurs) — ratio 3.2:1 → WCAG AA ❌
  // INTERDIT pour tout texte lisible (cf. A2UI §7, SPEC-KIT anti-patterns)
  static const Color gris2 = Color(0xFF4B5563);

  // ─── Couleurs Podium (v1.3) ───────────────────────────────────────────────
  // SPEC-KIT §6 — Rang 1 : ambre (réutilisé) | Rang 2 : argent | Rang 3 : bronze
  static const Color argent = Color(0xFF9CA3AF); // Podium rang 2
  static const Color bronze = Color(0xFFB45309); // Podium rang 3
}
