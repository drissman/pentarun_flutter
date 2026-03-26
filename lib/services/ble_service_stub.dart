// SPEC-KIT §6.2 — Phase 3 — Stub BLE Flutter Web (BLE non disponible sur navigateur)
import 'package:pentarun_flutter/models/hr_device.dart';
import 'package:pentarun_flutter/models/hr_sample.dart';

/// BLE non supporté sur Flutter Web — stub no-op
class BleServiceImpl {
  BleServiceImpl._();
  static final BleServiceImpl instance = BleServiceImpl._();

  /// Toujours false sur Web
  bool get isSupported => false;

  /// Retourne immédiatement une liste vide
  Stream<List<HrDevice>> scan({Duration timeout = const Duration(seconds: 10)}) =>
      Stream.value([]);

  Future<void> connect(String deviceId) async {}

  /// Flux vide — aucune mesure HR sur Web
  Stream<HrSample> get hrStream => const Stream.empty();

  /// Flux état connexion — toujours déconnecté
  Stream<bool> get connectionStream => Stream.value(false);

  Future<void> disconnect() async {}

  HrDevice? get connectedDevice => null;
}
