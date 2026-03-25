// SPEC-KIT §3.1 — Écran authentification (email + Google OAuth)
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/services/auth_service.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onJudgeModeSelected;
  const AuthScreen({super.key, this.onJudgeModeSelected});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; _info = null; });
    try {
      if (_isLogin) {
        final res = await AuthService.signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
        if (res.session == null && mounted) {
          setState(() => _error = 'Connexion échouée. Vérifiez vos identifiants.');
        }
      } else {
        final res = await AuthService.signUpWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
        // Si pas de session → email de confirmation requis
        if (res.session == null && mounted) {
          setState(() => _info =
              'Email envoyé ! Confirmez votre adresse mail puis reconnectez-vous.');
        }
        // Si session → onAuthStateChange gère la navigation automatiquement
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.signInWithGoogle();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: A2Colors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // Logo / titre
                const Icon(Icons.monitor_heart, color: A2Colors.cyan, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'PENTARUN',
                  style: TextStyle(
                    color: A2Colors.blanc,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'PLATEFORME COMPÉTITIVE',
                  style: TextStyle(
                    color: A2Colors.gris1,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 48),

                // Card auth
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: A2Colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: A2Colors.border2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Toggle login / inscription
                      Row(
                        children: [
                          _tab('CONNEXION', _isLogin, () => setState(() => _isLogin = true)),
                          const SizedBox(width: 8),
                          _tab('INSCRIPTION', !_isLogin, () => setState(() => _isLogin = false)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Email
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: A2Colors.blanc),
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 16),

                      // Mot de passe
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        style: const TextStyle(color: A2Colors.blanc),
                        decoration: const InputDecoration(labelText: 'Mot de passe'),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 8),

                      // Info (ex: email de confirmation envoyé)
                      if (_info != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _info!,
                          style: const TextStyle(
                            color: A2Colors.vert, // SPEC-KIT §5.3 — A2Colors obligatoire
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      // Erreur
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: A2Colors.rouge,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Bouton principal
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black, strokeWidth: 2))
                              : Text(
                                  _isLogin ? 'SE CONNECTER' : 'CRÉER MON COMPTE',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Séparateur
                      Row(
                        children: [
                          const Expanded(child: Divider(color: A2Colors.border2)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OU', style: TextStyle(
                              color: A2Colors.gris1, fontSize: 10,
                              fontWeight: FontWeight.w700, letterSpacing: 2)),
                          ),
                          const Expanded(child: Divider(color: A2Colors.border2)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google OAuth
                      SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _googleSignIn,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: A2Colors.blanc,
                            side: const BorderSide(color: A2Colors.border2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.g_mobiledata, size: 22),
                          label: const Text(
                            'CONTINUER AVEC GOOGLE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Mode juge sans compte
                const SizedBox(height: 24),
                TextButton(
                  onPressed: widget.onJudgeModeSelected,
                  child: Text(
                    'CONTINUER SANS COMPTE (MODE JUGE)',
                    style: TextStyle(
                      color: widget.onJudgeModeSelected != null
                          ? A2Colors.gris1
                          : A2Colors.border2,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? A2Colors.cyanDark : A2Colors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.black : A2Colors.gris1,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
