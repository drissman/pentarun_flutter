import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pentarun_flutter/models/kettlebell.dart';
import 'package:pentarun_flutter/models/level.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class AthleteForm extends StatefulWidget {
  const AthleteForm({super.key});

  @override
  State<AthleteForm> createState() => _AthleteFormState();
}

class _AthleteFormState extends State<AthleteForm> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit(AppState state) {
    state.updateFormName(_nameController.text);
    state.addAthlete();
    _nameController.clear();
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossCount = constraints.maxWidth > 800
              ? 6
              : constraints.maxWidth > 500
                  ? 3
                  : 2;
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
                      .map((l) =>
                          DropdownMenuItem(value: l, child: Text(l.label)))
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
                      .map((w) => DropdownMenuItem(
                          value: w, child: Text(w.toString())))
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
                  controller:
                      TextEditingController(text: state.formHeight.toString()),
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
                  controller:
                      TextEditingController(text: state.formWeight.toString()),
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
              SizedBox(
                width: _itemWidth(constraints.maxWidth, crossCount),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18), // align with label space
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
    );
  }

  double _itemWidth(double total, int cols) {
    return (total - (cols - 1) * 12) / cols;
  }

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
              color: A2Colors.gris2,
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
