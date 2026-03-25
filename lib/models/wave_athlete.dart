// SPEC-KIT §7.1 — Phase 2.2 — Athlète inscrit dans une vague (état live)

class WaveAthlete {
  final String id;
  final String waveId;
  final String profileId;
  final String? displayName;      // depuis jointure profiles (nom + prenom)
  final int? dossard;
  final int kbKg;
  final int stationActuelle;
  final List<int> splitsMs;
  final int noCountEvents;
  final String statutAthlete;     // 'attente' | 'en_course' | 'termine' | 'dnf'
  final int? finalTimeMs;
  final double? officialScore;
  final double? platformScore;
  final DateTime createdAt;

  const WaveAthlete({
    required this.id,
    required this.waveId,
    required this.profileId,
    this.displayName,
    this.dossard,
    required this.kbKg,
    this.stationActuelle = 0,
    this.splitsMs = const [],
    this.noCountEvents = 0,
    this.statutAthlete = 'attente',
    this.finalTimeMs,
    this.officialScore,
    this.platformScore,
    required this.createdAt,
  });

  bool get isRunning => statutAthlete == 'en_course';
  bool get isFinished => statutAthlete == 'termine';

  factory WaveAthlete.fromJson(Map<String, dynamic> json) {
    // Jointure profiles optionnelle : présente si SELECT *, profiles!inner(...)
    String? name;
    final profileData = json['profiles'];
    if (profileData is Map<String, dynamic>) {
      final nom = profileData['nom'] as String? ?? '';
      final prenom = profileData['prenom'] as String? ?? '';
      name = '$prenom $nom'.trim().toUpperCase();
    }

    return WaveAthlete(
      id: json['id'] as String,
      waveId: json['wave_id'] as String,
      profileId: json['profile_id'] as String,
      displayName: name,
      dossard: json['dossard'] as int?,
      kbKg: json['kb_kg'] as int,
      stationActuelle: json['station_actuelle'] as int? ?? 0,
      splitsMs: (json['splits_ms'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      noCountEvents: json['no_count_events'] as int? ?? 0,
      statutAthlete: json['statut_athlete'] as String? ?? 'attente',
      finalTimeMs: json['final_time_ms'] as int?,
      officialScore: (json['official_score'] as num?)?.toDouble(),
      platformScore: (json['platform_score'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'wave_id': waveId,
    'profile_id': profileId,
    'dossard': dossard,
    'kb_kg': kbKg,
  };
}
