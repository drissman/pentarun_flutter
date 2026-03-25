// SPEC-KIT §7.1 — Phase 2.2 — Modèle compétition

class Competition {
  final String id;
  final String organizerId;
  final String nom;
  final String lieu;
  final DateTime dateEvent;
  final String statut; // 'brouillon' | 'en_cours' | 'termine'
  final DateTime createdAt;

  const Competition({
    required this.id,
    required this.organizerId,
    required this.nom,
    required this.lieu,
    required this.dateEvent,
    required this.statut,
    required this.createdAt,
  });

  bool get isActive => statut == 'en_cours';
  bool get isDraft => statut == 'brouillon';
  bool get isFinished => statut == 'termine';

  factory Competition.fromJson(Map<String, dynamic> json) => Competition(
    id: json['id'] as String,
    organizerId: json['organizer_id'] as String,
    nom: json['nom'] as String,
    lieu: json['lieu'] as String,
    dateEvent: DateTime.parse(json['date_event'] as String),
    statut: json['statut'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'organizer_id': organizerId,
    'nom': nom,
    'lieu': lieu,
    'date_event': dateEvent.toIso8601String().substring(0, 10),
    'statut': statut,
  };

  Competition copyWith({String? statut}) => Competition(
    id: id,
    organizerId: organizerId,
    nom: nom,
    lieu: lieu,
    dateEvent: dateEvent,
    statut: statut ?? this.statut,
    createdAt: createdAt,
  );
}
