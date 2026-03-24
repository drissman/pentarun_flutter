// SPEC-KIT §4.1 — Écran historique performances athlète
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/athlete_profile.dart';
import 'package:pentarun_flutter/models/race_result.dart';
import 'package:pentarun_flutter/services/results_service.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';
import 'package:pentarun_flutter/utils/time_formatter.dart';

class HistoryScreen extends StatefulWidget {
  final AthleteProfile profile;
  const HistoryScreen({super.key, required this.profile});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RaceResult>? _results;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await ResultsService.getHistoryForProfile(widget.profile.id);
    if (mounted) setState(() { _results = results; _loading = false; });
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.profile.displayName,
              style: const TextStyle(
                color: A2Colors.blanc,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            Text(
              '${widget.profile.ageCategory.label} · ${widget.profile.sexe.label}',
              style: const TextStyle(
                color: A2Colors.gris1,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: A2Colors.cyan))
          : _results == null || _results!.isEmpty
              ? _emptyState()
              : _resultsList(),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, color: A2Colors.border2, size: 48),
          SizedBox(height: 16),
          Text(
            'AUCUNE COURSE ENREGISTRÉE',
            style: TextStyle(
              color: A2Colors.gris1,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _results!.length,
      itemBuilder: (ctx, i) => _resultCard(_results![i], i),
    );
  }

  Widget _resultCard(RaceResult r, int index) {
    final isPb = index == 0; // Premier résultat = meilleur score (trié ASC)
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: A2Colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPb ? A2Colors.ambre : A2Colors.border,
          width: isPb ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPb)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: A2Colors.ambre.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: A2Colors.ambre.withValues(alpha: 0.4)),
                  ),
                  child: const Text('MEILLEUR SCORE',
                    style: TextStyle(color: A2Colors.ambre, fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              Text(
                '${r.waveDate.day.toString().padLeft(2,'0')}/'
                '${r.waveDate.month.toString().padLeft(2,'0')}/'
                '${r.waveDate.year}',
                style: const TextStyle(
                  color: A2Colors.gris1,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${r.level.label} · ${r.weightKbKg} KG',
                style: const TextStyle(
                  color: A2Colors.cyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Scores
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                TimeFormatter.format(r.finalTimeMs),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: A2Colors.blanc,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              // SPEC-KIT §5.2 — scorePlateforme affiché
              Text(
                'SCORE ${TimeFormatter.format(r.platformScore.round())}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: A2Colors.vert,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
