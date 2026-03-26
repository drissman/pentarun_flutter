// SPEC-KIT §3.5.3 — Phase 3.5 — Configuration profils angulaires par mouvement
import 'package:pentarun_flutter/models/level.dart';

/// Type de mouvement KB — détermine les seuils angulaires
enum KbMovement {
  snatch,
  jerk,
  longCycle;

  String get label {
    switch (this) {
      case snatch:    return 'SNATCH';
      case jerk:      return 'JERK';
      case longCycle: return 'LONG CYCLE';
    }
  }
}

/// Seuils angulaires et paramètres de détection
class RepCounterConfig {
  /// Angle (°) en dessous duquel le bras est considéré "BAS"
  final double seuilBas;

  /// Angle (°) au-dessus duquel le bras est considéré "HAUT"
  final double seuilHaut;

  /// Confidence minimale MediaPipe pour valider un landmark
  final double minConfidence;

  /// Nombre de frames consécutifs requis pour confirmer un état
  final int debounceFrames;

  const RepCounterConfig({
    required this.seuilBas,
    required this.seuilHaut,
    this.minConfidence = 0.65,
    this.debounceFrames = 3,
  });

  // ─── Profils par mouvement et niveau ─────────────────────────────────────
  // SPEC-KIT §3.5.3 — Seuils calibrés par amplitude réelle par niveau

  static RepCounterConfig forMovement(KbMovement movement, Level level) {
    // Les athlètes TITAN/ELITE ont une amplitude plus complète → seuils plus stricts
    final isElite = level == Level.elite || level == Level.titan;

    switch (movement) {
      case KbMovement.snatch:
        return RepCounterConfig(
          seuilBas:  isElite ? 55 : 65,  // Descente coude plus fermé chez les élites
          seuilHaut: isElite ? 160 : 148, // Extension plus complète chez les élites
        );
      case KbMovement.jerk:
        return RepCounterConfig(
          seuilBas:  isElite ? 60 : 70,
          seuilHaut: isElite ? 162 : 150,
        );
      case KbMovement.longCycle:
        // Long cycle = clean + jerk : amplitude maximale attendue
        return RepCounterConfig(
          seuilBas:  isElite ? 50 : 60,
          seuilHaut: isElite ? 162 : 150,
        );
    }
  }

  /// Profil par défaut (snatch, niveau challenger)
  static const RepCounterConfig defaultConfig = RepCounterConfig(
    seuilBas: 65,
    seuilHaut: 150,
  );
}
