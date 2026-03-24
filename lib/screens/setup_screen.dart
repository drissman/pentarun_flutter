import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/energy_breakdown.dart';
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
                      style: TextStyle(fontSize: 10, color: A2Colors.gris2),
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

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final athletes = state.athletes;
    final hasAthletes = athletes.isNotEmpty;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                  const Row(
                    children: [
                      Icon(Icons.monitor_heart, color: A2Colors.cyan, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'CONFIGURATION VAGUE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 19,
                          color: A2Colors.blanc,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "PHASE 1 — LA CHAMBRE D'APPEL",
                    style: TextStyle(
                      color: A2Colors.gris2,
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
                              color: A2Colors.gris2,
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

                  // Start button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: hasAthletes ? () => state.startRacing() : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            hasAthletes ? A2Colors.vert : const Color(0xFF1A1A1A),
                        foregroundColor:
                            hasAthletes ? Colors.black : A2Colors.gris2,
                        disabledBackgroundColor: const Color(0xFF1A1A1A),
                        disabledForegroundColor: A2Colors.gris2,
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
