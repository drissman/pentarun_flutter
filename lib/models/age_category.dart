// SPEC-KIT §4.2 — Catégories d'âge OPENSPEC v2.0
// SPEC-KIT §5.4 — coeff_age basé sur déclin VO2max (Tanaka & Seals 2003)

enum AgeCategory {
  junior,
  espoir,
  senior,
  master1,
  master2,
  master3;

  // SPEC-KIT §4.2 — Déduction catégorie depuis l'âge
  static AgeCategory fromAge(int age) {
    if (age < 18) return junior;
    if (age <= 21) return espoir;
    if (age <= 39) return senior;
    if (age <= 49) return master1;
    if (age <= 59) return master2;
    return master3;
  }

  String get label {
    switch (this) {
      case junior:  return 'JUNIOR';
      case espoir:  return 'ESPOIR';
      case senior:  return 'SENIOR';
      case master1: return 'MASTER 1';
      case master2: return 'MASTER 2';
      case master3: return 'MASTER 3';
    }
  }

  String get ageRange {
    switch (this) {
      case junior:  return '< 18 ans';
      case espoir:  return '18 – 21 ans';
      case senior:  return '22 – 39 ans';
      case master1: return '40 – 49 ans';
      case master2: return '50 – 59 ans';
      case master3: return '60 ans et +';
    }
  }

  // SPEC-KIT §5.4 — coeff_age : déclin VO2max Tanaka & Seals (2003)
  double get coeff {
    switch (this) {
      case junior:  return 0.980; // Développement physique en cours
      case espoir:  return 0.990; // Proche du pic VO2max
      case senior:  return 1.000; // Référence — pic VO2max
      case master1: return 0.915; // ~8–10% déclin VO2max
      case master2: return 0.855; // ~15–20% déclin VO2max
      case master3: return 0.775; // ~25–35% déclin VO2max
    }
  }
}
