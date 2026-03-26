// SPEC-KIT §6.3–6.6 — Phase 3 — Métriques cardiaques calculées à la fin de course

class HrMetrics {
  /// FC moyenne sur la durée de la course (bpm)
  final int fcMoy;

  /// FC maximale atteinte (bpm)
  final int fcMaxAtteinte;

  /// FC max théorique (Tanaka 2001 : 208 – 0.7 × âge_estimé)
  final int fcMaxTheorique;

  /// TRIMP Bannister 1991 — charge cardiaque totale (u.a.)
  final double trimp;

  /// coeff_physio = (FC_moy / FC_max_theo) × coeff_age_statique
  final double coeffPhysio;

  /// scorePlateforme_HR = finalTimeMs × coeffKb × coeffPhysio × coeffSexe
  /// null si finalTimeMs non disponible au moment du calcul
  final double? platformScoreHr;

  const HrMetrics({
    required this.fcMoy,
    required this.fcMaxAtteinte,
    required this.fcMaxTheorique,
    required this.trimp,
    required this.coeffPhysio,
    this.platformScoreHr,
  });

  HrMetrics withPlatformScoreHr(double score) => HrMetrics(
        fcMoy: fcMoy,
        fcMaxAtteinte: fcMaxAtteinte,
        fcMaxTheorique: fcMaxTheorique,
        trimp: trimp,
        coeffPhysio: coeffPhysio,
        platformScoreHr: score,
      );

  /// Sérialisation JSON pour stockage dans results.hr_data (Supabase)
  Map<String, dynamic> toJson() => {
        'fc_moy': fcMoy,
        'fc_max_atteinte': fcMaxAtteinte,
        'fc_max_theorique': fcMaxTheorique,
        'trimp': trimp,
        'coeff_physio': coeffPhysio,
        if (platformScoreHr != null) 'platform_score_hr': platformScoreHr,
      };
}
