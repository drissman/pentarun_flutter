// SPEC-KIT §6.2 — Phase 3 : BLE natif — flutter_blue_plus
// Compilé uniquement sur Android + iOS (dart.library.io)
// Exporté via ble_service.dart (conditional import)

import 'dart:async';
import 'package:flutter/foundation.dart';
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
  // Le stream se ferme via timer après timeout + 1s de marge
  Stream<List<HrDevice>> scan({
    Duration timeout = const Duration(seconds: 10),
  }) {
    final controller = StreamController<List<HrDevice>>();
    StreamSubscription? resultsSub;

    // Scan sans filtre UUID : le Polar H10 n'inclut pas toujours 0x180D
    // dans son paquet d'annonce. On filtre par nom côté app après le scan.
    FlutterBluePlus.startScan(timeout: timeout);

    resultsSub = FlutterBluePlus.scanResults.listen((results) {
      if (!controller.isClosed) {
        final hrDevices = results
            .where((r) {
              final name = r.device.platformName.toLowerCase();
              final uuids = r.advertisementData.serviceUuids
                  .map((u) => u.toString().toLowerCase())
                  .toList();
              // Garder si nom contient polar/garmin/h10/h7, ou si UUID HR présent
              return name.contains('polar') ||
                  name.contains('garmin') ||
                  name.contains('h10') ||
                  name.contains('h7') ||
                  uuids.any((u) => u.contains('180d'));
            })
            .map((r) => HrDevice(
                  id: r.device.remoteId.str,
                  name: r.device.platformName,
                  rssi: r.rssi,
                ))
            .toList();
        controller.add(hrDevices);
      }
    });

    Future.delayed(timeout + const Duration(seconds: 1), () async {
      await FlutterBluePlus.stopScan();
      await resultsSub?.cancel();
      if (!controller.isClosed) controller.close();
    });

    return controller.stream;
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  // ─── Connect ──────────────────────────────────────────────────────────────
  Future<void> connect(String deviceId) async {
    final device = BluetoothDevice.fromId(deviceId);
    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      // requestMtu timeout sur certains appareils Android (Huawei) — non bloquant
      debugPrint('[BLE] connect warning: $e');
    }
    _connectedDevice = HrDevice(id: deviceId, name: device.platformName);
    _connController.add(true);
    try {
      await _subscribeHr(device);
    } catch (e) {
      debugPrint('[BLE] _subscribeHr failed: $e');
    }
  }

  // Découverte du service HR + souscription aux notifications GATT
  Future<void> _subscribeHr(BluetoothDevice device) async {
    final services = await device.discoverServices();
    debugPrint('[BLE] Services découverts: ${services.map((s) => s.uuid).toList()}');

    // Cherche le service HR (UUID court 180d ou UUID complet)
    final hrService = services.firstWhere(
      (s) => s.uuid.toString().toLowerCase().contains('180d'),
      orElse: () => throw Exception('Service HR 0x180D non trouvé'),
    );
    debugPrint('[BLE] Service HR trouvé: ${hrService.uuid}');

    final hrChar = hrService.characteristics.firstWhere(
      (c) => c.uuid.toString().toLowerCase().contains('2a37'),
      orElse: () => throw Exception('Caractéristique HR 0x2A37 non trouvée'),
    );
    debugPrint('[BLE] Caractéristique HR trouvée: ${hrChar.uuid}');

    await hrChar.setNotifyValue(true);
    // Décodage paquet HR GATT : bit 0 du flags = format (uint8 ou uint16)
    hrChar.lastValueStream.listen((data) {
      if (data.isEmpty) return;
      final flags = data[0];
      final bpm = (flags & 0x01) == 0
          ? data[1]
          : data[1] + (data[2] << 8);
      debugPrint('[BLE] BPM reçu: $bpm');
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
