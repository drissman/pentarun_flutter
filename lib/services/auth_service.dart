// SPEC-KIT §3.1 — Service authentification Supabase
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  // SPEC-KIT §3.1 — Connexion Google (Flutter web)
  // url_launcher_web : seul LaunchMode.inAppBrowserView utilise window.open(url,'_self')
  // = même onglet, jamais bloqué par le popup blocker (contrairement à _blank)
  static Future<bool> signInWithGoogle() async {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'https://pentarun.netlify.app',
      authScreenLaunchMode: LaunchMode.inAppBrowserView,
    );
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
