// SPEC-KIT §5.5 — Différentiel force/endurance homme/femme
// Base : PENTARUN ≈ 70% force KB + 30% aérobie → différentiel combiné ≈ 87%

enum Sex {
  homme,
  femme;

  String get label => this == homme ? 'HOMME' : 'FEMME';

  // SPEC-KIT §5.5 — coeff_sexe
  double get coeff => this == homme ? 1.000 : 0.870;

  // SPEC-KIT §5.5 — schéma SQL : CHECK (sexe IN ('HOMME', 'FEMME'))
  String get dbValue => name.toUpperCase(); // 'HOMME' ou 'FEMME'

  static Sex fromDb(String value) =>
      Sex.values.firstWhere((s) => s.name == value.toLowerCase());
}
