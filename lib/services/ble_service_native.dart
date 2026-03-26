// SPEC-KIT §6.2 — Phase 3 : BLE natif — flutter_blue_plus
// Compilé uniquement sur Android + iOS (dart.library.io)
// Exporté via ble_service.dart (conditional import)

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pentarun_flutter/models/hr_device.dart';
import 'package:pentarun_flutter/models/hr_sample.dart';

class BleServiceImpl {
  BleServiceImpl._();
  static final BleServiceImpl instance = BleServiceImpl._();

  bool get isSupported => true;

  HrDevice? _connectedDevice;
  HrDevice? get connectedDevice => _connectedDevice;

  final _hrController = StreamController<HrSample>.broadcast();
  final _connController = StreamController<bool>.broadcast();

  Stream<HrSample> get hrStream => _hrController.stream;
  Stream<bool> get connectionStream => _connController.stream;

  // ─── Scan ─────────────────────────────────────────────────────────────────
  // Filtre sur le service Heart Rate GATT 0x180D uniquement
  Stream<List<HrDevice>> scan({
    Duration timeout = const Duration(seconds: 10),
  }) {
    // startScan est intentionnellement non-awaité : il s'arrête après timeout
    FlutterBluePlus.startScan(
      withServices: [Guid('0000180d-0000-1000-8000-00805f9b34fb')],
      timeout: timeout,
    );
    return FlutterBluePlus.scanResults.map((results) => results
        .map((r) => HrDevice(
              id: r.device.remoteId.str,
              name: r.device.platformName,
              rssi: r.rssi,
            ))
        .toList());
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  // ─── Connect ──────────────────────────────────────────────────────────────
  Future<void> connect(String deviceId) async {
    final device = BluetoothDevice.fromId(deviceId);
    await device.connect(autoConnect: false);
    _connectedDevice = HrDevice(id: deviceId, name: device.platformName);
    _connController.add(true);
    await _subscribeHr(device);
  }

  // Découverte du service HR + souscription aux notifications GATT
  Future<void> _subscribeHr(BluetoothDevice device) async {
    final services = await device.discoverServices();
    final hrService = services.firstWhere(
      (s) => s.uuid == Guid('0000180d-0000-1000-8000-00805f9b34fb'),
    );
    final hrChar = hrService.characteristics.firstWhere(
      (c) => c.uuid == Guid('00002a37-0000-1000-8000-00805f9b34fb'),
    );
    await hrChar.setNotifyValue(true);
    // Décodage paquet HR GATT : bit 0 du flags = format (uint8 ou uint16)
    hrChar.lastValueStream.listen((data) {
      if (data.isEmpty) return;
      final flags = data[0];
      final bpm = (flags & 0x01) == 0
          ? data[1]
          : data[1] + (data[2] << 8);
      _hrController.add(HrSample(bpm: bpm, timestamp: DateTime.now()));
    });
  }

  // ─── Disconnect ───────────────────────────────────────────────────────────
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await BluetoothDevice.fromId(_connectedDevice!.id).disconnect();
    }
    _connectedDevice = null;
    _connController.add(false);
  }

  void dispose() {
    _hrController.close();
    _connController.close();
  }
}
