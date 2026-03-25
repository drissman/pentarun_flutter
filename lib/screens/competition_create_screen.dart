// SPEC-KIT §7.1 — Phase 2.2 — Création compétition (organisateur)
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/competition.dart';
import 'package:pentarun_flutter/services/competition_service.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class CompetitionCreateScreen extends StatefulWidget {
  const CompetitionCreateScreen({super.key});

  @override
  State<CompetitionCreateScreen> createState() => _CompetitionCreateScreenState();
}

class _CompetitionCreateScreenState extends State<CompetitionCreateScreen> {
  final _nomCtrl  = TextEditingController();
  final _lieuCtrl = TextEditingController();
  DateTime _date  = DateTime.now().add(const Duration(days: 7));
  bool _loading   = false;
  String? _error;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _lieuCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: A2Colors.cyan,
            onSurface: A2Colors.blanc,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _create() async {
    final nom  = _nomCtrl.text.trim();
    final lieu = _lieuCtrl.text.trim();
    if (nom.isEmpty || lieu.isEmpty) {
      setState(() => _error = 'Nom et lieu obligatoires.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final competition = await CompetitionService.createCompetition(
        nom: nom,
        lieu: lieu,
        dateEvent: _date,
      );
      if (mounted) Navigator.of(context).pop<Competition>(competition);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
          'NOUVELLE COMPÉTITION',
          style: TextStyle(
            color: A2Colors.blanc,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section('INFORMATIONS'),
              TextField(
                controller: _nomCtrl,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: A2Colors.blanc),
                decoration: const InputDecoration(labelText: 'Nom de la compétition'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lieuCtrl,
                style: const TextStyle(color: A2Colors.blanc),
                decoration: const InputDecoration(labelText: 'Lieu (ville, salle...)'),
              ),
              const SizedBox(height: 16),

              // Sélecteur date
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: A2Colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: A2Colors.border2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DATE', style: TextStyle(
                            color: A2Colors.gris1, fontSize: 10,
                            fontWeight: FontWeight.w700, letterSpacing: 1.5,
                          )),
                          const SizedBox(height: 2),
                          Text(
                            '${_date.day.toString().padLeft(2,'0')}/'
                            '${_date.month.toString().padLeft(2,'0')}/'
                            '${_date.year}',
                            style: const TextStyle(
                              color: A2Colors.blanc, fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today, color: A2Colors.gris1, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (_error != null) ...[
                Text(_error!, style: const TextStyle(
                  color: A2Colors.rouge, fontSize: 11, fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 16),
              ],

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _create,
                  style: _loading
                      ? ElevatedButton.styleFrom(
                          backgroundColor: A2Colors.cyanDark,
                          foregroundColor: A2Colors.blanc,
                        )
                      : null,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: A2Colors.blanc, strokeWidth: 2))
                      : const Text('CRÉER LA COMPÉTITION',
                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(label, style: const TextStyle(
      color: A2Colors.gris1, fontSize: 10,
      fontWeight: FontWeight.w900, letterSpacing: 2,
    )),
  );
}
