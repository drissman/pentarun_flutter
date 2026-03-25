// SPEC-KIT §3.3 — Écran création / édition profil athlète
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/age_category.dart';
import 'package:pentarun_flutter/models/athlete_profile.dart';
import 'package:pentarun_flutter/models/kettlebell.dart';
import 'package:pentarun_flutter/models/level.dart';
import 'package:pentarun_flutter/models/sex.dart';
import 'package:pentarun_flutter/services/auth_service.dart';
import 'package:pentarun_flutter/services/profile_service.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class ProfileScreen extends StatefulWidget {
  final AthleteProfile? existing;
  /// Appelé après création du profil (première connexion).
  /// Si null, utilise Navigator.pop() (mode édition depuis nav stack).
  final VoidCallback? onSaved;
  const ProfileScreen({super.key, this.existing, this.onSaved});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nomCtrl    = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _poidsCtrl  = TextEditingController();
  final _tailleCtrl = TextEditingController();

  Sex _sexe = Sex.homme;
  DateTime _dateNaissance = DateTime(1990, 1, 1);
  Level _niveau = Level.challenger;
  int _kbHabituel = 24;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final p = widget.existing!;
      _nomCtrl.text    = p.nom;
      _prenomCtrl.text = p.prenom;
      _poidsCtrl.text  = p.poidsKg.toString();
      _tailleCtrl.text = p.tailleCm.toString();
      _sexe            = p.sexe;
      _dateNaissance   = p.dateNaissance;
      _niveau          = p.niveauHabituel;
      _kbHabituel      = p.kbHabituelKg;
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _poidsCtrl.dispose();
    _tailleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance,
      firstDate: DateTime(1930),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
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
    if (picked != null) setState(() => _dateNaissance = picked);
  }

  Future<void> _save() async {
    final nom    = _nomCtrl.text.trim().toUpperCase();
    final prenom = _prenomCtrl.text.trim().toUpperCase();
    final poids  = int.tryParse(_poidsCtrl.text.trim());
    final taille = int.tryParse(_tailleCtrl.text.trim());

    if (nom.isEmpty || prenom.isEmpty || poids == null || taille == null) {
      setState(() => _error = 'Tous les champs sont obligatoires.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final user = AuthService.currentUser!;
      final profile = AthleteProfile(
        id: widget.existing?.id ?? '',
        authId: user.id,
        nom: nom,
        prenom: prenom,
        sexe: _sexe,
        dateNaissance: _dateNaissance,
        poidsKg: poids,
        tailleCm: taille,
        niveauHabituel: _niveau,
        kbHabituelKg: _kbHabituel,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
      );
      if (widget.existing == null) {
        await ProfileService.createProfile(profile);
        if (mounted) {
          if (widget.onSaved != null) {
            widget.onSaved!();
          } else {
            Navigator.of(context).pop(true);
          }
        }
      } else {
        await ProfileService.updateProfile(profile);
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // SPEC-KIT §4.2 — Catégorie d'âge calculée en direct
    final age = DateTime.now().year - _dateNaissance.year;
    final cat = AgeCategory.fromAge(age);

    return Scaffold(
      backgroundColor: A2Colors.bg,
      appBar: AppBar(
        backgroundColor: A2Colors.card,
        title: Text(
          widget.existing == null ? 'MON PROFIL' : 'MODIFIER MON PROFIL',
          style: const TextStyle(
            color: A2Colors.blanc,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 15,
          ),
        ),
        leading: widget.existing != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: A2Colors.gris1),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section('IDENTITÉ'),
              _field('Prénom', _prenomCtrl),
              const SizedBox(height: 12),
              _field('Nom', _nomCtrl),
              const SizedBox(height: 24),

              _section('PROFIL PHYSIOLOGIQUE'),
              // Sexe
              Row(
                children: Sex.values.map((s) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _sexe = s),
                    child: Container(
                      margin: EdgeInsets.only(right: s == Sex.homme ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _sexe == s ? A2Colors.cyanDark : A2Colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: A2Colors.border2),
                      ),
                      child: Text(
                        s.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _sexe == s ? Colors.black : A2Colors.gris1,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),

              // Date naissance
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                          const Text('DATE DE NAISSANCE',
                              style: TextStyle(color: A2Colors.gris1, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                          const SizedBox(height: 2),
                          Text(
                            '${_dateNaissance.day.toString().padLeft(2,'0')}/'
                            '${_dateNaissance.month.toString().padLeft(2,'0')}/'
                            '${_dateNaissance.year}',
                            style: const TextStyle(color: A2Colors.blanc, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      // Badge catégorie d'âge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: A2Colors.cyanDark.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: A2Colors.cyan.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '${cat.label} · ${cat.ageRange}',
                          style: const TextStyle(color: A2Colors.cyan, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _field('Poids (kg)', _poidsCtrl, numeric: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Taille (cm)', _tailleCtrl, numeric: true)),
                ],
              ),
              const SizedBox(height: 24),

              _section('NIVEAU HABITUEL'),
              DropdownButtonFormField<Level>(
                value: _niveau,
                dropdownColor: A2Colors.card,
                style: const TextStyle(color: A2Colors.cyan, fontWeight: FontWeight.w900),
                decoration: const InputDecoration(labelText: 'Niveau'),
                items: Level.values.map((l) => DropdownMenuItem(
                  value: l,
                  child: Text(l.label),
                )).toList(),
                onChanged: (v) { if (v != null) setState(() => _niveau = v); },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _kbHabituel,
                dropdownColor: A2Colors.card,
                style: const TextStyle(color: A2Colors.ambre, fontWeight: FontWeight.w900),
                decoration: const InputDecoration(labelText: 'KB habituel (kg total 2 KB)'),
                items: Kettlebell.weights.map((w) => DropdownMenuItem(
                  value: w,
                  child: Text('$w kg — coeff ${Kettlebell.coeffFor(w).toStringAsFixed(3)}'),
                )).toList(),
                onChanged: (v) { if (v != null) setState(() => _kbHabituel = v); },
              ),
              const SizedBox(height: 32),

              // Erreur
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: A2Colors.rouge, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
              ],

              // Bouton sauvegarder
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: _loading
                      ? ElevatedButton.styleFrom(
                          backgroundColor: A2Colors.cyanDark,
                          foregroundColor: A2Colors.blanc,
                        )
                      : null,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: A2Colors.blanc, strokeWidth: 2))
                      : const Text('SAUVEGARDER MON PROFIL',
                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
              ),

              if (widget.existing != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await AuthService.signOut();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('SE DÉCONNECTER',
                    style: TextStyle(color: A2Colors.rouge, fontSize: 11,
                        fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: const TextStyle(
        color: A2Colors.gris1,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      )),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool numeric = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: A2Colors.blanc),
      decoration: InputDecoration(labelText: label),
    );
  }
}
