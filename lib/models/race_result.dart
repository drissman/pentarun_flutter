// SPEC-KIT §4.1 — Résultat de course persistant (Supabase)
import 'package:pentarun_flutter/models/level.dart';

class RaceResult {
  final String? id;
  final String profileId;
  final String? competitionName;
  final DateTime waveDate;
  final Level level;
  final int weightKbKg;
  final double coeffKb;
  final double coeffAge;
  final double coeffSexe;
  final int finalTimeMs;
  final double officialScore;
  // SPEC-KIT §5.2 — scorePlateforme = finalTimeMs × coeff_KB × coeff_age × coeff_sexe
  final double platformScore;
  final List<int> splitsMs;
  final int noCountEvents;
  final double? energyRunKcal;
  final double? energySteelKcal;
  final double? energyTotalKcal;
  /// Nom affiché — peuplé uniquement lors d'une requête avec jointure profiles
  final String? athleteDisplayName;

  const RaceResult({
    this.id,
    required this.profileId,
    this.competitionName,
    required this.waveDate,
    required this.level,
    required this.weightKbKg,
    required this.coeffKb,
    required this.coeffAge,
    required this.coeffSexe,
    required this.finalTimeMs,
    required this.officialScore,
    required this.platformScore,
    required this.splitsMs,
    required this.noCountEvents,
    this.energyRunKcal,
    this.energySteelKcal,
    this.energyTotalKcal,
    this.athleteDisplayName,
  });

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    // Nom athlète depuis la jointure profiles (présent uniquement en classement)
    final profiles = json['profiles'] as Map<String, dynamic>?;
    final String? displayName = profiles != null
        ? '${profiles['prenom']} ${profiles['nom']}'.toUpperCase()
        : null;
    return RaceResult(
      id: json['id'] as String?,
      profileId: json['profile_id'] as String,
      competitionName: json['competition_name'] as String?,
      waveDate: DateTime.parse(json['wave_date'] as String),
      level: Level.fromLabel(json['level'] as String),
      weightKbKg: json['weight_kb_kg'] as int,
      coeffKb: (json['coeff_kb'] as num).toDouble(),
      coeffAge: (json['coeff_age'] as num).toDouble(),
      coeffSexe: (json['coeff_sexe'] as num).toDouble(),
      finalTimeMs: json['final_time_ms'] as int,
      officialScore: (json['official_score'] as num).toDouble(),
      platformScore: (json['platform_score'] as num).toDouble(),
      splitsMs: List<int>.from(json['splits'] as List),
      noCountEvents: json['no_count_events'] as int,
      energyRunKcal: (json['energy_run_kcal'] as num?)?.toDouble(),
      energySteelKcal: (json['energy_steel_kcal'] as num?)?.toDouble(),
      energyTotalKcal: (json['energy_total_kcal'] as num?)?.toDouble(),
      athleteDisplayName: displayName,
    );
  }

  Map<String, dynamic> toJson() => {
    'profile_id': profileId,
    if (competitionName != null) 'competition_name': competitionName,
    'wave_date': waveDate.toIso8601String().substring(0, 10),
    'level': level.label,
    'weight_kb_kg': weightKbKg,
    'coeff_kb': coeffKb,
    'coeff_age': coeffAge,
    'coeff_sexe': coeffSexe,
    'final_time_ms': finalTimeMs,
    'official_score': officialScore,
    'platform_score': platformScore,
    'splits': splitsMs,
    'no_count_events': noCountEvents,
    if (energyRunKcal != null) 'energy_run_kcal': energyRunKcal,
    if (energySteelKcal != null) 'energy_steel_kcal': energySteelKcal,
    if (energyTotalKcal != null) 'energy_total_kcal': energyTotalKcal,
  };
}
