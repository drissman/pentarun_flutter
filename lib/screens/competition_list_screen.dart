// SPEC-KIT §7.1 — Phase 2.2 — Liste compétitions + gestion vagues (organisateur)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pentarun_flutter/models/competition.dart';
import 'package:pentarun_flutter/models/level.dart';
import 'package:pentarun_flutter/models/wave.dart';
import 'package:pentarun_flutter/models/wave_athlete.dart';
import 'package:pentarun_flutter/models/athlete_profile.dart';
import 'package:pentarun_flutter/screens/competition_create_screen.dart';
import 'package:pentarun_flutter/screens/director_screen.dart';
import 'package:pentarun_flutter/services/competition_service.dart';
import 'package:pentarun_flutter/services/profile_service.dart';
import 'package:pentarun_flutter/services/wave_service.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class CompetitionListScreen extends StatefulWidget {
  const CompetitionListScreen({super.key});

  @override
  State<CompetitionListScreen> createState() => _CompetitionListScreenState();
}

class _CompetitionListScreenState extends State<CompetitionListScreen> {
  List<Competition> _competitions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await CompetitionService.getMyCompetitions();
      if (mounted) setState(() { _competitions = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createCompetition() async {
    final result = await Navigator.of(context).push<Competition>(
      MaterialPageRoute(builder: (_) => const CompetitionCreateScreen()),
    );
    if (result != null) {
      setState(() => _competitions.insert(0, result));
    }
  }

  Future<void> _openCompetition(Competition comp) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _CompetitionDetailScreen(competition: comp)),
    );
    _load(); // Refresh après retour
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
          'MES COMPÉTITIONS',
          style: TextStyle(
            color: A2Colors.blanc, fontWeight: FontWeight.w900,
            letterSpacing: 1.5, fontSize: 15,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: A2Colors.cyan),
            tooltip: 'Nouvelle compétition',
            onPressed: _createCompetition,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: A2Colors.cyan))
          : _competitions.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: A2Colors.cyan,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _competitions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _CompetitionCard(
                      competition: _competitions[i],
                      onTap: () => _openCompetition(_competitions[i]),
                    ),
                  ),
                ),
      floatingActionButton: _competitions.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _createCompetition,
              backgroundColor: A2Colors.cyan,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text('NOUVELLE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.emoji_events_outlined, color: A2Colors.gris1, size: 48),
        const SizedBox(height: 16),
        const Text('AUCUNE COMPÉTITION', style: TextStyle(
          color: A2Colors.gris1, fontWeight: FontWeight.w900,
          fontSize: 12, letterSpacing: 2,
        )),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _createCompetition,
          icon: const Icon(Icons.add),
          label: const Text('CRÉER MA 1ÈRE COMPÉTITION',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ],
    ),
  );
}

// ─── Card compétition ────────────────────────────────────────────────────────

class _CompetitionCard extends StatelessWidget {
  final Competition competition;
  final VoidCallback onTap;
  const _CompetitionCard({required this.competition, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statut = competition.statut;
    final color = statut == 'en_cours'
        ? A2Colors.vert
        : statut == 'termine'
            ? A2Colors.gris1
            : A2Colors.ambre;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: A2Colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: A2Colors.border2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(competition.nom, style: const TextStyle(
                    color: A2Colors.blanc, fontWeight: FontWeight.w900, fontSize: 14,
                  )),
                  const SizedBox(height: 4),
                  Text(
                    '${competition.lieu} · '
                    '${competition.dateEvent.day.toString().padLeft(2,'0')}/'
                    '${competition.dateEvent.month.toString().padLeft(2,'0')}/'
                    '${competition.dateEvent.year}',
                    style: const TextStyle(color: A2Colors.gris1, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Text(
                statut == 'en_cours' ? 'EN COURS' : statut == 'termine' ? 'TERMINÉE' : 'BROUILLON',
                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: A2Colors.gris1, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Détail compétition + gestion vagues ────────────────────────────────────

class _CompetitionDetailScreen extends StatefulWidget {
  final Competition competition;
  const _CompetitionDetailScreen({required this.competition});

  @override
  State<_CompetitionDetailScreen> createState() => _CompetitionDetailScreenState();
}

class _CompetitionDetailScreenState extends State<_CompetitionDetailScreen> {
  late Competition _competition;
  List<Wave> _waves = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _competition = widget.competition;
    _loadWaves();
  }

  Future<void> _loadWaves() async {
    setState(() => _loading = true);
    try {
      final data = await CompetitionService.getWaves(_competition.id);
      if (mounted) setState(() { _waves = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addWave() async {
    final result = await showDialog<Wave>(
      context: context,
      builder: (_) => _AddWaveDialog(competitionId: _competition.id, numero: _waves.length + 1),
    );
    if (result != null) setState(() => _waves.add(result));
  }

  Future<void> _toggleStatut() async {
    final next = _competition.isActive ? 'termine' : _competition.isDraft ? 'en_cours' : 'brouillon';
    await CompetitionService.updateStatut(_competition.id, next);
    setState(() => _competition = _competition.copyWith(statut: next));
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
        title: Text(
          _competition.nom,
          style: const TextStyle(
            color: A2Colors.blanc, fontWeight: FontWeight.w900,
            letterSpacing: 1, fontSize: 14,
          ),
        ),
        actions: [
          if (_competition.isActive) ...[
            IconButton(
              icon: const Icon(Icons.monitor, color: A2Colors.cyan),
              tooltip: 'Vue directeur',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DirectorScreen(competition: _competition),
              )),
            ),
            // SPEC-KIT §7.2 Sprint 5 — lien spectateur public
            IconButton(
              icon: const Icon(Icons.link, color: A2Colors.gris1),
              tooltip: 'Copier le lien spectateurs',
              onPressed: () async {
                const base = 'https://pentarun.netlify.app';
                final url = '$base/#/live/${_competition.id}';
                await Clipboard.setData(ClipboardData(text: url));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lien spectateurs copié !',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      backgroundColor: A2Colors.vert,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
          if (!_competition.isFinished)
            TextButton(
              onPressed: _toggleStatut,
              child: Text(
                _competition.isDraft ? 'LANCER' : 'CLÔTURER',
                style: TextStyle(
                  color: _competition.isDraft ? A2Colors.vert : A2Colors.rouge,
                  fontWeight: FontWeight.w900, fontSize: 11,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: A2Colors.cyan))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: A2Colors.card,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: A2Colors.gris1, size: 14),
                      const SizedBox(width: 6),
                      Text(_competition.lieu, style: const TextStyle(color: A2Colors.gris1, fontSize: 12)),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, color: A2Colors.gris1, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${_competition.dateEvent.day.toString().padLeft(2,'0')}/'
                        '${_competition.dateEvent.month.toString().padLeft(2,'0')}/'
                        '${_competition.dateEvent.year}',
                        style: const TextStyle(color: A2Colors.gris1, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Titre vagues
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('VAGUES', style: TextStyle(
                        color: A2Colors.gris1, fontSize: 10,
                        fontWeight: FontWeight.w900, letterSpacing: 2,
                      )),
                      if (!_competition.isFinished)
                        GestureDetector(
                          onTap: _addWave,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: A2Colors.cyan, size: 16),
                              SizedBox(width: 4),
                              Text('AJOUTER', style: TextStyle(
                                color: A2Colors.cyan, fontSize: 10,
                                fontWeight: FontWeight.w900, letterSpacing: 1,
                              )),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Liste vagues
                Expanded(
                  child: _waves.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('AUCUNE VAGUE', style: TextStyle(
                                color: A2Colors.gris1, fontSize: 11,
                                fontWeight: FontWeight.w900, letterSpacing: 2,
                              )),
                              const SizedBox(height: 12),
                              if (!_competition.isFinished)
                                TextButton.icon(
                                  onPressed: _addWave,
                                  icon: const Icon(Icons.add, color: A2Colors.cyan, size: 16),
                                  label: const Text('Ajouter une vague',
                                      style: TextStyle(color: A2Colors.cyan)),
                                ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _waves.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _WaveCard(
                            wave: _waves[i],
                            competition: _competition,
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// ─── Card vague ──────────────────────────────────────────────────────────────

class _WaveCard extends StatefulWidget {
  final Wave wave;
  final Competition competition;
  const _WaveCard({required this.wave, required this.competition});

  @override
  State<_WaveCard> createState() => _WaveCardState();
}

class _WaveCardState extends State<_WaveCard> {
  List<WaveAthlete> _athletes = [];
  bool _expanded = false;
  bool _loadingAthletes = false;

  Future<void> _loadAthletes() async {
    if (_loadingAthletes) return;
    setState(() => _loadingAthletes = true);
    try {
      final data = await WaveService.getWaveAthletes(widget.wave.id);
      if (mounted) setState(() { _athletes = data; _loadingAthletes = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingAthletes = false);
    }
  }

  Future<void> _enrollAthlete() async {
    final result = await showDialog<WaveAthlete>(
      context: context,
      builder: (_) => _EnrollAthleteDialog(waveId: widget.wave.id),
    );
    if (result != null) setState(() => _athletes.add(result));
  }

  @override
  Widget build(BuildContext context) {
    final statut = widget.wave.statut;
    final color = statut == 'en_cours'
        ? A2Colors.cyan
        : statut == 'terminee'
            ? A2Colors.vert
            : A2Colors.gris1;

    return Container(
      decoration: BoxDecoration(
        color: A2Colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: A2Colors.border2),
      ),
      child: Column(
        children: [
          // Header vague
          GestureDetector(
            onTap: () {
              setState(() => _expanded = !_expanded);
              if (!_expanded && _athletes.isEmpty) _loadAthletes();
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${widget.wave.numero}', style: TextStyle(
                        color: color, fontWeight: FontWeight.w900, fontSize: 13,
                      )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VAGUE ${widget.wave.numero}',
                            style: const TextStyle(color: A2Colors.blanc,
                                fontWeight: FontWeight.w900, fontSize: 13)),
                        Text(widget.wave.niveau.label,
                            style: const TextStyle(color: A2Colors.gris1, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      statut == 'en_cours' ? 'EN COURS' : statut == 'terminee' ? 'TERMINÉE' : 'ATTENTE',
                      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: A2Colors.gris1, size: 18),
                ],
              ),
            ),
          ),

          // Liste athlètes (expandable)
          if (_expanded) ...[
            const Divider(color: A2Colors.border2, height: 1),
            if (_loadingAthletes)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(color: A2Colors.cyan, strokeWidth: 2)),
              )
            else ...[
              if (_athletes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text('Aucun athlète inscrit',
                      style: TextStyle(color: A2Colors.gris1, fontSize: 11)),
                )
              else
                ...(_athletes.map((wa) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, color: A2Colors.gris1, size: 14),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        wa.displayName ?? wa.profileId,
                        style: const TextStyle(color: A2Colors.blanc, fontSize: 12),
                      )),
                      Text('${wa.kbKg} kg',
                          style: const TextStyle(color: A2Colors.ambre, fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ))),

              // Bouton inscrire
              if (!widget.competition.isFinished && widget.wave.isWaiting)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _enrollAthlete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: A2Colors.cyan,
                        side: const BorderSide(color: A2Colors.cyanDark),
                      ),
                      icon: const Icon(Icons.person_add_outlined, size: 16),
                      label: const Text('INSCRIRE UN ATHLÈTE',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                    ),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

// ─── Dialog : ajouter une vague ──────────────────────────────────────────────

class _AddWaveDialog extends StatefulWidget {
  final String competitionId;
  final int numero;
  const _AddWaveDialog({required this.competitionId, required this.numero});

  @override
  State<_AddWaveDialog> createState() => _AddWaveDialogState();
}

class _AddWaveDialogState extends State<_AddWaveDialog> {
  Level _niveau = Level.challenger;
  bool _loading = false;

  Future<void> _create() async {
    setState(() => _loading = true);
    try {
      final wave = await CompetitionService.createWave(
        competitionId: widget.competitionId,
        numero: widget.numero,
        niveau: _niveau.label,
      );
      if (mounted) Navigator.of(context).pop<Wave>(wave);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: A2Colors.card,
      title: Text('VAGUE ${widget.numero}',
          style: const TextStyle(color: A2Colors.blanc, fontWeight: FontWeight.w900, fontSize: 14)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NIVEAU', style: TextStyle(
            color: A2Colors.gris1, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5,
          )),
          const SizedBox(height: 8),
          DropdownButtonFormField<Level>(
            value: _niveau,
            dropdownColor: A2Colors.card,
            style: const TextStyle(color: A2Colors.cyan, fontWeight: FontWeight.w900),
            decoration: const InputDecoration(labelText: 'Niveau'),
            items: Level.values.map((l) => DropdownMenuItem(
              value: l, child: Text(l.label),
            )).toList(),
            onChanged: (v) { if (v != null) setState(() => _niveau = v); },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ANNULER', style: TextStyle(color: A2Colors.gris1)),
        ),
        TextButton(
          onPressed: _loading ? null : _create,
          child: _loading
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(color: A2Colors.cyan, strokeWidth: 2))
              : const Text('CRÉER', style: TextStyle(color: A2Colors.cyan, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

// ─── Dialog : inscrire un athlète ────────────────────────────────────────────

class _EnrollAthleteDialog extends StatefulWidget {
  final String waveId;
  const _EnrollAthleteDialog({required this.waveId});

  @override
  State<_EnrollAthleteDialog> createState() => _EnrollAthleteDialogState();
}

class _EnrollAthleteDialogState extends State<_EnrollAthleteDialog> {
  final _searchCtrl = TextEditingController();
  List<AthleteProfile> _results = [];
  AthleteProfile? _selected;
  int _kb = 16;
  bool _searching = false;
  bool _enrolling = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) { setState(() => _results = []); return; }
    setState(() => _searching = true);
    try {
      final data = await ProfileService.searchByName(query);
      if (mounted) setState(() { _results = data; _searching = false; });
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _enroll() async {
    if (_selected == null) return;
    setState(() => _enrolling = true);
    try {
      final wa = await WaveService.enrollAthlete(
        waveId: widget.waveId,
        profile: _selected!,
        kbKg: _kb,
      );
      if (mounted) Navigator.of(context).pop<WaveAthlete>(wa);
    } catch (e) {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: A2Colors.card,
      title: const Text('INSCRIRE UN ATHLÈTE',
          style: TextStyle(color: A2Colors.blanc, fontWeight: FontWeight.w900, fontSize: 13)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: A2Colors.blanc),
              decoration: const InputDecoration(
                labelText: 'Rechercher par nom / prénom',
                prefixIcon: Icon(Icons.search, color: A2Colors.gris1, size: 18),
              ),
              onChanged: _search,
            ),
            if (_searching)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(color: A2Colors.cyan, strokeWidth: 2),
              )
            else if (_results.isNotEmpty && _selected == null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    title: Text(_results[i].displayName,
                        style: const TextStyle(color: A2Colors.blanc, fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    subtitle: Text('${_results[i].ageCategory.label} · ${_results[i].niveauHabituel.label}',
                        style: const TextStyle(color: A2Colors.gris1, fontSize: 10)),
                    onTap: () => setState(() {
                      _selected = _results[i];
                      _kb = _results[i].kbHabituelKg;
                      _results = [];
                    }),
                  ),
                ),
              ),
            if (_selected != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: A2Colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: A2Colors.cyanDark),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: A2Colors.cyan, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_selected!.displayName,
                        style: const TextStyle(color: A2Colors.cyan, fontWeight: FontWeight.w900,
                            fontSize: 12))),
                    GestureDetector(
                      onTap: () => setState(() { _selected = null; _searchCtrl.clear(); }),
                      child: const Icon(Icons.close, color: A2Colors.gris1, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _kb,
                dropdownColor: A2Colors.card,
                style: const TextStyle(color: A2Colors.ambre, fontWeight: FontWeight.w900),
                decoration: const InputDecoration(labelText: 'Kettlebell (kg)'),
                items: [8, 12, 16, 20, 24, 28, 32, 36, 40].map((w) =>
                  DropdownMenuItem(value: w, child: Text('$w kg'))
                ).toList(),
                onChanged: (v) { if (v != null) setState(() => _kb = v); },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ANNULER', style: TextStyle(color: A2Colors.gris1)),
        ),
        TextButton(
          onPressed: (_selected == null || _enrolling) ? null : _enroll,
          child: _enrolling
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(color: A2Colors.cyan, strokeWidth: 2))
              : const Text('INSCRIRE', style: TextStyle(color: A2Colors.cyan, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}
