import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/athlete.dart';
import 'package:pentarun_flutter/models/station.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';
import 'package:pentarun_flutter/utils/time_formatter.dart';
import 'package:pentarun_flutter/widgets/station_progress_bar.dart';

class AthleteRaceCard extends StatelessWidget {
  final Athlete athlete;
  final int elapsedMs;
  final DateTime startTime;

  const AthleteRaceCard({
    super.key,
    required this.athlete,
    required this.elapsedMs,
    required this.startTime,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final finished = athlete.status == AthleteStatus.finished;

    return Container(
      decoration: BoxDecoration(
        color: A2Colors.card,
        border: Border.all(
          color: finished ? A2Colors.vert : A2Colors.border2,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            color: A2Colors.surfaceDark,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  athlete.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    color: A2Colors.blanc,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${athlete.weightKb} KG',
                      style: const TextStyle(
                        color: A2Colors.cyan,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Cible: ${athlete.energy.total.round()} kcal',
                      style: const TextStyle(
                        color: A2Colors.ambre,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Progress bar
          StationProgressBar(currentStation: athlete.currentStation),

          // Action zone
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: finished ? _finishedView() : _runningView(state),
            ),
          ),

          // Footer
          Container(
            color: A2Colors.surfaceDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TimeFormatter.format(
                      finished ? athlete.finalTimeMs : elapsedMs),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 22,
                    color: Color(0xFFCCCCCC),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (athlete.currentStation > 0 && !finished)
                  IconButton(
                    onPressed: () => state.undo(athlete.id),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.undo, color: A2Colors.gris1, size: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _finishedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ring gauge full vert
        SizedBox(
          width: 72,
          height: 72,
          child: CustomPaint(
            painter: _StationRingPainter(
              current: Station.count,
              total: Station.count,
            ),
            child: const Center(
              child: Icon(Icons.check, color: A2Colors.vert, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'TERMINÉ',
          style: TextStyle(
            color: A2Colors.vert,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
        if (athlete.noCountEvents > 0) ...[
          const SizedBox(height: 8),
          Text(
            'No-Count ×${athlete.noCountEvents}',
            style: const TextStyle(
              color: A2Colors.rouge,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 12),
        // Splits résumé
        if (athlete.splits.length == Station.count)
          _splitsSummary(),
      ],
    );
  }

  Widget _runningView(AppState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ligne: bague + étape + splits
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bague de progression circulaire
            SizedBox(
              width: 72,
              height: 72,
              child: CustomPaint(
                painter: _StationRingPainter(
                  current: athlete.currentStation,
                  total: Station.count,
                ),
                child: Center(
                  child: Text(
                    '${athlete.currentStation}/${Station.count}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: A2Colors.cyan,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Étape actuelle + splits live
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ÉTAPE ACTUELLE',
                    style: TextStyle(
                      color: A2Colors.gris1,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Station.labelAt(athlete.currentStation),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: A2Colors.blanc,
                      fontSize: 11,
                    ),
                  ),
                  if (athlete.splits.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _splitsLive(),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (athlete.noCountEvents > 0) ...[
          const SizedBox(height: 8),
          Text(
            'NO COUNT ×${athlete.noCountEvents}',
            style: const TextStyle(
              color: A2Colors.rouge,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 12),
        // FAT FINGER — Valider
        SizedBox(
          width: double.infinity,
          height: 144,
          child: ElevatedButton(
            onPressed: () => state.validateStation(athlete.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: A2Colors.cyanDark,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, size: 30),
                SizedBox(height: 8),
                Text(
                  'VALIDER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // No-Count
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => state.noCount(athlete.id),
            style: OutlinedButton.styleFrom(
              foregroundColor: A2Colors.rouge,
              side: const BorderSide(color: Color(0xFF5A1A1A)),
              backgroundColor: const Color(0xFF1A0505),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: const Icon(Icons.block, size: 14),
            label: const Text(
              'NO-COUNT',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<int> _computeDeltas() {
    return athlete.splits.asMap().entries.map((e) {
      final prev = e.key == 0 ? startTime : athlete.splits[e.key - 1];
      return e.value.difference(prev).inMilliseconds;
    }).toList();
  }

  Widget _splitsLive() {
    final deltas = _computeDeltas();
    return Wrap(
      spacing: 6,
      runSpacing: 2,
      children: deltas.asMap().entries.map((e) {
        final isLast = e.key == deltas.length - 1;
        return Text(
          'S${e.key + 1}:${TimeFormatter.format(e.value)}',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isLast ? A2Colors.cyan : A2Colors.gris1,
          ),
        );
      }).toList(),
    );
  }

  Widget _splitsSummary() {
    final deltas = _computeDeltas();
    return Wrap(
      spacing: 6,
      runSpacing: 2,
      children: deltas.asMap().entries.map((e) {
        return Text(
          'S${e.key + 1}:${TimeFormatter.format(e.value)}',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: A2Colors.gris1,
          ),
        );
      }).toList(),
    );
  }
}

// ─── Bague de Progression Circulaire ─────────────────────────────────────────

class _StationRingPainter extends CustomPainter {
  final int current;
  final int total;

  const _StationRingPainter({required this.current, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    // Fond
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFF2A2A2A);
    canvas.drawCircle(center, radius, bgPaint);

    if (current <= 0) return;

    // Arc progression
    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = current >= total ? A2Colors.vert : A2Colors.cyan;

    final sweepAngle = (current / total) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_StationRingPainter old) => old.current != current;
}
