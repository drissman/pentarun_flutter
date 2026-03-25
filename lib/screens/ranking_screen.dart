// SPEC-KIT §5.6 — Classement en ligne (Philosophie B : intra-niveau)
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/age_category.dart';
import 'package:pentarun_flutter/models/level.dart';
import 'package:pentarun_flutter/models/race_result.dart';
import 'package:pentarun_flutter/models/sex.dart';
import 'package:pentarun_flutter/services/results_service.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';
import 'package:pentarun_flutter/utils/time_formatter.dart';

// SPEC-KIT §5.4 — Déduit la catégorie d'âge depuis coeff_age (pas de colonne DB)
AgeCategory _catFromCoeff(double coeff) {
  if (coeff == 0.980) return AgeCategory.junior;
  if (coeff == 0.990) return AgeCategory.espoir;
  if (coeff == 1.000) return AgeCategory.senior;
  if (coeff == 0.915) return AgeCategory.master1;
  if (coeff == 0.855) return AgeCategory.master2;
  return AgeCategory.master3;
}

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  Level _level         = Level.challenger;
  Sex _sexe            = Sex.homme;
  AgeCategory _cat     = AgeCategory.senior;

  List<RaceResult>? _results;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final raw = await ResultsService.getRanking(
      level: _level.label,
      sexe: _sexe.dbValue,
      categorieAge: _cat.label,
    );
    // SPEC-KIT §5.6 — Filtre catégorie d'âge côté client depuis coeff_age
    final r = raw.where((res) => _catFromCoeff(res.coeffAge) == _cat).toList();
    if (mounted) setState(() { _results = r; _loading = false; });
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
          'CLASSEMENT EN LIGNE',
          style: TextStyle(
            color: A2Colors.blanc,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtres
          _FiltersBar(
            level: _level,
            sexe: _sexe,
            cat: _cat,
            onLevelChanged: (v) { setState(() { _level = v; _results = null; }); _load(); },
            onSexeChanged: (v) { setState(() { _sexe = v; _results = null; }); _load(); },
            onCatChanged:  (v) { setState(() { _cat = v; _results = null; }); _load(); },
          ),
          // Résultats
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: A2Colors.cyan))
                : _results == null || _results!.isEmpty
                    ? _emptyState()
                    : _rankingList(),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, color: A2Colors.border2, size: 48),
          SizedBox(height: 16),
          Text(
            'AUCUN RÉSULTAT POUR CES FILTRES',
            style: TextStyle(
              color: A2Colors.gris1,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _results!.length,
      itemBuilder: (ctx, i) => _rankRow(_results![i], i + 1),
    );
  }

  Widget _rankRow(RaceResult r, int rank) {
    final Color rankColor;
    if (rank == 1)      rankColor = A2Colors.ambre;
    else if (rank == 2) rankColor = A2Colors.argent;
    else if (rank == 3) rankColor = A2Colors.bronze;
    else                rankColor = A2Colors.border2;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: A2Colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: rankColor, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.athleteDisplayName ?? r.profileId, // SPEC-KIT §5.6 — nom via jointure profiles
                    style: const TextStyle(
                      color: A2Colors.blanc,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${r.waveDate.day.toString().padLeft(2,'0')}/${r.waveDate.month.toString().padLeft(2,'0')}/${r.waveDate.year}'
                    ' · ${r.weightKbKg} kg KB',
                    style: const TextStyle(
                      color: A2Colors.gris1,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  TimeFormatter.format(r.platformScore.round()),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: A2Colors.cyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'T.brut ${TimeFormatter.format(r.finalTimeMs)}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: A2Colors.gris1,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Barre de filtres ─────────────────────────────────────────────────────────

class _FiltersBar extends StatelessWidget {
  final Level level;
  final Sex sexe;
  final AgeCategory cat;
  final ValueChanged<Level> onLevelChanged;
  final ValueChanged<Sex> onSexeChanged;
  final ValueChanged<AgeCategory> onCatChanged;

  const _FiltersBar({
    required this.level,
    required this.sexe,
    required this.cat,
    required this.onLevelChanged,
    required this.onSexeChanged,
    required this.onCatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: A2Colors.card,
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          // Niveau
          _FilterChip<Level>(
            label: 'NIVEAU',
            value: level,
            items: Level.values,
            labelOf: (l) => l.label,
            onChanged: onLevelChanged,
          ),
          // Sexe
          _FilterChip<Sex>(
            label: 'SEXE',
            value: sexe,
            items: Sex.values,
            labelOf: (s) => s.label,
            onChanged: onSexeChanged,
          ),
          // Catégorie d'âge
          _FilterChip<AgeCategory>(
            label: 'CATÉGORIE',
            value: cat,
            items: AgeCategory.values,
            labelOf: (c) => c.label,
            onChanged: onCatChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterChip<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
          style: const TextStyle(
            color: A2Colors.gris1, fontSize: 9,
            fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        DropdownButton<T>(
          value: value,
          dropdownColor: A2Colors.card,
          underline: const SizedBox(),
          style: const TextStyle(
            color: A2Colors.cyan, fontWeight: FontWeight.w900, fontSize: 12),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(labelOf(item)),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ],
    );
  }
}
