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

  // Données profil complètes (présentes si SELECT *, profiles!inner(...))
  final int? poidsKg;
  final int? tailleCm;
  final double? coeffAge;   // calculé depuis date_naissance
  final double? coeffSexe;  // calculé depuis sexe

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
    this.poidsKg,
    this.tailleCm,
    this.coeffAge,
    this.coeffSexe,
  });

  bool get isRunning => statutAthlete == 'en_course';
  bool get isFinished => statutAthlete == 'termine';

  factory WaveAthlete.fromJson(Map<String, dynamic> json) {
    // Jointure profiles optionnelle : présente si SELECT *, profiles!inner(...)
    String? name;
    int? poids;
    int? taille;
    double? coeffAge;
    double? coeffSexe;

    final profileData = json['profiles'];
    if (profileData is Map<String, dynamic>) {
      final nom = profileData['nom'] as String? ?? '';
      final prenom = profileData['prenom'] as String? ?? '';
      name = '$prenom $nom'.trim().toUpperCase();
      poids = profileData['poids_kg'] as int?;
      taille = profileData['taille_cm'] as int?;

      // Calcul coeffAge depuis date_naissance
      if (profileData['date_naissance'] != null) {
        final dob = DateTime.parse(profileData['date_naissance'] as String);
        final age = DateTime.now().year - dob.year;
        coeffAge = _coeffAgeFromAge(age);
      }
      // Calcul coeffSexe depuis sexe
      final sexe = profileData['sexe'] as String?;
      coeffSexe = (sexe == 'FEMME') ? 0.870 : 1.000;
    } else if (json['display_name'] != null) {
      // SPEC-KIT §7.2 Sprint 5 — colonne dénormalisée (spectateur anonyme, pas de jointure profil)
      name = (json['display_name'] as String).toUpperCase();
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
      poidsKg: poids,
      tailleCm: taille,
      coeffAge: coeffAge,
      coeffSexe: coeffSexe,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'wave_id': waveId,
    'profile_id': profileId,
    'dossard': dossard,
    'kb_kg': kbKg,
  };

  // SPEC-KIT §5.4 §5.5 — coeff_age par tranche d'âge
  static double _coeffAgeFromAge(int age) {
    if (age < 18) return 0.980;
    if (age < 22) return 0.990;
    if (age < 40) return 1.000;
    if (age < 50) return 0.915;
    if (age < 60) return 0.855;
    return 0.775;
  }
}
