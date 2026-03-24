class Kettlebell {
  Kettlebell._();

  static const Map<int, double> coefficients = {
    4: 1.050,
    6: 1.025,
    8: 1.000,
    10: 0.975,
    12: 0.950,
    14: 0.925,
    16: 0.900,
    18: 0.875,
    20: 0.850,
    22: 0.825,
    24: 0.800,
    26: 0.775,
    28: 0.750,
    30: 0.725,
    32: 0.700,
    34: 0.675,
    36: 0.650,
    40: 0.600,
  };

  static List<int> get weights => coefficients.keys.toList();

  static double coeffFor(int weightKg) => coefficients[weightKg] ?? 1.0;
}
