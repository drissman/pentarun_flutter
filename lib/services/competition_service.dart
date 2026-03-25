// SPEC-KIT §7.1 — Phase 2.2 — Service compétitions et vagues
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pentarun_flutter/models/competition.dart';
import 'package:pentarun_flutter/models/wave.dart';
import 'package:pentarun_flutter/services/profile_service.dart';

class CompetitionService {
  CompetitionService._();

  static SupabaseClient get _client => Supabase.instance.client;

  // ─── Compétitions ──────────────────────────────────────────────────────────

  /// Crée une compétition pour l'utilisateur connecté
  static Future<Competition> createCompetition({
    required String nom,
    required String lieu,
    required DateTime dateEvent,
  }) async {
    final profile = await ProfileService.getCurrentProfile();
    if (profile == null) throw Exception('Profil introuvable');

    final data = await _client
        .from('competitions')
        .insert({
          'organizer_id': profile.id,
          'nom': nom.trim().toUpperCase(),
          'lieu': lieu.trim(),
          'date_event': dateEvent.toIso8601String().substring(0, 10),
        })
        .select()
        .single();
    return Competition.fromJson(data);
  }

  /// Compétitions de l'organisateur connecté
  static Future<List<Competition>> getMyCompetitions() async {
    final profile = await ProfileService.getCurrentProfile();
    if (profile == null) return [];

    final data = await _client
        .from('competitions')
        .select()
        .eq('organizer_id', profile.id)
        .order('date_event', ascending: false);
    return (data as List).map((e) => Competition.fromJson(e)).toList();
  }

  /// Compétitions actives (pour les spectateurs et les juges)
  static Future<List<Competition>> getActiveCompetitions() async {
    final data = await _client
        .from('competitions')
        .select()
        .eq('statut', 'en_cours')
        .order('date_event', ascending: false);
    return (data as List).map((e) => Competition.fromJson(e)).toList();
  }

  /// Met à jour le statut d'une compétition
  static Future<void> updateStatut(String id, String statut) async {
    await _client
        .from('competitions')
        .update({'statut': statut})
        .eq('id', id);
  }

  // ─── Vagues ────────────────────────────────────────────────────────────────

  /// Crée une vague dans une compétition
  static Future<Wave> createWave({
    required String competitionId,
    required int numero,
    required String niveau,
  }) async {
    final data = await _client
        .from('waves')
        .insert({
          'competition_id': competitionId,
          'numero': numero,
          'niveau': niveau,
        })
        .select()
        .single();
    return Wave.fromJson(data);
  }

  /// Vagues d'une compétition
  static Future<List<Wave>> getWaves(String competitionId) async {
    final data = await _client
        .from('waves')
        .select()
        .eq('competition_id', competitionId)
        .order('numero');
    return (data as List).map((e) => Wave.fromJson(e)).toList();
  }

  /// Met à jour le statut d'une vague
  static Future<void> updateWaveStatut(String waveId, String statut) async {
    final update = {'statut': statut};
    if (statut == 'en_cours') update['started_at'] = DateTime.now().toIso8601String();
    await _client.from('waves').update(update).eq('id', waveId);
  }

  /// Récupère une vague par son ID
  static Future<Wave?> getWave(String waveId) async {
    final data = await _client
        .from('waves')
        .select()
        .eq('id', waveId)
        .maybeSingle();
    if (data == null) return null;
    return Wave.fromJson(data);
  }
}
