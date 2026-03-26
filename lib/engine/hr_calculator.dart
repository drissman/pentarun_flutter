// SPEC-KIT §6.3–6.6 — Phase 3 — Moteur cardio-métabolique
// Formules : TRIMP Bannister 1991, FC_max Tanaka 2001, coeff_physio OPENSPEC
import 'dart:math' show exp;

import 'package:pentarun_flutter/models/hr_metrics.dart';
import 'package:pentarun_flutter/models/hr_sample.dart';

class HrCalculator {
  HrCalculator._();

  // ─── FC max théorique — Tanaka 2001 ──────────────────────────────────────
  // Utilise l'âge de référence de chaque catégorie (déduit depuis coeff_age)
  static double fcMaxTheorique(double coeffAge) {
    // Ages de référence médians par catégorie OPENSPEC §4.2
    final double age;
    if (coeffAge == 0.980)      age = 16; // Junior
    else if (coeffAge == 0.990) age = 19; // Espoir
    else if (coeffAge == 1.000) age = 30; // Senior
    else if (coeffAge == 0.915) age = 45; // Master 1
    else if (coeffAge == 0.855) age = 55; // Master 2
    else                        age = 65; // Master 3
    return 208 - 0.7 * age;
  }

  // ─── Calcul complet ────────────────────────────────────────────────────────
  /// Retourne null si les échantillons sont insuffisants (< 10 mesures)
  static HrMetrics? compute({
    required List<HrSample> samples,
    required double coeffAge,
    required double coeffSexe,
  }) {
    if (samples.length < 10) return null;

    final bpms = samples.map((s) => s.bpm.toDouble()).toList();
    final fcMoy = bpms.reduce((a, b) => a + b) / bpms.length;
    final fcMax = bpms.reduce((a, b) => a > b ? a : b).toInt();
    final fcMaxTheo = fcMaxTheorique(coeffAge);

    final durationMin = samples.last.timestamp
            .difference(samples.first.timestamp)
            .inSeconds
            .toDouble() /
        60.0;

    // TRIMP Bannister 1991 — b = 1.92 (homme), 1.67 (femme)
    final ratio = fcMoy / fcMaxTheo;
    final b = coeffSexe >= 1.0 ? 1.92 : 1.67;
    final trimp = durationMin * ratio * exp(b * ratio);

    // coeff_physio — SPEC-KIT §6.5
    final coeffPhysio = ratio * coeffAge;

    return HrMetrics(
      fcMoy: fcMoy.round(),
      fcMaxAtteinte: fcMax,
      fcMaxTheorique: fcMaxTheo.round(),
      trimp: trimp,
      coeffPhysio: coeffPhysio,
    );
  }

  // ─── scorePlateforme_HR — SPEC-KIT §6.6 ──────────────────────────────────
  static double platformScoreHr({
    required int finalTimeMs,
    required double coeffKb,
    required double coeffPhysio,
    required double coeffSexe,
  }) =>
      finalTimeMs * coeffKb * coeffPhysio * coeffSexe;
}
