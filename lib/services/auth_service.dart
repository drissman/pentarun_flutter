// SPEC-KIT §3.1 — Service authentification Supabase
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pentarun_flutter/utils/web_redirect.dart';

class AuthService {
  AuthService._();

  static SupabaseClient get _client => Supabase.instance.client;

  // ─── Session ──────────────────────────────────────────────────────────────
  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;

  // ─── Email / Mot de passe ─────────────────────────────────────────────────
  // SPEC-KIT §3.1 — Inscription email
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return _client.auth.signUp(email: email, password: password);
  }

  // SPEC-KIT §3.1 — Connexion email
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  // ─── Google OAuth ─────────────────────────────────────────────────────────
  // SPEC-KIT §3.1 ERRATA v2.1 — window.location.href bypass popup blocker
  // url_launcher → window.open('noopener,noreferrer') est bloqué silencieusement
  // après les await PKCE (contexte user-activation expiré dans le browser).
  // Fix : getOAuthSignInUrl() construit l'URL localement (PKCE, pas de réseau),
  // puis webRedirect() navigue via window.location.href (non bloquable).
  static Future<void> signInWithGoogle() async {
    final res = await _client.auth.getOAuthSignInUrl(
      provider: OAuthProvider.google,
      redirectTo: 'https://pentarun.netlify.app',
    );
    webRedirect(res.url);
  }

  // ─── Déconnexion ──────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── Réinitialisation mot de passe ───────────────────────────────────────
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
