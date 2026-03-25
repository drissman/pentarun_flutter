// SPEC-KIT §2 — Initialisation Supabase + routage auth-aware
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pentarun_flutter/app.dart';
import 'package:pentarun_flutter/config/supabase_config.dart';
import 'package:pentarun_flutter/models/athlete_profile.dart';
import 'package:pentarun_flutter/screens/auth_screen.dart';
import 'package:pentarun_flutter/screens/profile_screen.dart';
import 'package:pentarun_flutter/screens/spectator_screen.dart';
import 'package:pentarun_flutter/services/profile_service.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_theme.dart';
import 'package:pentarun_flutter/utils/web_gotrue_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    // SPEC-KIT §3.1 ERRATA v2.1 — WebGotrueAsyncStorage remplace
    // SharedPreferencesGotrueAsyncStorage qui hang sur Flutter Web.
    // localStorage JS est synchrone → jamais bloqué. PKCE conservé pour
    // la récupération de session correcte (?code= → exchangeCodeForSession).
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        pkceAsyncStorage: WebGotrueAsyncStorage(),
      ),
    );
    // SPEC-KIT §3.1 ERRATA v2.1 — Échange explicite du code PKCE OAuth
    // supabase_flutter._handleInitialUri() devrait détecter ?code= automatiquement
    // via app_links, mais échoue parfois (timing ou parsing). On l'échange manuellement
    // avant runApp pour garantir que la session existe dès le premier build de _AuthGate.
    if (kIsWeb) {
      final code = Uri.base.queryParameters['code'];
      if (code != null) {
        try {
          await Supabase.instance.client.auth.exchangeCodeForSession(code);
        } catch (_) {
          // Code déjà échangé ou expiré — ignorer
        }
      }
    }
  }

  // SPEC-KIT §7.2 Sprint 5 — Route spectateur : /#/live/{competitionId}
  // Détecté avant runApp → bypass complet de l'AuthGate
  String? spectatorCompetitionId;
  if (kIsWeb) {
    final fragment = Uri.base.fragment; // ex: '/live/abc-123-def'
    if (fragment.startsWith('/live/')) {
      final id = fragment.substring('/live/'.length).trim();
      if (id.isNotEmpty) spectatorCompetitionId = id;
    }
  }

  runApp(PentarunRoot(spectatorCompetitionId: spectatorCompetitionId));
}

class PentarunRoot extends StatefulWidget {
  final String? spectatorCompetitionId;
  const PentarunRoot({super.key, this.spectatorCompetitionId});

  @override
  State<PentarunRoot> createState() => _PentarunRootState();
}

class _PentarunRootState extends State<PentarunRoot> {
  final _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: _appState,
      child: MaterialApp(
        title: 'PENTARUN v2.0',
        debugShowCheckedModeBanner: false,
        theme: A2Theme.dark,
        // SPEC-KIT §7.2 Sprint 5 — Route spectateur bypass AuthGate
        home: widget.spectatorCompetitionId != null
            ? SpectatorScreen(competitionId: widget.spectatorCompetitionId!)
            : SupabaseConfig.isConfigured
                ? const _AuthGate()
                : const Scaffold(body: PentarunApp()),
      ),
    );
  }
}

// ─── Auth Gate ────────────────────────────────────────────────────────────────
// SPEC-KIT §3.1/§3.2 — AuthScreen → ProfileScreen (1re connexion) → PentarunApp

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _loading = true;
  bool _judgeMode = false;
  User? _user;
  AthleteProfile? _profile;

  @override
  void initState() {
    super.initState();
    _init();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      final user = data.session?.user;
      if (user == null) {
        if (mounted) setState(() { _user = null; _profile = null; _loading = false; });
      } else {
        // Future.delayed(zero) brise le deadlock potentiel :
        // supabase_flutter émet onAuthStateChange de façon synchrone pendant
        // signUp/signIn — si on appelle getCurrentProfile() immédiatement,
        // le client interne est encore verrouillé → hang infini.
        Future.delayed(Duration.zero, () async {
          if (!mounted) return;
          try {
            final p = await ProfileService.getCurrentProfile();
            if (mounted) setState(() { _user = user; _profile = p; _loading = false; });
          } catch (_) {
            if (mounted) setState(() { _user = user; _profile = null; _loading = false; });
          }
        });
      }
    });
  }

  Future<void> _init() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      _user = session.user;
      final p = await ProfileService.getCurrentProfile();
      if (mounted) setState(() { _profile = p; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _enterJudgeMode() {
    setState(() => _judgeMode = true);
  }

  void _onProfileSaved() async {
    try {
      final p = await ProfileService.getCurrentProfile();
      if (mounted) setState(() => _profile = p);
    } catch (_) {
      // Profile saved but query failed — go to app anyway
      if (mounted) setState(() => _profile = AthleteProfile.empty());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mode juge — bypass auth
    if (_judgeMode) return const Scaffold(body: PentarunApp());

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
      );
    }
    if (_user == null) {
      return AuthScreen(onJudgeModeSelected: _enterJudgeMode);
    }
    if (_profile == null) {
      return ProfileScreen(onSaved: _onProfileSaved);
    }
    return const Scaffold(body: PentarunApp());
  }
}
