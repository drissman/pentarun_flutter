// SPEC-KIT §3.2 — Formulaire ajout athlète (mode juge + recherche profil)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pentarun_flutter/models/athlete_profile.dart';
import 'package:pentarun_flutter/models/kettlebell.dart';
import 'package:pentarun_flutter/models/level.dart';
import 'package:pentarun_flutter/models/sex.dart';
import 'package:pentarun_flutter/services/profile_service.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class AthleteForm extends StatefulWidget {
  const AthleteForm({super.key});

  @override
  State<AthleteForm> createState() => _AthleteFormState();
}

class _AthleteFormState extends State<AthleteForm> {
  late TextEditingController _nameController;
  late TextEditingController _searchController;

  // Résultats de recherche profil
  List<AthleteProfile> _searchResults = [];
  AthleteProfile? _linkedProfile;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _submit(AppState state) {
    state.updateFormName(_nameController.text);
    state.addAthlete();
    _nameController.clear();
    _searchController.clear();
    setState(() { _searchResults = []; _linkedProfile = null; });
  }

  Future<void> _search(String query, AppState state) async {
    if (query.trim().length < 2) {
      setState(() { _searchResults = []; _searching = false; });
      return;
    }
    setState(() => _searching = true);
    try {
      final results = await ProfileService.searchByName(query);
      if (mounted) setState(() { _searchResults = results; _searching = false; });
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _selectProfile(AthleteProfile profile, AppState state) {
    setState(() {
      _linkedProfile = profile;
      _searchResults = [];
      _searchController.clear();
      _nameController.text = profile.displayName;
    });
    state.updateFormName(profile.displayName);
    state.updateFormLevel(profile.niveauHabituel);
    state.updateFormKb(profile.kbHabituelKg);
    state.updateFormWeight(profile.poidsKg);
    state.updateFormHeight(profile.tailleCm);
    state.updateFormSexe(profile.sexe);
    state.updateFormDateNaissance(profile.dateNaissance);
    state.updateFormProfileId(profile.id);
  }

  void _clearProfile(AppState state) {
    setState(() { _linkedProfile = null; });
    _nameController.clear();
    state.updateFormProfileId(null);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: A2Colors.surfaceDark,
        border: Border.all(color: A2Colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Recherche profil ──────────────────────────────────────────────
          if (_linkedProfile == null) ...[
            _sectionLabel('RECHERCHE PROFIL ATHLÈTE'),
            const SizedBox(height: 6),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: A2Colors.blanc, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Nom ou prénom…',
                prefixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              color: A2Colors.cyan, strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search, color: A2Colors.gris1, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: A2Colors.gris1, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
              ),
              onChanged: (v) => _search(v, state),
            ),
            // Résultats
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: A2Colors.surface,
                  border: Border.all(color: A2Colors.border2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _searchResults.map((p) => InkWell(
                    onTap: () => _selectProfile(p, state),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.displayName,
                                    style: const TextStyle(
                                      color: A2Colors.blanc,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    )),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.ageCategory.label} · ${p.sexe.label} · ${p.niveauHabituel.label} · ${p.kbHabituelKg} kg KB',
                                  style: const TextStyle(
                                    color: A2Colors.gris1,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.link, color: A2Colors.cyan, size: 16),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: A2Colors.border2),
            const SizedBox(height: 12),
            _sectionLabel('OU SAISIE MANUELLE (MODE JUGE)'),
            const SizedBox(height: 8),
          ] else ...[
            // Profil lié — badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: A2Colors.cyan.withValues(alpha: 0.08),
                border: Border.all(color: A2Colors.cyan.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_pin, color: A2Colors.cyan, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_linkedProfile!.displayName,
                            style: const TextStyle(
                              color: A2Colors.cyan,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            )),
                        Text(
                          '${_linkedProfile!.ageCategory.label} · ${_linkedProfile!.sexe.label}'
                          ' · coeff age ${_linkedProfile!.coeffAge.toStringAsFixed(3)}'
                          ' · coeff sexe ${_linkedProfile!.coeffSexe.toStringAsFixed(3)}',
                          style: const TextStyle(
                            color: A2Colors.gris1, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.link_off, color: A2Colors.gris1, size: 16),
                    tooltip: 'Dissocier le profil',
                    onPressed: () => _clearProfile(state),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Champs manuels ────────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              // Auto-adaptatif : 1 col tous les ~180dp disponibles (min 1, max 6)
              final crossCount = (constraints.maxWidth / 180).floor().clamp(1, 6);
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _field(
                    label: 'ATHLÈTE',
                    width: _itemWidth(constraints.maxWidth, crossCount),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: A2Colors.blanc,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      decoration: const InputDecoration(hintText: 'NOM'),
                      onSubmitted: (_) => _submit(state),
                    ),
                  ),
                  _field(
                    label: 'NIVEAU',
                    width: _itemWidth(constraints.maxWidth, crossCount),
                    child: DropdownButtonFormField<Level>(
                      initialValue: state.formLevel,
                      dropdownColor: A2Colors.surface,
                      style: const TextStyle(
                        color: A2Colors.blanc,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      items: Level.values
                          .map((l) => DropdownMenuItem(value: l, child: Text(l.label)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) state.updateFormLevel(v);
                      },
                    ),
                  ),
                  _field(
                    label: 'ACIER TOTAL 2 KB (KG)',
                    width: _itemWidth(constraints.maxWidth, crossCount),
                    child: DropdownButtonFormField<int>(
                      initialValue: state.formKb,
                      dropdownColor: A2Colors.surface,
                      style: const TextStyle(
                        color: A2Colors.cyan,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      items: Kettlebell.weights
                          .map((w) => DropdownMenuItem(value: w, child: Text(w.toString())))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) state.updateFormKb(v);
                      },
                    ),
                  ),
                  _field(
                    label: 'TAILLE (CM)',
                    width: _itemWidth(constraints.maxWidth, crossCount),
                    child: TextField(
                      controller: TextEditingController(text: state.formHeight.toString()),
                      style: const TextStyle(
                        color: A2Colors.ambre,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null) state.updateFormHeight(n);
                      },
                    ),
                  ),
                  _field(
                    label: 'POIDS (KG)',
                    width: _itemWidth(constraints.maxWidth, crossCount),
                    child: TextField(
                      controller: TextEditingController(text: state.formWeight.toString()),
                      style: const TextStyle(
                        color: A2Colors.ambre,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null) state.updateFormWeight(n);
                      },
                    ),
                  ),
                  // SPEC-KIT §5.2 — Sexe (pour coeff plateforme)
                  _field(
                    label: 'SEXE',
                    width: _itemWidth(constraints.maxWidth, crossCount),
                    child: Row(
                      children: Sex.values.map((s) => Expanded(
                        child: GestureDetector(
                          onTap: () => state.updateFormSexe(s),
                          child: Container(
                            margin: EdgeInsets.only(right: s == Sex.homme ? 6 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: state.formSexe == s
                                  ? A2Colors.cyanDark
                                  : A2Colors.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: A2Colors.border2),
                            ),
                            child: Text(
                              s.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: state.formSexe == s
                                    ? Colors.black
                                    : A2Colors.gris1,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  SizedBox(
                    width: _itemWidth(constraints.maxWidth, crossCount),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _submit(state),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'AJOUTER',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  double _itemWidth(double total, int cols) => (total - (cols - 1) * 12) / cols;

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: A2Colors.gris1,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
    ),
  );

  Widget _field({
    required String label,
    required double width,
    required Widget child,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: A2Colors.gris1,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
