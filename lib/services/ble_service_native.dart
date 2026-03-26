// SPEC-KIT §6.2 — Phase 3 — Service BLE natif (Android / iOS)
// ─────────────────────────────────────────────────────────────────────────────
// ACTIVATION BUILD NATIF :
//   1. Ajouter dans pubspec.yaml :  flutter_blue_plus: ^1.35.0
//   2. Décommenter les imports ci-dessous
//   3. Remplacer le corps de chaque méthode par l'implémentation flutter_blue_plus
//   4. Compiler : flutter build apk --release  ou  flutter build ios --release
// ─────────────────────────────────────────────────────────────────────────────
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

import 'package:pentarun_flutter/models/hr_device.dart';
import 'package:pentarun_flutter/models/hr_sample.dart';

/// Service BLE natif — Heart Rate Service GATT 0x180D / Caractéristique 0x2A37
class BleServiceImpl {
  BleServiceImpl._();
  static final BleServiceImpl instance = BleServiceImpl._();

  bool get isSupported => true; // Disponible sur Android / iOS

  HrDevice? _connectedDevice;
  HrDevice? get connectedDevice => _connectedDevice;

  final _hrController = StreamController<HrSample>.broadcast();
  final _connController = StreamController<bool>.broadcast();

  // ── Scan ──────────────────────────────────────────────────────────────────
  /// Scan BLE — filtre Heart Rate Service UUID 0x180D
  Stream<List<HrDevice>> scan({Duration timeout = const Duration(seconds: 10)}) {
    // TODO (flutter_blue_plus) :
    //   await FlutterBluePlus.startScan(
    //     withServices: [Guid('0000180d-0000-1000-8000-00805f9b34fb')],
    //     timeout: timeout,
    //   );
    //   return FlutterBluePlus.scanResults.map((results) =>
    //     results.map((r) => HrDevice(id: r.device.remoteId.str, name: r.device.platformName, rssi: r.rssi)).toList()
    //   );
    return Stream.value([]);
  }

  // ── Connexion ─────────────────────────────────────────────────────────────
  Future<void> connect(String deviceId) async {
    // TODO (flutter_blue_plus) :
    //   final device = BluetoothDevice.fromId(deviceId);
    //   await device.connect(autoConnect: false);
    //   _connectedDevice = HrDevice(id: deviceId, name: device.platformName);
    //   _connController.add(true);
    //   await _subscribeHr(device);
  }

  // ── Lecture GATT 0x2A37 ───────────────────────────────────────────────────
  // ignore: unused_element
  Future<void> _subscribeHr(dynamic device) async {
    // TODO (flutter_blue_plus) :
    //   final services = await device.discoverServices();
    //   final hrService = services.firstWhere(
    //     (s) => s.uuid == Guid('0000180d-0000-1000-8000-00805f9b34fb'));
    //   final hrChar = hrService.characteristics.firstWhere(
    //     (c) => c.uuid == Guid('00002a37-0000-1000-8000-00805f9b34fb'));
    //   await hrChar.setNotifyValue(true);
    //   hrChar.lastValueStream.listen((data) {
    //     if (data.isEmpty) return;
    //     // Parsing GATT 0x2A37 (Bluetooth SIG spec)
    //     final flags = data[0];
    //     final bpm = (flags & 0x01) == 0 ? data[1] : (data[1] + (data[2] << 8));
    //     _hrController.add(HrSample(bpm: bpm, timestamp: DateTime.now()));
    //   });
  }

  Stream<HrSample> get hrStream => _hrController.stream;
  Stream<bool> get connectionStream => _connController.stream;

  Future<void> disconnect() async {
    // TODO (flutter_blue_plus) :
    //   await BluetoothDevice.fromId(_connectedDevice!.id).disconnect();
    _connectedDevice = null;
    _connController.add(false);
  }
}
