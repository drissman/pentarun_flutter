import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      // Anti-drift: always compute from DateTime.now() - startTime
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header chrono
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 600;
                  final statusRow = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _pulseDot(),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACQUISITION EN COURS',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: A2Colors.blanc,
                            ),
                          ),
                          Text(
                            "PHASE 2 — L'ARÈNE A2UI",
                            style: TextStyle(
                              color: A2Colors.gris1,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  final chrono = Text(
                    TimeFormatter.format(state.elapsedMs),
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: A2Colors.cyan,
                      letterSpacing: -3,
                    ),
                  );

                  final closeBtn = OutlinedButton.icon(
                    onPressed: () => state.goToSummary(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: A2Colors.rouge,
                      side: const BorderSide(color: Color(0xFF5A1A1A)),
                      backgroundColor: const Color(0xFF1A0505),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.warning_amber_rounded, size: 16),
                    label: const Text(
                      'CLÔTURER',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                  );

                  if (wide) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        statusRow,
                        chrono,
                        closeBtn,
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [statusRow, closeBtn],
                        ),
                        const SizedBox(height: 8),
                        chrono,
                      ],
                    );
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Athletes grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 900
                    ? 3
                    : constraints.maxWidth > 560
                        ? 2
                        : 1;
                final spacing = 16.0;
                final cardWidth =
                    (constraints.maxWidth - (cols - 1) * spacing) / cols;

                return SingleChildScrollView(
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: state.athletes.map((a) {
                      return SizedBox(
                        width: cardWidth,
                        height: 460,
                        child: AthleteRaceCard(
                          athlete: a,
                          elapsedMs: state.elapsedMs,
                          startTime: state.startTime!,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
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
