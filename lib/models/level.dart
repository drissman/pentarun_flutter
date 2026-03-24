enum Level {
  decouverte,
  actif,
  challenger,
  elite,
  titan;

  String get label {
    switch (this) {
      case Level.decouverte:
        return 'DÉCOUVERTE';
      case Level.actif:
        return 'ACTIF';
      case Level.challenger:
        return 'CHALLENGER';
      case Level.elite:
        return 'ELITE';
      case Level.titan:
        return 'TITAN';
    }
  }

  double get runDistKm {
    switch (this) {
      case Level.decouverte:
        return 1.0;
      case Level.actif:
        return 1.5;
      case Level.challenger:
        return 2.0;
      case Level.elite:
        return 3.0;
      case Level.titan:
        return 4.0;
    }
  }

  int get repsPerStation {
    switch (this) {
      case Level.decouverte:
        return 15;
      case Level.actif:
        return 20;
      case Level.challenger:
        return 30;
      case Level.elite:
        return 40;
      case Level.titan:
        return 60;
    }
  }

  static Level fromLabel(String label) {
    return Level.values.firstWhere((l) => l.label == label);
  }
}
