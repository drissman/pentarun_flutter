import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/energy_breakdown.dart';
import 'package:pentarun_flutter/models/hr_device.dart';
import 'package:pentarun_flutter/screens/competition_list_screen.dart';
import 'package:pentarun_flutter/screens/profile_screen.dart';
import 'package:pentarun_flutter/screens/wave_join_screen.dart';
import 'package:pentarun_flutter/services/cv_service.dart';
import 'package:pentarun_flutter/services/hr_session_service.dart';
import 'package:pentarun_flutter/services/profile_service.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';
import 'package:pentarun_flutter/widgets/athlete_form.dart';
import 'package:pentarun_flutter/widgets/athlete_setup_card.dart';

// ─── Prédicteur Énergétique ───────────────────────────────────────────────────

class _EnergyPredictorCard extends StatelessWidget {
  final EnergyBreakdown energy;

  const _EnergyPredictorCard({required this.energy});

  @override
  Widget build(BuildContext context) {
    final runFlex = (energy.run * 100 / energy.total).round().clamp(1, 98);
    final steelFlex = (energy.steel * 100 / energy.total).round().clamp(1, 97);
    final epocFlex = (100 - runFlex - steelFlex).clamp(1, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0900),
        border: Border.all(color: const Color(0xFF3A2800)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: A2Colors.ambre, size: 15),
              const SizedBox(width: 6),
              const Text(
                'PRÉDICTEUR ÉNERGÉTIQUE',
                style: TextStyle(
                  color: A2Colors.ambre,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                  ),
                  children: [
                    TextSpan(
                      text: energy.total.round().toString(),
                      style: const TextStyle(
                          fontSize: 20, color: A2Colors.ambre),
                    ),
                    const TextSpan(
                      text: ' KCAL',
                      style: TextStyle(fontSize: 10, color: A2Colors.gris1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barre segmentée
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 7,
              child: Row(
                children: [
                  Flexible(
                    flex: runFlex,
                    child: Container(color: A2Colors.cyan),
                  ),
                  Flexible(
                    flex: steelFlex,
                    child: Container(color: A2Colors.ambre),
                  ),
                  Flexible(
                    flex: epocFlex,
                    child: Container(color: A2Colors.vert),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _dot(A2Colors.cyan, 'Course ${energy.run.round()} kcal'),
              const SizedBox(width: 14),
              _dot(A2Colors.ambre, 'Acier ${energy.steel.round()} kcal'),
              const SizedBox(width: 14),
              _dot(A2Colors.vert, 'EPOC ×1.15'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: A2Colors.gris1,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  Future<void> _openProfile(BuildContext context) async {
    final profile = await ProfileService.getCurrentProfile();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfileScreen(existing: profile)),
    );
  }

  void _openCompetitions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CompetitionListScreen()),
    );
  }

  Future<void> _joinWave(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WaveJoinScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final athletes = state.athletes;
    final hasAthletes = athletes.isNotEmpty;

    final screenW = MediaQuery.of(context).size.width;
    final padding = (screenW * 0.04).clamp(10.0, 28.0);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Title
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monitor_heart, color: A2Colors.cyan, size: 24),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text(
                          'CONFIGURATION VAGUE',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: 19,
                            color: A2Colors.blanc,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_events_outlined, color: A2Colors.gris1),
                        tooltip: 'Mes compétitions',
                        onPressed: () => _openCompetitions(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle_outlined, color: A2Colors.gris1),
                        tooltip: 'Mon profil',
                        onPressed: () => _openProfile(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "PHASE 1 — LA CHAMBRE D'APPEL",
                    style: TextStyle(
                      color: A2Colors.gris1,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  const AthleteForm(),
                  const SizedBox(height: 16),

                  // Prédicteur énergétique
                  _EnergyPredictorCard(energy: state.formEnergy),
                  const SizedBox(height: 24),

                  // Athletes grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (!hasAthletes) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: A2Colors.border2,
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'AUCUN ATHLÈTE DANS LA VAGUE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: A2Colors.gris1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      final cols = constraints.maxWidth > 600 ? 2 : 1;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: athletes.map((a) {
                          return SizedBox(
                            width: (constraints.maxWidth - (cols - 1) * 12) / cols,
                            child: AthleteSetupCard(athlete: a),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // SPEC-KIT §6.2 — Phase 3 : Appairage capteur HR
                  const _HrPairingCard(),
                  const SizedBox(height: 16),

                  // SPEC-KIT §3.5.4 — Phase 3.5 : CV Assist (avant la course)
                  if (state.hasCvFeature) ...[
                    _CvSetupCard(state: state),
                    const SizedBox(height: 16),
                  ],

                  // Rejoindre vague connectée
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _joinWave(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: A2Colors.cyan,
                        side: const BorderSide(color: A2Colors.cyanDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.link, size: 18),
                      label: const Text(
                        'REJOINDRE UNE VAGUE CONNECTÉE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Start button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: hasAthletes ? () => state.startRacing() : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            hasAthletes ? A2Colors.vert : const Color(0xFF252525),
                        foregroundColor:
                            hasAthletes ? Colors.black : A2Colors.gris1,
                        disabledBackgroundColor: const Color(0xFF252525),
                        disabledForegroundColor: A2Colors.gris1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow, size: 26),
                      label: const Text(
                        'DÉMARRER LA VAGUE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

// ─── CV Assist Setup — Phase 3.5 ─────────────────────────────────────────────

class _CvSetupCard extends StatelessWidget {
  final AppState state;
  const _CvSetupCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final enabled = state.cvEnabled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: A2Colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
              ? A2Colors.vert.withValues(alpha: 0.5)
              : A2Colors.border2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.videocam_outlined,
                color: enabled ? A2Colors.vert : A2Colors.gris1, size: 18),
            const SizedBox(width: 8),
            Text(
              'CV ASSIST — COMPTAGE REPS',
              style: TextStyle(
                color: enabled ? A2Colors.vert : A2Colors.gris1,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            Switch(
              value: enabled,
              onChanged: (_) => state.toggleCv(),
              activeColor: A2Colors.vert,
            ),
          ]),
          if (enabled) ...[
            const SizedBox(height: 4),
            Text(
              '1 athlète max — caméra frontale face à l\'athlète',
              style: const TextStyle(
                  color: A2Colors.gris1, fontSize: 10),
            ),
            const SizedBox(height: 10),
            // Aperçu caméra
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: CvServiceImpl.instance.buildPreview(),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            const Text(
              'Activez avant la course pour compter les reps automatiquement.\n'
              'La caméra frontale détecte les mouvements kettlebell.',
              style: TextStyle(color: A2Colors.gris1, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Appairage Capteur HR — Phase 3 ──────────────────────────────────────────

class _HrPairingCard extends StatefulWidget {
  const _HrPairingCard();

  @override
  State<_HrPairingCard> createState() => _HrPairingCardState();
}

class _HrPairingCardState extends State<_HrPairingCard> {
  final _hr = HrSessionService.instance;
  List<HrDevice> _found = [];
  bool _scanning = false;
  bool _connecting = false;

  Future<void> _scan() async {
    if (!_hr.bleSupported || _scanning) return;
    setState(() { _scanning = true; _found = []; });
    await for (final devices in _hr.scan(timeout: const Duration(seconds: 5))) {
      if (mounted) setState(() => _found = devices);
    }
    if (mounted) setState(() => _scanning = false);
  }

  Future<void> _connect(HrDevice d) async {
    if (_connecting) return;
    setState(() => _connecting = true);
    try {
      await _hr.connect(d.id);
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _disconnect() async {
    await _hr.disconnect();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final connected = _hr.connected;
    final device = _hr.device;
    final supported = _hr.bleSupported;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: A2Colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: connected
              ? A2Colors.vert.withValues(alpha: 0.5)
              : supported
                  ? A2Colors.border2
                  : A2Colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(
              Icons.monitor_heart_outlined,
              color: connected ? A2Colors.vert : A2Colors.gris1,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'CAPTEUR CARDIO BLE',
              style: TextStyle(
                color: connected ? A2Colors.vert : A2Colors.gris1,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            // Badge statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (connected
                        ? A2Colors.vert
                        : supported
                            ? A2Colors.ambre
                            : A2Colors.border2)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (connected
                          ? A2Colors.vert
                          : supported
                              ? A2Colors.ambre
                              : A2Colors.border2)
                      .withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                connected
                    ? 'CONNECTÉ'
                    : supported
                        ? 'NATIF'
                        : 'WEB — NON DISPO',
                style: TextStyle(
                  color: connected
                      ? A2Colors.vert
                      : supported
                          ? A2Colors.ambre
                          : A2Colors.border2,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          if (!supported)
            // Message Web
            const Text(
              'BLE disponible uniquement sur l\'app mobile native.\n'
              'Compilez avec flutter build apk pour activer le capteur HR.',
              style: TextStyle(color: A2Colors.gris1, fontSize: 10),
            )
          else if (connected && device != null) ...[
            // Capteur connecté
            Text(device.name,
                style: const TextStyle(
                    color: A2Colors.blanc, fontWeight: FontWeight.w900, fontSize: 12)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _disconnect,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('DÉCONNECTER',
                    style: TextStyle(color: A2Colors.rouge, fontSize: 10,
                        fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ] else ...[
            // Scan + liste
            Row(children: [
              Expanded(
                child: _connecting
                    ? const Text('Connexion en cours...',
                        style: TextStyle(color: A2Colors.cyan, fontSize: 10))
                    : _found.isEmpty
                        ? Text(
                            _scanning ? 'Recherche en cours...' : 'Aucun capteur trouvé.',
                            style: const TextStyle(color: A2Colors.gris1, fontSize: 10))
                        : Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _found.map((d) => InkWell(
                              onTap: () => _connect(d),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: A2Colors.surface,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: A2Colors.cyan.withValues(alpha: 0.5)),
                                ),
                                child: Text(d.name,
                                    style: const TextStyle(
                                        color: A2Colors.cyan, fontSize: 10,
                                        fontWeight: FontWeight.w900)),
                              ),
                            )).toList(),
                          ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _scanning ? null : _scan,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: A2Colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: A2Colors.border2),
                  ),
                  child: _scanning
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              color: A2Colors.cyan, strokeWidth: 2))
                      : const Icon(Icons.bluetooth_searching, color: A2Colors.cyan, size: 18),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}
