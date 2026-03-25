// SPEC-KIT §7.1 — Phase 2.2 — Service athlètes dans une vague
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pentarun_flutter/models/athlete_profile.dart';
import 'package:pentarun_flutter/models/wave_athlete.dart';

class WaveService {
  WaveService._();

  static SupabaseClient get _client => Supabase.instance.client;

  // ─── Inscription ───────────────────────────────────────────────────────────

  /// Inscrit un athlète dans une vague
  static Future<WaveAthlete> enrollAthlete({
    required String waveId,
    required AthleteProfile profile,
    required int kbKg,
    int? dossard,
  }) async {
    final data = await _client
        .from('wave_athletes')
        .insert({
          'wave_id': waveId,
          'profile_id': profile.id,
          'kb_kg': kbKg,
          if (dossard != null) 'dossard': dossard,
          // SPEC-KIT §7.2 Sprint 5 — display_name dénormalisé pour accès spectateur anonyme
          'display_name': profile.displayName,
        })
        .select('*, profiles!inner(nom, prenom)')
        .single();
    return WaveAthlete.fromJson(data);
  }

  /// Récupère tous les athlètes d'une vague avec les infos profil complètes
  static Future<List<WaveAthlete>> getWaveAthletes(String waveId) async {
    final data = await _client
        .from('wave_athletes')
        .select('*, profiles!inner(nom, prenom, poids_kg, taille_cm, sexe, date_naissance)')
        .eq('wave_id', waveId)
        .order('dossard', nullsFirst: false)
        .order('created_at');
    return (data as List).map((e) => WaveAthlete.fromJson(e)).toList();
  }

  /// Récupère les athlètes sans jointure profil (spectateur anonyme)
  /// SPEC-KIT §7.2 Sprint 5 — utilise display_name dénormalisé
  static Future<List<WaveAthlete>> getWaveAthletesPublic(String waveId) async {
    final data = await _client
        .from('wave_athletes')
        .select()
        .eq('wave_id', waveId)
        .order('dossard', nullsFirst: false)
        .order('created_at');
    return (data as List).map((e) => WaveAthlete.fromJson(e)).toList();
  }

  /// Supprime un athlète d'une vague (avant démarrage)
  static Future<void> removeAthlete(String waveAthleteId) async {
    await _client.from('wave_athletes').delete().eq('id', waveAthleteId);
  }

  // ─── Progression live ──────────────────────────────────────────────────────

  /// Push la progression d'un athlète en temps réel
  /// SPEC-KIT §7.3 — Fire-and-forget : ne bloque jamais le chrono local
  static Future<void> pushProgress({
    required String waveAthleteId,
    required int stationActuelle,
    required List<int> splitsMs,
    required String statutAthlete,
    int noCountEvents = 0,
    int? finalTimeMs,
    double? officialScore,
    double? platformScore,
  }) async {
    await _client.from('wave_athletes').update({
      'station_actuelle': stationActuelle,
      'splits_ms': splitsMs,
      'statut_athlete': statutAthlete,
      'no_count_events': noCountEvents,
      if (finalTimeMs != null) 'final_time_ms': finalTimeMs,
      if (officialScore != null) 'official_score': officialScore,
      if (platformScore != null) 'platform_score': platformScore,
    }).eq('id', waveAthleteId);
  }
}
