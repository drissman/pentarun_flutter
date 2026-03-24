// SPEC-KIT §5.2 — Tests unitaires moteur biomécanique
// Vérifie la conformité des formules OPENSPEC v1.4 (ERRATA §3)

import 'package:flutter_test/flutter_test.dart';
import 'package:pentarun_flutter/engine/energy_calculator.dart';
import 'package:pentarun_flutter/models/level.dart';

void main() {
  group('EnergyCalculator — OPENSPEC v1.4', () {
    // ─── Constantes ──────────────────────────────────────────────────────────

    test('SPEC-KIT §3.2 — efficacité musculaire η = 0.20', () {
      expect(EnergyCalculator.kMuscularEfficiency, 0.20);
    });

    test('SPEC-KIT §3.2 ERRATA v1.4 — facteur excentrique = 1.25', () {
      expect(EnergyCalculator.kEccentricFactor, 1.25);
    });

    test('SPEC-KIT §3.2 ERRATA v1.4 — EPOC HIIT = 1.30 (était 1.15)', () {
      expect(EnergyCalculator.kEpoc, 1.30);
    });

    test('SPEC-KIT §3.2 ERRATA v1.4 — h_rack = 0.73 (était 0.80)', () {
      expect(EnergyCalculator.kRackRatio, 0.73);
    });

    test('SPEC-KIT §3.2 ERRATA v1.4 — h_oh = 1.22 (était 1.15)', () {
      expect(EnergyCalculator.kOhRatio, 1.22);
    });

    test('SPEC-KIT §3.2 ERRATA v1.4 — h_dip = 0.12 (était 0.15)', () {
      expect(EnergyCalculator.kDipRatio, 0.12);
    });

    // ─── Athlète référence CHALLENGER ────────────────────────────────────────
    // 75 kg / 175 cm / 24 kg KB / CHALLENGER (30 reps, 2 km)
    // Résultat v1.4 attendu : ~287 kcal total

    late final result;

    setUpAll(() {
      result = EnergyCalculator.calculate(
        weightAthleteKg: 75,
        heightAthleteCm: 175,
        weightKbKg: 24,
        level: Level.challenger,
      );
    });

    test('SPEC-KIT §3.2 — run CHALLENGER (75kg, 2km) ≈ 154.5 kcal', () {
      // run = 1.03 × 75 × 2.0 = 154.5
      expect(result.run, closeTo(154.5, 0.1));
    });

    test('SPEC-KIT §3.2 — steel CHALLENGER (175cm, 24kg, 30reps) ≈ 66.5 kcal', () {
      // wConc ≈ 44 503 J → steel = (44503 / (4184×0.20)) × 1.25 ≈ 66.5
      expect(result.steel, closeTo(66.5, 1.0));
    });

    test('SPEC-KIT §3.2 — total CHALLENGER avec EPOC×1.30 ≈ 287 kcal', () {
      // total = (154.5 + 66.5) × 1.30 ≈ 287
      expect(result.total, closeTo(287.0, 2.0));
    });

    test('SPEC-KIT §3.2 — total > run (acier + EPOC non nul)', () {
      expect(result.total, greaterThan(result.run));
    });

    test('SPEC-KIT §3.2 — total > steel (course domine pour CHALLENGER)', () {
      expect(result.run, greaterThan(result.steel));
    });

    // ─── Autres niveaux — monotonie ──────────────────────────────────────────

    test('SPEC-KIT §5.1 — TITAN > ELITE > CHALLENGER > ACTIF > DECOUVERTE', () {
      final levels = [
        Level.decouverte,
        Level.actif,
        Level.challenger,
        Level.elite,
        Level.titan,
      ];
      final totals = levels
          .map((l) => EnergyCalculator.calculate(
                weightAthleteKg: 70,
                heightAthleteCm: 170,
                weightKbKg: 20,
                level: l,
              ).total)
          .toList();

      for (int i = 1; i < totals.length; i++) {
        expect(totals[i], greaterThan(totals[i - 1]),
            reason:
                '${levels[i].label} doit dépenser plus que ${levels[i - 1].label}');
      }
    });

    // ─── Monotonie poids KB ───────────────────────────────────────────────────

    test('SPEC-KIT §3.2 — KB plus lourd → dépense acier plus élevée', () {
      final light = EnergyCalculator.calculate(
        weightAthleteKg: 70,
        heightAthleteCm: 170,
        weightKbKg: 16,
        level: Level.challenger,
      );
      final heavy = EnergyCalculator.calculate(
        weightAthleteKg: 70,
        heightAthleteCm: 170,
        weightKbKg: 32,
        level: Level.challenger,
      );
      expect(heavy.steel, greaterThan(light.steel));
    });

    // ─── Plausibilité absolue ─────────────────────────────────────────────────

    test('SPEC-KIT §3.2 — total DECOUVERTE > 50 kcal (plancher réaliste)', () {
      final r = EnergyCalculator.calculate(
        weightAthleteKg: 60,
        heightAthleteCm: 160,
        weightKbKg: 8,
        level: Level.decouverte,
      );
      expect(r.total, greaterThan(50.0));
    });

    test('SPEC-KIT §3.2 — total TITAN < 1000 kcal (plafond réaliste)', () {
      final r = EnergyCalculator.calculate(
        weightAthleteKg: 90,
        heightAthleteCm: 190,
        weightKbKg: 40,
        level: Level.titan,
      );
      expect(r.total, lessThan(1000.0));
    });
  });
}
