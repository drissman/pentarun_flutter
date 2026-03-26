import 'dart:typed_data';
import 'package:pentarun_flutter/models/energy_breakdown.dart';
import 'package:pentarun_flutter/models/hr_metrics.dart';
import 'package:pentarun_flutter/models/level.dart';

enum AthleteStatus { waiting, running, finished }

class Athlete {
  final String id;
  final String name;
  final Level level;
  final int weightKb;
  final int heightAthlete;
  final int weightAthlete;
  final double coeff;
  final EnergyBreakdown energy;
  final List<DateTime> splits;
  final int currentStation;
  final AthleteStatus status;
  final int? finalTimeMs;
  final double? officialScore;
  final int noCountEvents;
  final Uint8List? judgeSignature;
  final Uint8List? athleteSignature;

  // SPEC-KIT §5.2 — Champs plateforme (optionnels : mode juge sans compte fonctionne sans)
  final String? profileId;       // ID profil Supabase
  final double? coeffAge;        // coeff VO2max (AgeCategory)
  final double? coeffSexe;       // coeff sexe (Sex)
  final double? platformScore;   // finalTimeMs × coeffKb × coeffAge × coeffSexe

  // SPEC-KIT §7.1 — Phase 2.2 : lien vers wave_athletes (null = mode libre)
  final String? waveAthleteId;

  // SPEC-KIT §6.3 — Phase 3 : métriques cardiaques (null si pas de capteur BLE)
  final HrMetrics? hrMetrics;

  const Athlete({
    required this.id,
    required this.name,
    required this.level,
    required this.weightKb,
    required this.heightAthlete,
    required this.weightAthlete,
    required this.coeff,
    required this.energy,
    this.splits = const [],
    this.currentStation = 0,
    this.status = AthleteStatus.waiting,
    this.finalTimeMs,
    this.officialScore,
    this.noCountEvents = 0,
    this.judgeSignature,
    this.athleteSignature,
    this.profileId,
    this.coeffAge,
    this.coeffSexe,
    this.platformScore,
    this.waveAthleteId,
    this.hrMetrics,
  });

  Athlete copyWith({
    List<DateTime>? splits,
    int? currentStation,
    AthleteStatus? status,
    int? finalTimeMs,
    double? officialScore,
    double? platformScore,
    int? noCountEvents,
    Uint8List? judgeSignature,
    Uint8List? athleteSignature,
    HrMetrics? hrMetrics,
    bool clearFinalTime = false,
    bool clearOfficialScore = false,
  }) {
    return Athlete(
      id: id,
      name: name,
      level: level,
      weightKb: weightKb,
      heightAthlete: heightAthlete,
      weightAthlete: weightAthlete,
      coeff: coeff,
      energy: energy,
      splits: splits ?? this.splits,
      currentStation: currentStation ?? this.currentStation,
      status: status ?? this.status,
      finalTimeMs: clearFinalTime ? null : (finalTimeMs ?? this.finalTimeMs),
      officialScore:
          clearOfficialScore ? null : (officialScore ?? this.officialScore),
      platformScore: clearFinalTime ? null : (platformScore ?? this.platformScore),
      noCountEvents: noCountEvents ?? this.noCountEvents,
      judgeSignature: judgeSignature ?? this.judgeSignature,
      athleteSignature: athleteSignature ?? this.athleteSignature,
      profileId: profileId,
      coeffAge: coeffAge,
      coeffSexe: coeffSexe,
      waveAthleteId: waveAthleteId,
      hrMetrics: hrMetrics ?? this.hrMetrics,
    );
  }
}
