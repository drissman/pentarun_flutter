// SPEC-KIT §5.6 — Phase 2.3 Sprint 1+2 — Classement podium + Records par catégorie
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

// Déduit le sexe depuis coeff_sexe
Sex _sexFromCoeff(double coeff) => coeff >= 1.0 ? Sex.homme : Sex.femme;

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  Level _level     = Level.challenger;
  Sex _sexe        = Sex.homme;
  AgeCategory _cat = AgeCategory.senior;

  List<RaceResult>? _ranking;
  List<RaceResult>? _records;
  bool _loadingRanking = false;
  bool _loadingRecords = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(_onTabChange);
    _loadRanking();
  }

  void _onTabChange() {
    if (_tabs.index == 1 && _records == null && !_loadingRecords) {
      _loadRecords();
    }
  }

  Future<void> _loadRanking() async {
    setState(() => _loadingRanking = true);
    final raw = await ResultsService.getRanking(
      level: _level.label,
      sexe: _sexe.dbValue,
      categorieAge: _cat.label,
    );
    final filtered = raw.where((r) => _catFromCoeff(r.coeffAge) == _cat).toList();
    if (mounted) setState(() { _ranking = filtered; _loadingRanking = false; });
  }

  Future<void> _loadRecords() async {
    setState(() => _loadingRecords = true);
    final data = await ResultsService.getRecords(level: _level.label);
    if (mounted) setState(() { _records = data; _loadingRecords = false; });
  }

  void _onLevelChanged(Level v) {
    setState(() { _level = v; _ranking = null; _records = null; });
    _loadRanking();
    if (_tabs.index == 1) _loadRecords();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
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
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: A2Colors.cyan,
          labelColor: A2Colors.cyan,
          unselectedLabelColor: A2Colors.gris1,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
          tabs: const [
            Tab(text: 'CLASSEMENT'),
            Tab(text: 'RECORDS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _RankingTab(
            level: _level,
            sexe: _sexe,
            cat: _cat,
            results: _ranking,
            loading: _loadingRanking,
            onLevelChanged: _onLevelChanged,
            onSexeChanged: (v) {
              setState(() { _sexe = v; _ranking = null; });
              _loadRanking();
            },
            onCatChanged: (v) {
              setState(() { _cat = v; _ranking = null; });
              _loadRanking();
            },
          ),
          _RecordsTab(
            level: _level,
            records: _records,
            loading: _loadingRecords,
            onLevelChanged: _onLevelChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Tab Classement ───────────────────────────────────────────────────────────

class _RankingTab extends StatelessWidget {
  final Level level;
  final Sex sexe;
  final AgeCategory cat;
  final List<RaceResult>? results;
  final bool loading;
  final ValueChanged<Level> onLevelChanged;
  final ValueChanged<Sex> onSexeChanged;
  final ValueChanged<AgeCategory> onCatChanged;

  const _RankingTab({
    required this.level,
    required this.sexe,
    required this.cat,
    required this.results,
    required this.loading,
    required this.onLevelChanged,
    required this.onSexeChanged,
    required this.onCatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FiltersBar(
          level: level,
          sexe: sexe,
          cat: cat,
          onLevelChanged: onLevelChanged,
          onSexeChanged: onSexeChanged,
          onCatChanged: onCatChanged,
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator(color: A2Colors.cyan))
              : (results == null || results!.isEmpty)
                  ? _emptyState()
                  : _body(),
        ),
      ],
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

  Widget _body() {
    final top3 = results!.take(3).toList();
    final rest  = results!.skip(3).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (top3.isNotEmpty) _PodiumWidget(top3: top3),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...rest.asMap().entries.map((e) => _rankRow(e.value, e.key + 4)),
        ],
      ],
    );
  }

  Widget _rankRow(RaceResult r, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: A2Colors.card,
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: A2Colors.border2, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text('$rank',
                  style: const TextStyle(
                      color: A2Colors.gris1,
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
            ),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.athleteDisplayName ?? r.profileId,
                    style: const TextStyle(
                        color: A2Colors.blanc, fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '${r.waveDate.day.toString().padLeft(2,'0')}/'
                  '${r.waveDate.month.toString().padLeft(2,'0')}/'
                  '${r.waveDate.year}'
                  ' · ${r.weightKbKg} kg KB',
                  style: const TextStyle(color: A2Colors.gris1, fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(TimeFormatter.format(r.platformScore.round()),
                  style: const TextStyle(fontFamily: 'monospace', color: A2Colors.cyan,
                      fontWeight: FontWeight.w900, fontSize: 15)),
              Text('T.brut ${TimeFormatter.format(r.finalTimeMs)}',
                  style: const TextStyle(fontFamily: 'monospace', color: A2Colors.gris1,
                      fontSize: 9)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Podium top 3 ─────────────────────────────────────────────────────────────

class _PodiumWidget extends StatelessWidget {
  final List<RaceResult> top3;
  const _PodiumWidget({required this.top3});

  @override
  Widget build(BuildContext context) {
    // Ordre visuel podium : 2 – 1 – 3
    final order = [
      if (top3.length > 1) (rank: 2, result: top3[1]),
      (rank: 1, result: top3[0]),
      if (top3.length > 2) (rank: 3, result: top3[2]),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: order.map((e) => Expanded(
          child: _PodiumCard(rank: e.rank, result: e.result),
        )).toList(),
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final int rank;
  final RaceResult result;
  const _PodiumCard({required this.rank, required this.result});

  Color get _color {
    if (rank == 1) return A2Colors.ambre;
    if (rank == 2) return A2Colors.argent;
    return A2Colors.bronze;
  }

  double get _height {
    if (rank == 1) return 100;
    if (rank == 2) return 78;
    return 60;
  }

  @override
  Widget build(BuildContext context) {
    final firstName = result.athleteDisplayName?.split(' ').first ?? '—';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(firstName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _color, fontWeight: FontWeight.w900,
                  fontSize: rank == 1 ? 12 : 10)),
          const SizedBox(height: 4),
          Text(TimeFormatter.format(result.platformScore.round()),
              style: TextStyle(fontFamily: 'monospace', color: _color,
                  fontWeight: FontWeight.w900, fontSize: rank == 1 ? 14 : 12)),
          const SizedBox(height: 6),
          Container(
            height: _height,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(top: BorderSide(color: _color, width: 2)),
            ),
            child: Center(
              child: Text('$rank',
                  style: TextStyle(color: _color, fontWeight: FontWeight.w900,
                      fontSize: rank == 1 ? 28 : 22)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Records ─────────────────────────────────────────────────────────────

class _RecordsTab extends StatelessWidget {
  final Level level;
  final List<RaceResult>? records;
  final bool loading;
  final ValueChanged<Level> onLevelChanged;

  const _RecordsTab({
    required this.level,
    required this.records,
    required this.loading,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: A2Colors.card,
          child: Row(
            children: [
              const Text('NIVEAU',
                  style: TextStyle(color: A2Colors.gris1, fontSize: 9,
                      fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(width: 8),
              DropdownButton<Level>(
                value: level,
                dropdownColor: A2Colors.card,
                underline: const SizedBox(),
                style: const TextStyle(color: A2Colors.cyan,
                    fontWeight: FontWeight.w900, fontSize: 12),
                items: Level.values.map((l) => DropdownMenuItem(
                  value: l, child: Text(l.label),
                )).toList(),
                onChanged: (v) { if (v != null) onLevelChanged(v); },
              ),
            ],
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator(color: A2Colors.cyan))
              : (records == null || records!.isEmpty)
                  ? _emptyState()
                  : _recordsGrid(records!),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, color: A2Colors.border2, size: 48),
          SizedBox(height: 16),
          Text('AUCUN RECORD POUR CE NIVEAU',
              style: TextStyle(color: A2Colors.gris1, fontWeight: FontWeight.w900,
                  letterSpacing: 2, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _recordsGrid(List<RaceResult> data) {
    final grid = <AgeCategory, Map<Sex, RaceResult>>{};
    for (final r in data) {
      final cat = _catFromCoeff(r.coeffAge);
      final sex = _sexFromCoeff(r.coeffSexe);
      grid.putIfAbsent(cat, () => {})[sex] = r;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(children: [
            const SizedBox(width: 88),
            Expanded(child: Center(
              child: const Text('HOMME',
                  style: TextStyle(color: A2Colors.cyan, fontWeight: FontWeight.w900,
                      fontSize: 10, letterSpacing: 1.5)),
            )),
            Expanded(child: Center(
              child: const Text('FEMME',
                  style: TextStyle(color: A2Colors.cyan, fontWeight: FontWeight.w900,
                      fontSize: 10, letterSpacing: 1.5)),
            )),
          ]),
        ),
        ...AgeCategory.values.map((cat) {
          final homme = grid[cat]?[Sex.homme];
          final femme = grid[cat]?[Sex.femme];
          if (homme == null && femme == null) return const SizedBox.shrink();
          return _RecordRow(cat: cat, homme: homme, femme: femme);
        }),
      ],
    );
  }
}

class _RecordRow extends StatelessWidget {
  final AgeCategory cat;
  final RaceResult? homme;
  final RaceResult? femme;

  const _RecordRow({required this.cat, this.homme, this.femme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: A2Colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: A2Colors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: const BoxDecoration(
              color: A2Colors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Text(cat.label,
                style: const TextStyle(color: A2Colors.gris1,
                    fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1)),
          ),
          Expanded(child: _RecordCell(result: homme)),
          Container(width: 1, height: 56, color: A2Colors.border),
          Expanded(child: _RecordCell(result: femme)),
        ],
      ),
    );
  }
}

class _RecordCell extends StatelessWidget {
  final RaceResult? result;
  const _RecordCell({this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const Center(
        child: Text('—', style: TextStyle(color: A2Colors.border2, fontSize: 18)),
      );
    }
    final date = '${result!.waveDate.day.toString().padLeft(2,'0')}/'
        '${result!.waveDate.month.toString().padLeft(2,'0')}/'
        '${result!.waveDate.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(TimeFormatter.format(result!.platformScore.round()),
              style: const TextStyle(fontFamily: 'monospace', color: A2Colors.ambre,
                  fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            result!.athleteDisplayName?.split(' ').first ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: A2Colors.blanc, fontSize: 9,
                fontWeight: FontWeight.w700),
          ),
          Text(date,
              style: const TextStyle(color: A2Colors.gris1, fontSize: 8)),
        ],
      ),
    );
  }
}

// ─── Barre de filtres (Classement) ────────────────────────────────────────────

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
          _FilterChip<Level>(
            label: 'NIVEAU',
            value: level,
            items: Level.values,
            labelOf: (l) => l.label,
            onChanged: onLevelChanged,
          ),
          _FilterChip<Sex>(
            label: 'SEXE',
            value: sexe,
            items: Sex.values,
            labelOf: (s) => s.label,
            onChanged: onSexeChanged,
          ),
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
            style: const TextStyle(color: A2Colors.gris1, fontSize: 9,
                fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        DropdownButton<T>(
          value: value,
          dropdownColor: A2Colors.card,
          underline: const SizedBox(),
          style: const TextStyle(color: A2Colors.cyan,
              fontWeight: FontWeight.w900, fontSize: 12),
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
