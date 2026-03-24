enum Station {
  s1,
  s2,
  s3,
  s4,
  s5;

  String get label {
    switch (this) {
      case Station.s1:
        return 'S1 — Run + Double Clean';
      case Station.s2:
        return 'S2 — Run + Double LC Press';
      case Station.s3:
        return 'S3 — Run + Double Jerk';
      case Station.s4:
        return 'S4 — Run + Double Half Snatch';
      case Station.s5:
        return 'S5 — Run + Double Push Press';
    }
  }

  static const int count = 5;

  static String labelAt(int index) {
    return Station.values[index].label;
  }
}
