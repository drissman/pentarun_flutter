import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pentarun_flutter/models/athlete.dart';
import 'package:pentarun_flutter/services/cv_service.dart';
import 'package:pentarun_flutter/services/hr_session_service.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';
import 'package:pentarun_flutter/utils/time_formatter.dart';
import 'package:pentarun_flutter/widgets/athlete_race_card.dart';

class RacingScreen extends StatefulWidget {
  const RacingScreen({super.key});

  @override
  State<RacingScreen> createState() => _RacingScreenState();
}

class _RacingScreenState extends State<RacingScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      // SPEC-KIT §4.2 — Moteur Anti-Drift : timestamp absolu (DateTime.now() - startTime)
      AppStateProvider.of(context).updateElapsed();
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    final screenW = MediaQuery.of(context).size.width;
    final padding = (screenW * 0.03).clamp(8.0, 24.0);

    return Stack(
      children: [
        // ── Fond caméra CV — plein écran translucide ────────────────────────
        if (state.cvEnabled) ...[
          Positioned.fill(child: CvServiceImpl.instance.buildPreview()),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.58)),
          ),
        ],

        // ── UI principale ────────────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header compact
                _buildHeader(context, state),
                const SizedBox(height: 8),

                // Athletes grid — adaptatif
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      final athletes = state.athletes;
                      if (athletes.isEmpty) return const SizedBox.shrink();

                      final cols = w > 900 ? 3 : w > 560 ? 2 : 1;
                      const spacing = 10.0;
                      final cardWidth = (w - (cols - 1) * spacing) / cols;
                      final rows = (athletes.length / cols).ceil();
                      final cardHeight = rows <= 1
                          ? h
                          : (h * 0.9).clamp(340.0, 640.0);

                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: athletes.map((a) => SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: AthleteRaceCard(
                              athlete: a,
                              elapsedMs: state.elapsedMs,
                              startTime: state.startTime!,
                            ),
                          )).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    final allDone = state.athletes.isNotEmpty &&
        state.athletes.every((a) => a.status == AthleteStatus.finished);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          // ── Indicateur LIVE ──────────────────────────────────────────────
          _pulseDot(),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              color: A2Colors.rouge,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 14),

          // ── BPM temps réel ───────────────────────────────────────────────
          StreamBuilder<int>(
            stream: HrSessionService.instance.bpmStream,
            builder: (_, snap) {
              final bpm = snap.data;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 13,
                    color: bpm != null ? A2Colors.rouge : A2Colors.gris1,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    bpm != null ? '$bpm' : '--',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: A2Colors.blanc,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    'BPM',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: A2Colors.gris1,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Chrono centré ────────────────────────────────────────────────
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                TimeFormatter.format(state.elapsedMs),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  color: A2Colors.blanc,
                ),
              ),
            ),
          ),

          // ── Bouton CLÔTURER ──────────────────────────────────────────────
          GestureDetector(
            onTap: () => state.goToSummary(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: allDone
                    ? A2Colors.rouge.withValues(alpha: 0.15)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: allDone
                      ? A2Colors.rouge.withValues(alpha: 0.6)
                      : const Color(0xFF3A3A3A),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.stop_circle_outlined,
                    size: 16,
                    color: allDone ? A2Colors.rouge : A2Colors.gris1,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CLÔTURER',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: allDone ? A2Colors.rouge : A2Colors.gris1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pulseDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: A2Colors.rouge.withValues(alpha: value),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        // Restart animation by rebuilding
        if (mounted) setState(() {});
      },
    );
  }
}
