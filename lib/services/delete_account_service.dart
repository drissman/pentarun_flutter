// SPEC-KIT §3.4 — Suppression compte athlète via Edge Function
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteAccountService {
  DeleteAccountService._();

  static SupabaseClient get _client => Supabase.instance.client;

  /// Supprime le compte connecté (profil + résultats en cascade)
  /// via la Edge Function delete-account (service_role requis côté serveur).
  static Future<void> deleteAccount() async {
    await _client.functions.invoke('delete-account', method: HttpMethod.post);
    await _client.auth.signOut();
  }
}
