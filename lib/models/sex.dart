// SPEC-KIT §5.5 — Différentiel force/endurance homme/femme
// Base : PENTARUN ≈ 70% force KB + 30% aérobie → différentiel combiné ≈ 87%

enum Sex {
  homme,
  femme;

  String get label => this == homme ? 'HOMME' : 'FEMME';

  // SPEC-KIT §5.5 — coeff_sexe
  double get coeff => this == homme ? 1.000 : 0.870;

  String get dbValue => name; // 'homme' ou 'femme'

  static Sex fromDb(String value) =>
      Sex.values.firstWhere((s) => s.name == value);
}
