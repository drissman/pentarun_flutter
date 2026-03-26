// SPEC-KIT §3.5.3 — Phase 3.5 — Landmark articulaire MediaPipe Pose
// Indices GATT MediaPipe Pose Landmarker (BlazePose 33 points)
class PoseLandmark {
  final int index;
  final double x;        // normalisé [0.0, 1.0]
  final double y;        // normalisé [0.0, 1.0]
  final double z;        // profondeur relative
  final double confidence; // [0.0, 1.0]

  const PoseLandmark({
    required this.index,
    required this.x,
    required this.y,
    this.z = 0,
    required this.confidence,
  });

  // ─── Indices MediaPipe Pose Landmarker ─────────────────────────────────────
  static const int leftShoulder  = 11;
  static const int rightShoulder = 12;
  static const int leftElbow     = 13;
  static const int rightElbow    = 14;
  static const int leftWrist     = 15;
  static const int rightWrist    = 16;
}

/// Côté du corps utilisé pour le comptage
enum RepSide { left, right }

/// État de la machine à états angulaire
enum RepState {
  /// Position initiale / indéterminée
  neutral,
  /// Bras bas — angle < seuil_bas (KB à hauteur hanche/épaule)
  basse,
  /// Bras haut — angle > seuil_haut (KB au-dessus de la tête, coude tendu)
  haute,
}

/// Événement de répétition détectée
class RepEvent {
  final DateTime timestamp;
  final RepSide side;
  final double confidence; // Confiance moyenne des landmarks impliqués
  final int repNumber;     // Numéro de la rep (cumul depuis reset)

  const RepEvent({
    required this.timestamp,
    required this.side,
    required this.confidence,
    required this.repNumber,
  });
}
