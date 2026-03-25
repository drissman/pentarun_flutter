// SPEC-KIT §7.1 — Phase 2.2 — Modèle vague de compétition
import 'package:pentarun_flutter/models/level.dart';

class Wave {
  final String id;
  final String competitionId;
  final int numero;
  final Level niveau;
  final String statut; // 'attente' | 'en_cours' | 'terminee'
  final DateTime? startedAt;
  final DateTime createdAt;

  const Wave({
    required this.id,
    required this.competitionId,
    required this.numero,
    required this.niveau,
    required this.statut,
    this.startedAt,
    required this.createdAt,
  });

  bool get isWaiting => statut == 'attente';
  bool get isRunning => statut == 'en_cours';
  bool get isFinished => statut == 'terminee';

  factory Wave.fromJson(Map<String, dynamic> json) => Wave(
    id: json['id'] as String,
    competitionId: json['competition_id'] as String,
    numero: json['numero'] as int,
    niveau: Level.fromLabel(json['niveau'] as String),
    statut: json['statut'] as String,
    startedAt: json['started_at'] != null
        ? DateTime.parse(json['started_at'] as String)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'competition_id': competitionId,
    'numero': numero,
    'niveau': niveau.label,
    'statut': statut,
  };

  Wave copyWith({String? statut, DateTime? startedAt}) => Wave(
    id: id,
    competitionId: competitionId,
    numero: numero,
    niveau: niveau,
    statut: statut ?? this.statut,
    startedAt: startedAt ?? this.startedAt,
    createdAt: createdAt,
  );
}
