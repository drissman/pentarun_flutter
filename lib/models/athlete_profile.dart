// SPEC-KIT §3.3 / §4.1 — Profil athlète persistant (Supabase)
import 'package:pentarun_flutter/models/age_category.dart';
import 'package:pentarun_flutter/models/level.dart';
import 'package:pentarun_flutter/models/sex.dart';

class AthleteProfile {
  final String id;         // UUID Supabase
  final String authId;     // UUID Supabase Auth
  final String nom;
  final String prenom;
  final Sex sexe;
  final DateTime dateNaissance;
  final int poidsKg;
  final int tailleCm;
  final Level niveauHabituel;
  final int kbHabituelKg;
  final DateTime createdAt;

  const AthleteProfile({
    required this.id,
    required this.authId,
    required this.nom,
    required this.prenom,
    required this.sexe,
    required this.dateNaissance,
    required this.poidsKg,
    required this.tailleCm,
    required this.niveauHabituel,
    required this.kbHabituelKg,
    required this.createdAt,
  });

  // SPEC-KIT §4.2 — Catégorie d'âge calculée dynamiquement
  int get age {
    final now = DateTime.now();
    int age = now.year - dateNaissance.year;
    if (now.month < dateNaissance.month ||
        (now.month == dateNaissance.month && now.day < dateNaissance.day)) {
      age--;
    }
    return age;
  }

  AgeCategory get ageCategory => AgeCategory.fromAge(age);

  // SPEC-KIT §5.4 — coeff_age depuis catégorie
  double get coeffAge => ageCategory.coeff;

  // SPEC-KIT §5.5 — coeff_sexe
  double get coeffSexe => sexe.coeff;

  String get displayName => '$prenom $nom'.toUpperCase();

  /// Profil vide — utilisé comme sentinelle "profil créé mais non chargé"
  factory AthleteProfile.empty() => AthleteProfile(
    id: '', authId: '', nom: '', prenom: '',
    sexe: Sex.homme,
    dateNaissance: DateTime(1990),
    poidsKg: 75, tailleCm: 175,
    niveauHabituel: Level.challenger,
    kbHabituelKg: 24,
    createdAt: DateTime.now(),
  );

  factory AthleteProfile.fromJson(Map<String, dynamic> json) {
    return AthleteProfile(
      id: json['id'] as String,
      authId: json['auth_id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      sexe: Sex.fromDb(json['sexe'] as String),
      dateNaissance: DateTime.parse(json['date_naissance'] as String),
      poidsKg: json['poids_kg'] as int,
      tailleCm: json['taille_cm'] as int,
      niveauHabituel: Level.fromLabel(json['niveau_habituel'] as String),
      kbHabituelKg: json['kb_habituel_kg'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'auth_id': authId,
    'nom': nom,
    'prenom': prenom,
    'sexe': sexe.dbValue,
    'date_naissance': dateNaissance.toIso8601String().substring(0, 10),
    'poids_kg': poidsKg,
    'taille_cm': tailleCm,
    'niveau_habituel': niveauHabituel.label,
    'kb_habituel_kg': kbHabituelKg,
  };
}
