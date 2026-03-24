// SPEC-KIT §5.2 — Calculateur score plateforme OPENSPEC v2.0
// scorePlateforme = finalTimeMs × coeff_KB × coeff_age × coeff_sexe
// Plus le score est bas, meilleur est le classement.

class PlatformScoreCalculator {
  PlatformScoreCalculator._();

  /// SPEC-KIT §5.2 — Score plateforme (classement général intra-niveau)
  /// Athlète référence : Senior homme · CHALLENGER · 24 kg KB
  /// → coeff_KB=0.800 · coeff_age=1.000 · coeff_sexe=1.000
  static double calculate({
    required int finalTimeMs,
    required double coeffKb,
    required double coeffAge,
    required double coeffSexe,
  }) {
    return finalTimeMs * coeffKb * coeffAge * coeffSexe;
  }

  /// SPEC-KIT §6.5 — Score plateforme avec HR (coeff_physio dynamique)
  /// coeff_physio = (FC_moy / FC_max_theorique) × coeff_age_statique
  /// FC_max_theorique = 208 − (0.7 × âge) — Tanaka 2001
  static double calculateWithHr({
    required int finalTimeMs,
    required double coeffKb,
    required double coeffSexe,
    required double fcMoy,
    required double fcMaxTheorique,
    required double coeffAgeStatique,
  }) {
    // SPEC-KIT §6.5 — coeff_physio dynamique
    final coeffPhysio = (fcMoy / fcMaxTheorique) * coeffAgeStatique;
    return finalTimeMs * coeffKb * coeffPhysio * coeffSexe;
  }

  /// SPEC-KIT §6.4 — FC max théorique (Tanaka 2001)
  /// Plus précis que 220-âge pour les adultes actifs
  static double fcMaxTheorique(int age) => 208 - (0.7 * age);

  /// SPEC-KIT §6.4 — TRIMP (Bannister 1991)
  /// b = 1.92 hommes · b = 1.67 femmes
  static double trimp({
    required double dureeMins,
    required double fcMoy,
    required double fcMaxTheorique,
    required bool estHomme,
  }) {
    final ratio = fcMoy / fcMaxTheorique;
    final b = estHomme ? 1.92 : 1.67;
    return dureeMins * ratio * (2.718281828 * (b * ratio));
  }
}
