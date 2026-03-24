import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/athlete.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';
import 'package:pentarun_flutter/utils/time_formatter.dart';
import 'package:pentarun_flutter/widgets/athlete_result_card.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final ranked = state.rankedAthletes;
    final finishedCount =
        ranked.where((a) => a.status == AthleteStatus.finished).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Title
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monitor_heart, color: A2Colors.cyan, size: 34),
                  SizedBox(width: 12),
                  Text(
                    'RÉSULTATS OFFICIELS',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 35,
                      letterSpacing: -1,
                      color: A2Colors.blanc,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'PHASE 3 — LE BILAN MÉTABOLIQUE ET LÉGAL',
                style: TextStyle(
                  color: A2Colors.gris1,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),

              // Podium (si ≥ 2 athlètes terminés)
              if (finishedCount >= 2) ...[
                _PodiumCard(ranked: ranked),
                const SizedBox(height: 32),
              ],

              // Athlete cards
              ...ranked.map((a) => AthleteResultCard(athlete: a)),

              const SizedBox(height: 16),

              // Actions rapides
              _QuickActionsPanel(state: state),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Podium Classement ────────────────────────────────────────────────────────

class _PodiumCard extends StatelessWidget {
  final List<Athlete> ranked;

  const _PodiumCard({required this.ranked});

  @override
  Widget build(BuildContext context) {
    final finished =
        ranked.where((a) => a.status == AthleteStatus.finished).toList();
    final dnf =
        ranked.where((a) => a.status != AthleteStatus.finished).toList();

    return Container(
      decoration: BoxDecoration(
        color: A2Colors.card,
        border: Border.all(color: const Color(0xFF3A2800)),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: A2Colors.surfaceDark,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const Row(
              children: [
                Icon(Icons.emoji_events, color: A2Colors.ambre, size: 22),
                SizedBox(width: 10),
                Text(
                  'CLASSEMENT DE VAGUE',
                  style: TextStyle(
                    color: A2Colors.ambre,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          ...finished.asMap().entries.map((e) =>
              _podiumRow(rank: e.key + 1, athlete: e.value)),
          ...dnf.map((a) => _podiumRow(rank: null, athlete: a)),
        ],
      ),
    );
  }

  Widget _podiumRow({required int? rank, required Athlete athlete}) {
    final Color borderColor;
    final String rankLabel;

    if (rank == 1) {
      borderColor = A2Colors.ambre;
      rankLabel = '1er';
    } else if (rank == 2) {
      borderColor = A2Colors.argent;
      rankLabel = '2e';
    } else if (rank == 3) {
      borderColor = A2Colors.bronze;
      rankLabel = '3e';
    } else if (rank != null) {
      borderColor = A2Colors.border2;
      rankLabel = '${rank}e';
    } else {
      borderColor = const Color(0xFF5A1A1A);
      rankLabel = 'DNF';
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: borderColor, width: 3),
          bottom: const BorderSide(color: A2Colors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              rankLabel,
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              athlete.name,
              style: const TextStyle(
                color: A2Colors.blanc,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          if (athlete.officialScore != null)
            Text(
              TimeFormatter.format(athlete.officialScore!.round()),
              style: const TextStyle(
                fontFamily: 'monospace',
                color: A2Colors.vert,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            )
          else
            const Text(
              'DNF',
              style: TextStyle(
                color: A2Colors.rouge,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          const SizedBox(width: 16),
          if (athlete.finalTimeMs != null)
            Text(
              TimeFormatter.format(athlete.finalTimeMs),
              style: const TextStyle(
                fontFamily: 'monospace',
                color: A2Colors.gris1,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Actions Rapides ──────────────────────────────────────────────────────────

class _QuickActionsPanel extends StatelessWidget {
  final AppState state;

  const _QuickActionsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1, color: A2Colors.border),
        const SizedBox(height: 24),
        Row(
          children: [
            _ActionTile(
              icon: Icons.picture_as_pdf,
              label: 'EXPORT PDF',
              color: A2Colors.gris1,
              enabled: false,
            ),
            const SizedBox(width: 12),
            _ActionTile(
              icon: Icons.refresh,
              label: 'NOUVELLE\nVAGUE',
              color: A2Colors.vert,
              enabled: true,
              onTap: () => state.resetAll(),
            ),
            const SizedBox(width: 12),
            _ActionTile(
              icon: Icons.share,
              label: 'PARTAGER',
              color: A2Colors.cyan,
              enabled: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: enabled ? 1.0 : 0.35,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: A2Colors.surface,
              border: Border.all(color: A2Colors.border2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: enabled ? color : A2Colors.gris2,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                    height: 1.4,
                  ),
                ),
                if (!enabled) ...[
                  const SizedBox(height: 3),
                  const Text(
                    'BIENTÔT',
                    style: TextStyle(
                      color: A2Colors.gris1,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
