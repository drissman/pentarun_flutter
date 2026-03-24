import 'package:pentarun_flutter/models/energy_breakdown.dart';
import 'package:pentarun_flutter/models/level.dart';

class EnergyCalculator {
  EnergyCalculator._();

  /// Moteur thermodynamique OPENSPEC v1.2
  /// FIX §3.2 : h_oh = H × 1.15 (était 1.25)
  static EnergyBreakdown calculate({
    required int weightAthleteKg,
    required int heightAthleteCm,
    required int weightKbKg,
    required Level level,
  }) {
    final double r = level.repsPerStation.toDouble();
    final double h = heightAthleteCm / 100.0;
    final double hRack = h * 0.80;
    final double hOh = h * 1.15; // CORRIGÉ v1.2 (était 1.25)
    final double hDip = h * 0.15;
    final double f = weightKbKg * 9.81;

    final double w = f * hRack * r +
        f * (hOh - hRack) * r +
        f * (hOh - hRack + hDip) * r +
        f * hOh * r +
        f * (hOh - hRack + hDip / 2) * r;

    final double steel = w / 4184;
    final double run = 1.03 * weightAthleteKg * level.runDistKm;
    final double total = (run + steel) * 1.15;

    return EnergyBreakdown(run: run, steel: steel, total: total);
  }
}
