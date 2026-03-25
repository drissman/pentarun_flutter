// SPEC-KIT §7.2 — Phase 2.2 Sprint 4 — Vue directeur : toutes les vagues en temps réel
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pentarun_flutter/models/competition.dart';
import 'package:pentarun_flutter/models/station.dart';
import 'package:pentarun_flutter/models/wave.dart';
import 'package:pentarun_flutter/models/wave_athlete.dart';
import 'package:pentarun_flutter/services/competition_service.dart';
import 'package:pentarun_flutter/services/realtime_service.dart';
import 'package:pentarun_flutter/services/wave_service.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';
import 'package:pentarun_flutter/utils/time_formatter.dart';

class DirectorScreen extends StatefulWidget {
  final Competition competition;
  const DirectorScreen({super.key, required this.competition});

  @override
  State<DirectorScreen> createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen>
    with SingleTickerProviderStateMixin {
  // Données live
  final Map<String, Wave> _waves = {};                          // waveId → Wave
  final Map<String, List<WaveAthlete>> _athletesByWave = {};   // waveId → athletes
  final Map<String, DateTime> _waveStartTimes = {};            // waveId → startedAt

  bool _loading = true;
  late Ticker _ticker;
  int _tickMs = 0; // force rebuild du ticker pour les chronos live

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => setState(() => _tickMs++));
    _ticker.start();
    _loadAll();
  }

  @override
  void dispose() {
    _ticker.dispose();
    // Désabonne tous les channels de cette compétition
    for (final waveId in _waves.keys) {
      RealtimeService.unsubscribe('wave:$waveId');
    }
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final waves = await CompetitionService.getWaves(widget.competition.id);

      // Charge les athlètes de toutes les vagues en parallèle
      final futures = waves.map((w) => WaveService.getWaveAthletes(w.id));
      final results = await Future.wait(futures);

      for (var i = 0; i < waves.length; i++) {
        final w = waves[i];
        _waves[w.id] = w;
        _athletesByWave[w.id] = results[i];
        if (w.startedAt != null) _waveStartTimes[w.id] = w.startedAt!;
      }

      // Abonne chaque vague au Realtime
      for (final w in waves) {
        _subscribeWave(w.id);
      }

      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _subscribeWave(String waveId) {
    RealtimeService.subscribeToWave(
      waveId,
      onAthleteUpdated: (updated) {
        if (!mounted) return;
        setState(() {
          final list = _athletesByWave[waveId] ?? [];
          final idx = list.indexWhere((a) => a.id == updated.id);
          if (idx >= 0) {
            list[idx] = updated;
          } else {
            list.add(updated);
          }
          _athletesByWave[waveId] = list;
        });
      },
      onWaveUpdated: (updated) {
        if (!mounted) return;
        setState(() {
          _waves[waveId] = updated;
          if (updated.startedAt != null) {
            _waveStartTimes[waveId] = updated.startedAt!;
          }
        });
      },
    );
  }

  // Chrono live d'une vague
  String _elapsedFor(String waveId) {
    final wave = _waves[waveId];
    if (wave == null || !wave.isRunning) return '—';
    final start = _waveStartTimes[waveId];
    if (start == null) return '—';
    return TimeFormatter.format(DateTime.now().difference(start).inMilliseconds);
  }

  // Compte athlètes terminés dans une vague
  int _finishedCount(String waveId) =>
      (_athletesByWave[waveId] ?? []).where((a) => a.isFinished).length;

  int _totalCount(String waveId) => (_athletesByWave[waveId] ?? []).length;

  @override
  Widget build(BuildContext context) {
    final sortedWaves = _waves.values.toList()
      ..sort((a, b) => a.numero.compareTo(b.numero));

    return Scaffold(
      backgroundColor: A2Colors.bg,
      appBar: AppBar(
        backgroundColor: A2Colors.card,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: A2Colors.gris1),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.competition.nom,
                style: const TextStyle(color: A2Colors.blanc,
                    fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
            const Text('VUE DIRECTEUR',
                style: TextStyle(color: A2Colors.cyan, fontSize: 9,
                    fontWeight: FontWeight.w900, letterSpacing: 2)),
          ],
        ),
        actions: [
          // Indicateur live
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(),
                const SizedBox(width: 6),
                const Text('LIVE', style: TextStyle(
                  color: A2Colors.rouge, fontSize: 10,
                  fontWeight: FontWeight.w900, letterSpacing: 2,
                )),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: A2Colors.cyan))
          : sortedWaves.isEmpty
              ? const Center(child: Text('Aucune vague',
                  style: TextStyle(color: A2Colors.gris1, fontSize: 12)))
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  color: A2Colors.cyan,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 1100 ? 3
                          : constraints.maxWidth > 680 ? 2 : 1;
                      final spacing = 12.0;
                      final cardW = (constraints.maxWidth - spacing * (cols + 1)) / cols;

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(spacing),
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: sortedWaves.map((w) => SizedBox(
                            width: cardW,
                            child: _WavePanel(
                              wave: w,
                              athletes: _athletesByWave[w.id] ?? [],
                              elapsed: _elapsedFor(w.id),
                              finished: _finishedCount(w.id),
                              total: _totalCount(w.id),
                            ),
                          )).toList(),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─── Panneau d'une vague ─────────────────────────────────────────────────────

class _WavePanel extends StatelessWidget {
  final Wave wave;
  final List<WaveAthlete> athletes;
  final String elapsed;
  final int finished;
  final int total;

  const _WavePanel({
    required this.wave,
    required this.athletes,
    required this.elapsed,
    required this.finished,
    required this.total,
  });

  Color get _statusColor => wave.isRunning
      ? A2Colors.rouge
      : wave.isFinished
          ? A2Colors.vert
          : A2Colors.ambre;

  String get _statusLabel => wave.isRunning
      ? 'EN COURS'
      : wave.isFinished
          ? 'TERMINÉE'
          : 'ATTENTE';

  @override
  Widget build(BuildContext context) {
    // Classement provisoire : athlètes terminés triés par officialScore ASC
    final finished = athletes.where((a) => a.isFinished).toList()
      ..sort((a, b) => (a.officialScore ?? double.maxFinite)
          .compareTo(b.officialScore ?? double.maxFinite));
    final running = athletes.where((a) => a.statutAthlete == 'en_course').toList()
      ..sort((a, b) => b.stationActuelle.compareTo(a.stationActuelle));
    final waiting = athletes.where((a) => a.statutAthlete == 'attente').toList();
    final ordered = [...finished, ...running, ...waiting];

    return Container(
      decoration: BoxDecoration(
        color: A2Colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: wave.isRunning ? A2Colors.rouge.withValues(alpha: 0.4) : A2Colors.border2,
          width: wave.isRunning ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header vague ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: A2Colors.surfaceDark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                // Numéro
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text('${wave.numero}', style: TextStyle(
                    color: _statusColor, fontWeight: FontWeight.w900, fontSize: 14,
                  ))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VAGUE ${wave.numero}',
                          style: const TextStyle(color: A2Colors.blanc,
                              fontWeight: FontWeight.w900, fontSize: 13)),
                      Text(wave.niveau.label,
                          style: const TextStyle(color: A2Colors.gris1, fontSize: 10)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(_statusLabel, style: TextStyle(
                        color: _statusColor, fontSize: 8,
                        fontWeight: FontWeight.w900, letterSpacing: 1,
                      )),
                    ),
                    const SizedBox(height: 4),
                    Text('$finished/$total',
                        style: const TextStyle(color: A2Colors.gris1, fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),

          // ── Chrono live ──
          if (wave.isRunning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: A2Colors.rouge.withValues(alpha: 0.06),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: A2Colors.rouge, size: 13),
                  const SizedBox(width: 6),
                  Text(elapsed, style: const TextStyle(
                    color: A2Colors.rouge, fontWeight: FontWeight.w900,
                    fontSize: 16, fontFamily: 'monospace', letterSpacing: 1,
                  )),
                ],
              ),
            ),

          // ── Athlètes ──
          if (ordered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aucun athlète inscrit',
                  style: TextStyle(color: A2Colors.gris1, fontSize: 11)),
            )
          else
            ...ordered.asMap().entries.map((entry) {
              final rank = entry.key;
              final a = entry.value;
              return Column(
                children: [
                  const Divider(color: A2Colors.border, height: 1),
                  _AthleteRow(athlete: a, rank: rank + 1),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ─── Ligne athlète ────────────────────────────────────────────────────────────

class _AthleteRow extends StatelessWidget {
  final WaveAthlete athlete;
  final int rank;
  const _AthleteRow({required this.athlete, required this.rank});

  @override
  Widget build(BuildContext context) {
    final isFinished = athlete.isFinished;
    final isRunning = athlete.isRunning;
    final stationsDone = athlete.stationActuelle.clamp(0, Station.count);

    Color rowColor = Colors.transparent;
    if (isFinished && rank == 1) rowColor = A2Colors.ambre.withValues(alpha: 0.05);
    if (isRunning) rowColor = A2Colors.cyan.withValues(alpha: 0.04);

    return Container(
      color: rowColor,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Rang / statut
          SizedBox(
            width: 22,
            child: isFinished
                ? Text('$rank', style: TextStyle(
                    color: rank == 1 ? A2Colors.ambre
                        : rank == 2 ? A2Colors.argent
                        : rank == 3 ? A2Colors.bronze
                        : A2Colors.gris1,
                    fontWeight: FontWeight.w900, fontSize: 12,
                  ))
                : isRunning
                    ? const Icon(Icons.arrow_forward, color: A2Colors.cyan, size: 14)
                    : const Icon(Icons.hourglass_empty, color: A2Colors.gris1, size: 12),
          ),
          const SizedBox(width: 8),

          // Nom + barre de progression
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  athlete.displayName ?? '—',
                  style: TextStyle(
                    color: isFinished ? A2Colors.blanc : isRunning ? A2Colors.cyan : A2Colors.gris1,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                // Barre stations
                Row(
                  children: List.generate(Station.count, (i) {
                    final done = i < stationsDone;
                    final current = i == stationsDone && isRunning;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i < Station.count - 1 ? 2 : 0),
                        decoration: BoxDecoration(
                          color: done
                              ? A2Colors.vert
                              : current
                                  ? A2Colors.cyan
                                  : A2Colors.border2,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Temps final ou station courante
          if (isFinished)
            Text(
              TimeFormatter.format(athlete.finalTimeMs),
              style: const TextStyle(
                color: A2Colors.vert, fontWeight: FontWeight.w900,
                fontSize: 11, fontFamily: 'monospace',
              ),
            )
          else if (isRunning)
            Text(
              'S${stationsDone + 1}',
              style: const TextStyle(color: A2Colors.cyan, fontWeight: FontWeight.w900, fontSize: 11),
            )
          else
            const Text('—', style: TextStyle(color: A2Colors.gris1, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Point pulsant LIVE ───────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        color: A2Colors.rouge.withValues(alpha: _anim.value),
        shape: BoxShape.circle,
      ),
    ),
  );
}
