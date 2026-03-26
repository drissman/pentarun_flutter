// SPEC-KIT §6.2–6.5 — Phase 3 — Gestionnaire de session cardio
// Singleton : tampon d'échantillons HR sur la durée d'une vague
import 'dart:async';

import 'package:pentarun_flutter/engine/hr_calculator.dart';
import 'package:pentarun_flutter/models/hr_device.dart';
import 'package:pentarun_flutter/models/hr_metrics.dart';
import 'package:pentarun_flutter/models/hr_sample.dart';
import 'package:pentarun_flutter/services/ble_service.dart';

class HrSessionService {
  HrSessionService._();
  static final HrSessionService instance = HrSessionService._();

  final _ble = BleServiceImpl.instance;
  StreamSubscription<HrSample>? _subscription;
  StreamSubscription<bool>? _connSubscription;

  final _samples = <HrSample>[];
  final _bpmController = StreamController<int>.broadcast();
  bool _connected = false;

  bool get bleSupported => _ble.isSupported;
  bool get connected => _connected;
  HrDevice? get device => _ble.connectedDevice;

  /// Flux BPM temps réel (pour affichage live pendant la course)
  Stream<int> get bpmStream => _bpmController.stream;

  // ─── Scan et connexion ────────────────────────────────────────────────────

  Stream<List<HrDevice>> scan({Duration timeout = const Duration(seconds: 10)}) =>
      _ble.scan(timeout: timeout);

  Future<void> connect(String deviceId) async {
    await _ble.connect(deviceId);
    _connSubscription?.cancel();
    _connSubscription = _ble.connectionStream.listen((v) {
      _connected = v;
    });
    _subscription?.cancel();
    _subscription = _ble.hrStream.listen((s) {
      _samples.add(s);
      _bpmController.add(s.bpm);
    });
  }

  Future<void> disconnect() async {
    await _ble.disconnect();
    _subscription?.cancel();
    _subscription = null;
    _connected = false;
  }

  // ─── Gestion du tampon ────────────────────────────────────────────────────

  /// Vide le tampon en début de vague
  void resetBuffer() => _samples.clear();

  int get sampleCount => _samples.length;

  // ─── Calcul métriques ─────────────────────────────────────────────────────

  /// Calcule les métriques HR avec les échantillons accumulés.
  /// Retourne null si < 10 échantillons (données insuffisantes).
  HrMetrics? computeMetrics({
    required double coeffAge,
    required double coeffSexe,
  }) =>
      HrCalculator.compute(
        samples: List.unmodifiable(_samples),
        coeffAge: coeffAge,
        coeffSexe: coeffSexe,
      );
}
