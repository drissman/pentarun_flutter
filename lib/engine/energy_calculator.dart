import 'package:pentarun_flutter/models/energy_breakdown.dart';
import 'package:pentarun_flutter/models/level.dart';

class EnergyCalculator {
  EnergyCalculator._();

  // ─── Constantes biomécaniques OPENSPEC v1.4 ────────────────────────────────

  /// Efficacité mécanique musculaire pour mouvements kettlebell.
  /// Littérature : Farrar (2010), Scott (2011) → 14-20%.
  /// Valeur retenue : 0.20 (conservative, reproduc. en compétition).
  /// FIX v1.4 : était implicitement 1.0 (100%) → sous-estimait l'acier ×5.
  static const double kMuscularEfficiency = 0.20;

  /// Facteur de coût excentrique (phase de descente des KB).
  /// La descente contrôlée représente ~25% du coût concentrique.
  /// FIX v1.4 : absent en v1.3 → sous-estimait l'acier ×1.25.
  static const double kEccentricFactor = 1.25;

  /// Coefficient EPOC (Excess Post-exercise Oxygen Consumption).
  /// PENTARUN = HIIT haute intensité → EPOC élevé.
  /// FIX v1.4 : 1.15 → 1.30 (effort compétitif, Borsheim & Bahr 2003).
  static const double kEpoc = 1.30;

  // ─── Hauteurs biomécaniques OPENSPEC v1.4 ─────────────────────────────────

  /// Position rack : épaule/poitrine, avant-bras vertical.
  /// FIX v1.4 : 0.80 → 0.73 (mesures anthropométriques compétition).
  static const double kRackRatio = 0.73;

  /// Position overhead : bras tendus avec KB.
  /// FIX v1.4 : 1.15 → 1.22 (bras + longueur poignée KB réels).
  static const double kOhRatio = 1.22;

  /// Amplitude dip jerk/push press.
  /// FIX v1.4 : 0.15 → 0.12 (dip compétition chronométré < dip entraîn.).
  static const double kDipRatio = 0.12;

  // ─── Moteur thermodynamique ────────────────────────────────────────────────

  /// OPENSPEC v1.4 — Formule corrigée sur 4 points :
  ///   1. Efficacité musculaire réelle (÷ η = 0.20)
  ///   2. Travail excentrique (× 1.25)
  ///   3. EPOC HIIT (× 1.30 au lieu de 1.15)
  ///   4. Hauteurs biomécaniques recalibrées
  static EnergyBreakdown calculate({
    required int weightAthleteKg,
    required int heightAthleteCm,
    required int weightKbKg,
    required Level level,
  }) {
    final double r = level.repsPerStation.toDouble();
    final double h = heightAthleteCm / 100.0;

    final double hRack = h * kRackRatio;
    final double hOh   = h * kOhRatio;
    final double hDip  = h * kDipRatio;
    final double f     = weightKbKg * 9.81;

    // Travail mécanique concentrique (Joules) — 5 stations
    final double wConcentric =
        f * hRack * r +                       // S1 — Double Clean
        f * (hOh - hRack) * r +               // S2 — Double LC Press
        f * (hOh - hRack + hDip) * r +        // S3 — Double Jerk
        f * hOh * r +                          // S4 — Double Half Snatch
        f * (hOh - hRack + hDip / 2) * r;     // S5 — Double Push Press

    // Coût métabolique acier : concentrique + excentrique, avec efficacité réelle
    final double steel =
        (wConcentric / (4184 * kMuscularEfficiency)) * kEccentricFactor;

    // Dépense course (formule Léger & Mercier — invariante)
    final double run = 1.03 * weightAthleteKg * level.runDistKm;

    // Total avec EPOC HIIT
    final double total = (run + steel) * kEpoc;

    return EnergyBreakdown(run: run, steel: steel, total: total);
  }
}
