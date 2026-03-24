// SPEC-KIT §3.3 / §4.1 — Service profil athlète (Supabase)
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pentarun_flutter/models/athlete_profile.dart';

class ProfileService {
  ProfileService._();

  static SupabaseClient get _client => Supabase.instance.client;

  // ─── Lecture ──────────────────────────────────────────────────────────────

  /// Profil de l'utilisateur connecté
  static Future<AthleteProfile?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client
        .from('profiles')
        .select()
        .eq('auth_id', user.id)
        .maybeSingle();
    if (data == null) return null;
    return AthleteProfile.fromJson(data);
  }

  /// Recherche par nom/prénom (pour l'organisateur — setup_screen)
  static Future<List<AthleteProfile>> searchByName(String query) async {
    if (query.trim().length < 2) return [];
    final data = await _client
        .from('profiles')
        .select()
        .or('nom.ilike.%$query%,prenom.ilike.%$query%')
        .order('nom')
        .limit(10);
    return (data as List).map((e) => AthleteProfile.fromJson(e)).toList();
  }

  // ─── Écriture ─────────────────────────────────────────────────────────────

  /// Création du profil (première connexion)
  static Future<AthleteProfile> createProfile(AthleteProfile profile) async {
    final data = await _client
        .from('profiles')
        .insert(profile.toJson())
        .select()
        .single();
    return AthleteProfile.fromJson(data);
  }

  /// Mise à jour du profil
  static Future<AthleteProfile> updateProfile(AthleteProfile profile) async {
    final data = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();
    return AthleteProfile.fromJson(data);
  }
}
