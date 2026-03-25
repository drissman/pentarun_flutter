// SPEC-KIT §7.1 — Phase 2.2 Sprint 3 — Juge rejoint une vague connectée
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/engine/energy_calculator.dart';
import 'package:pentarun_flutter/models/competition.dart';
import 'package:pentarun_flutter/models/kettlebell.dart';
import 'package:pentarun_flutter/models/wave.dart';
import 'package:pentarun_flutter/models/wave_athlete.dart';
import 'package:pentarun_flutter/services/competition_service.dart';
import 'package:pentarun_flutter/services/wave_service.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class WaveJoinScreen extends StatefulWidget {
  const WaveJoinScreen({super.key});

  @override
  State<WaveJoinScreen> createState() => _WaveJoinScreenState();
}

class _WaveJoinScreenState extends State<WaveJoinScreen> {
  List<Competition> _competitions = [];
  Competition? _selectedComp;
  List<Wave> _waves = [];
  Wave? _selectedWave;
  List<WaveAthlete> _athletes = [];

  bool _loadingComps = true;
  bool _loadingWaves = false;
  bool _loadingAthletes = false;
  bool _starting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompetitions();
  }

  Future<void> _loadCompetitions() async {
    setState(() { _loadingComps = true; _error = null; });
    try {
      final data = await CompetitionService.getActiveCompetitions();
      if (mounted) setState(() { _competitions = data; _loadingComps = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loadingComps = false; });
    }
  }

  Future<void> _selectCompetition(Competition comp) async {
    setState(() {
      _selectedComp = comp;
      _selectedWave = null;
      _athletes = [];
      _loadingWaves = true;
      _error = null;
    });
    try {
      final data = await CompetitionService.getWaves(comp.id);
      if (mounted) setState(() { _waves = data; _loadingWaves = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loadingWaves = false; });
    }
  }

  Future<void> _selectWave(Wave wave) async {
    setState(() {
      _selectedWave = wave;
      _athletes = [];
      _loadingAthletes = true;
      _error = null;
    });
    try {
      final data = await WaveService.getWaveAthletes(wave.id);
      if (mounted) setState(() { _athletes = data; _loadingAthletes = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loadingAthletes = false; });
    }
  }

  Future<void> _startWave() async {
    if (_selectedWave == null || _athletes.isEmpty) return;
    setState(() { _starting = true; _error = null; });

    try {
      // Marque la vague comme en_cours dans Supabase
      await CompetitionService.updateWaveStatut(_selectedWave!.id, 'en_cours');

      final state = AppStateProvider.of(context);
      state.resetAll();
      state.setCompetitionContext(_selectedComp!.id, _selectedWave!.id);

      // Charge les athlètes pré-inscrits dans AppState
      for (final wa in _athletes) {
        final energy = EnergyCalculator.calculate(
          weightAthleteKg: wa.poidsKg ?? 75,
          heightAthleteCm: wa.tailleCm ?? 175,
          weightKbKg: wa.kbKg,
          level: _selectedWave!.niveau,
        );
        state.addAthleteFromWave(
          waveAthleteId: wa.id,
          name: wa.displayName ?? wa.profileId.substring(0, 8).toUpperCase(),
          level: _selectedWave!.niveau,
          kbKg: wa.kbKg,
          heightCm: wa.tailleCm ?? 175,
          weightKg: wa.poidsKg ?? 75,
          coeffKb: Kettlebell.coeffFor(wa.kbKg),
          energy: energy,
          profileId: wa.profileId,
          coeffAge: wa.coeffAge,
          coeffSexe: wa.coeffSexe,
        );
      }

      state.startRacing();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _starting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: A2Colors.bg,
      appBar: AppBar(
        backgroundColor: A2Colors.card,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: A2Colors.gris1),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'REJOINDRE UNE VAGUE',
          style: TextStyle(
            color: A2Colors.blanc, fontWeight: FontWeight.w900,
            letterSpacing: 1.5, fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Étape 1 : Choisir la compétition ──
              _stepHeader('1', 'COMPÉTITION EN COURS', _selectedComp != null),

              if (_loadingComps)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: A2Colors.cyan, strokeWidth: 2),
                ))
              else if (_competitions.isEmpty)
                _emptyCard('Aucune compétition en cours actuellement.')
              else
                ..._competitions.map((c) => _selectCard(
                  label: c.nom,
                  sub: '${c.lieu} · ${c.dateEvent.day.toString().padLeft(2,'0')}/${c.dateEvent.month.toString().padLeft(2,'0')}/${c.dateEvent.year}',
                  selected: _selectedComp?.id == c.id,
                  onTap: () => _selectCompetition(c),
                )),

              const SizedBox(height: 24),

              // ── Étape 2 : Choisir la vague ──
              _stepHeader('2', 'MA VAGUE', _selectedWave != null,
                  disabled: _selectedComp == null),

              if (_selectedComp != null) ...[
                if (_loadingWaves)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: A2Colors.cyan, strokeWidth: 2),
                  ))
                else if (_waves.isEmpty)
                  _emptyCard('Aucune vague dans cette compétition.')
                else
                  ..._waves.where((w) => !w.isFinished).map((w) => _selectCard(
                    label: 'VAGUE ${w.numero}',
                    sub: w.niveau.label,
                    selected: _selectedWave?.id == w.id,
                    badge: w.isRunning ? 'EN COURS' : 'ATTENTE',
                    badgeColor: w.isRunning ? A2Colors.rouge : A2Colors.ambre,
                    onTap: () => _selectWave(w),
                  )),
              ],

              const SizedBox(height: 24),

              // ── Étape 3 : Athlètes pré-inscrits ──
              _stepHeader('3', 'ATHLÈTES INSCRITS', false,
                  disabled: _selectedWave == null),

              if (_selectedWave != null) ...[
                if (_loadingAthletes)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: A2Colors.cyan, strokeWidth: 2),
                  ))
                else if (_athletes.isEmpty)
                  _emptyCard('Aucun athlète inscrit dans cette vague.')
                else
                  Container(
                    decoration: BoxDecoration(
                      color: A2Colors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: A2Colors.border2),
                    ),
                    child: Column(
                      children: _athletes.asMap().entries.map((entry) {
                        final i = entry.key;
                        final wa = entry.value;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                      color: A2Colors.cyanDark.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(color: A2Colors.cyan,
                                          fontWeight: FontWeight.w900, fontSize: 11),
                                    )),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(
                                    wa.displayName ?? '—',
                                    style: const TextStyle(color: A2Colors.blanc,
                                        fontWeight: FontWeight.w700, fontSize: 13),
                                  )),
                                  Text('${wa.kbKg} kg',
                                      style: const TextStyle(color: A2Colors.ambre,
                                          fontWeight: FontWeight.w900, fontSize: 12)),
                                ],
                              ),
                            ),
                            if (i < _athletes.length - 1)
                              const Divider(color: A2Colors.border, height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],

              const SizedBox(height: 32),

              if (_error != null) ...[
                Text(_error!, style: const TextStyle(
                  color: A2Colors.rouge, fontSize: 11, fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 16),
              ],

              // ── Bouton démarrer ──
              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: (_selectedWave != null && _athletes.isNotEmpty && !_starting)
                      ? _startWave
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: A2Colors.vert,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: A2Colors.surface,
                    disabledForegroundColor: A2Colors.gris1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _starting
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Icon(Icons.play_arrow, size: 26),
                  label: Text(
                    _starting ? 'DÉMARRAGE...' : 'DÉMARRER LA VAGUE',
                    style: const TextStyle(fontWeight: FontWeight.w900,
                        fontSize: 16, letterSpacing: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepHeader(String num, String label, bool done, {bool disabled = false}) {
    final color = disabled ? A2Colors.gris2 : done ? A2Colors.vert : A2Colors.cyan;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Center(child: done
                ? Icon(Icons.check, color: color, size: 14)
                : Text(num, style: TextStyle(color: color,
                    fontWeight: FontWeight.w900, fontSize: 11))),
          ),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(
            color: disabled ? A2Colors.gris2 : A2Colors.gris1,
            fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2,
          )),
        ],
      ),
    );
  }

  Widget _selectCard({
    required String label,
    required String sub,
    required bool selected,
    required VoidCallback onTap,
    String? badge,
    Color badgeColor = A2Colors.ambre,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? A2Colors.cyanDark.withValues(alpha: 0.12) : A2Colors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? A2Colors.cyan : A2Colors.border2,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                    color: selected ? A2Colors.cyan : A2Colors.blanc,
                    fontWeight: FontWeight.w900, fontSize: 13,
                  )),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(color: A2Colors.gris1, fontSize: 11)),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(badge, style: TextStyle(
                  color: badgeColor, fontSize: 9,
                  fontWeight: FontWeight.w900, letterSpacing: 1,
                )),
              ),
            const SizedBox(width: 8),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? A2Colors.cyan : A2Colors.gris1, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(String msg) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: A2Colors.card,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: A2Colors.border2),
    ),
    child: Text(msg, style: const TextStyle(color: A2Colors.gris1, fontSize: 11)),
  );
}
