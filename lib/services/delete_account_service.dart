// SPEC-KIT §3.4 — Suppression compte athlète via Edge Function
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteAccountService {
  DeleteAccountService._();

  static SupabaseClient get _client => Supabase.instance.client;

  /// Supprime le compte connecté (profil + résultats en cascade)
  /// via la Edge Function delete-account (service_role requis côté serveur).
  /// SignOutScope.local : évite l'appel réseau signOut (user déjà supprimé).
  static Future<void> deleteAccount() async {
    await _client.functions
        .invoke('delete-account', method: HttpMethod.post)
        .timeout(const Duration(seconds: 10));
    // L'utilisateur est supprimé côté serveur — on efface la session locale
    // sans appel réseau (scope.local) pour éviter un hang sur /auth/v1/logout.
    await _client.auth.signOut(scope: SignOutScope.local);
  }
}
