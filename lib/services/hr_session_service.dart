// SPEC-KIT §6.2–6.5 — Phase 3 — Gestionnaire de session cardio
// Singleton : tampon d'échantillons HR sur la durée d'une vague
import 'dart:async';
import 'dart:math';

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

  // ─── Auto-reconnect ───────────────────────────────────────────────────────
  String? _lastDeviceId;      // ID du dernier appareil connecté
  bool _manualDisconnect = false; // true = déconnexion voulue → pas de reconnect
  int _reconnectAttempts = 0;
  static const _maxReconnectAttempts = 5;
  Timer? _reconnectTimer;

  // ─── Mode simulation ──────────────────────────────────────────────────────
  bool _simMode = false;
  Timer? _simTimer;
  int _simStep = 0;
  final _rng = Random();

  bool get simMode => _simMode;

  bool get bleSupported => _ble.isSupported;
  bool get connected => _connected;
  HrDevice? get device =>
      _simMode ? HrDevice(id: 'sim', name: 'POLAR H10 (SIM)') : _ble.connectedDevice;

  /// Flux BPM temps réel (pour affichage live pendant la course)
  Stream<int> get bpmStream => _bpmController.stream;

  // ─── Scan et connexion ────────────────────────────────────────────────────

  Stream<List<HrDevice>> scan({Duration timeout = const Duration(seconds: 10)}) =>
      _ble.scan(timeout: timeout);

  Future<void> connect(String deviceId) async {
    _manualDisconnect = false;
    _lastDeviceId = deviceId;
    _reconnectAttempts = 0;
    // Souscrire AVANT connect() pour ne pas manquer l'événement true
    _connSubscription?.cancel();
    _connSubscription = _ble.connectionStream.listen((v) {
      _connected = v;
      if (!v && !_manualDisconnect) _scheduleReconnect();
    });
    _subscription?.cancel();
    _subscription = _ble.hrStream.listen((s) {
      _samples.add(s);
      _bpmController.add(s.bpm);
    });
    await _ble.connect(deviceId);
    _connected = true; // Garantie si l'événement stream est manqué
  }

  void _scheduleReconnect() {
    if (_lastDeviceId == null) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    // Délai croissant : 2s, 4s, 6s, 8s, 10s
    final delay = Duration(seconds: _reconnectAttempts * 2);
    _reconnectTimer = Timer(delay, () async {
      if (_manualDisconnect || _connected) return;
      try {
        await _ble.connect(_lastDeviceId!);
        _connected = true;
        _reconnectAttempts = 0;
      } catch (_) {
        // Échec → prochain essai via connectionStream
      }
    });
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _lastDeviceId = null;
    await _ble.disconnect();
    _subscription?.cancel();
    _subscription = null;
    _connected = false;
  }

  // ─── Simulation HR ────────────────────────────────────────────────────────

  /// Démarre une simulation cardio réaliste (sans BLE).
  /// BPM : montée de 80→155 en 90 sec, puis maintien avec bruit ±8.
  void startSimulation() {
    _simMode = true;
    _connected = true;
    _simStep = 0;
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _simStep++;
      final base = _simStep < 90 ? 80 + _simStep : 155;
      final noise = _rng.nextInt(17) - 8;
      final bpm = (base + noise).clamp(60, 200);
      final sample = HrSample(bpm: bpm, timestamp: DateTime.now());
      _samples.add(sample);
      _bpmController.add(bpm);
    });
  }

  void stopSimulation() {
    _simTimer?.cancel();
    _simTimer = null;
    _simMode = false;
    _connected = false;
    _simStep = 0;
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
