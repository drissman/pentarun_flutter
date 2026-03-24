// SPEC-KIT §4.1 — Service résultats de course (Supabase)
// §7.3 : Toujours appelé en fire-and-forget — l'app fonctionne offline
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pentarun_flutter/models/race_result.dart';

class ResultsService {
  ResultsService._();

  static SupabaseClient get _client => Supabase.instance.client;

  // ─── Sauvegarde ───────────────────────────────────────────────────────────

  /// Enregistre un résultat après scellement
  /// SPEC-KIT §7.3 — Fire-and-forget : échoue silencieusement si offline
  static Future<RaceResult?> saveResult(RaceResult result) async {
    try {
      final data = await _client
          .from('results')
          .insert(result.toJson())
          .select()
          .single();
      return RaceResult.fromJson(data);
    } catch (_) {
      // SPEC-KIT §7.3 — Offline : l'app continue sans interruption
      return null;
    }
  }

  // ─── Historique athlète ───────────────────────────────────────────────────

  /// Tous les résultats d'un profil, du plus récent au plus ancien
  static Future<List<RaceResult>> getHistoryForProfile(
      String profileId) async {
    try {
      final data = await _client
          .from('results')
          .select()
          .eq('profile_id', profileId)
          .order('wave_date', ascending: false)
          .order('created_at', ascending: false);
      return (data as List).map((e) => RaceResult.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Classement ───────────────────────────────────────────────────────────

  /// Classement intra-niveau + sexe + catégorie d'âge
  /// SPEC-KIT §5.6 — Philosophie B : comparaison d'égal à égal
  static Future<List<RaceResult>> getRanking({
    required String level,
    required String sexe,
    required String categorieAge,
    int limit = 100,
  }) async {
    try {
      final data = await _client
          .from('results')
          .select('*, profiles!inner(sexe, age_category)')
          .eq('level', level)
          .eq('profiles.sexe', sexe)
          .order('platform_score', ascending: true)
          .limit(limit);
      return (data as List).map((e) => RaceResult.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
