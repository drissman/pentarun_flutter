import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/athlete.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class AthleteSetupCard extends StatelessWidget {
  final Athlete athlete;
  const AthleteSetupCard({super.key, required this.athlete});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: A2Colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: A2Colors.cyan, width: 4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  athlete.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: A2Colors.blanc,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _tag(athlete.level.label),
                    _tag('${athlete.weightKb}KG · C:${athlete.coeff.toStringAsFixed(3)}',
                        color: A2Colors.cyan),
                    _tag('~${athlete.energy.total.round()} KCAL',
                        color: A2Colors.ambre),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => state.removeAthlete(athlete.id),
            icon: const Icon(Icons.close, color: A2Colors.gris1, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, {Color color = A2Colors.gris1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
