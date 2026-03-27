// SPEC-KIT §6.7 — Phase 3.6 — BLE Web via Web Bluetooth API (Chrome/Edge)
// Compilé uniquement sur Flutter Web via export conditionnel dans ble_service.dart
//
// Compatibilité : Chrome ✅ · Edge ✅ · Firefox ❌ · Safari ❌
// Prérequis : HTTPS (Netlify assure HTTPS automatiquement)
//
// Différence vs natif (flutter_blue_plus) :
// - Pas de scan passif → requestDevice() ouvre un popup navigateur
// - L'utilisateur sélectionne son Polar H10 dans le popup (1 fois par session)
// - Auto-reconnect partiel via device.gatt.connect() (sans gesture si device mémorisé)
// - HrSessionService, HrCalculator, TRIMP → inchangés (aucune dépendance plateforme)

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:pentarun_flutter/models/hr_device.dart';
import 'package:pentarun_flutter/models/hr_sample.dart';
import 'package:pentarun_flutter/utils/web_bluetooth.dart';

class BleServiceImpl {
  BleServiceImpl._();
  static final BleServiceImpl instance = BleServiceImpl._();

  // ─── État ────────────────────────────────────────────────────────────────

  /// true sur Web — Web Bluetooth disponible sur Chrome/Edge
  bool get isSupported => true;

  HrDevice? _connectedDevice;
  HrDevice? get connectedDevice => _connectedDevice;

  final _hrController = StreamController<HrSample>.broadcast();
  final _connController = StreamController<bool>.broadcast();

  Stream<HrSample> get hrStream => _hrController.stream;
  Stream<bool> get connectionStream => _connController.stream;

  // Références internes pour reconnexion et nettoyage
  BluetoothDevice? _bleDevice;
  BluetoothRemoteGATTCharacteristic? _hrChar;
  JSFunction? _hrListener;
  // Écouteur 'gattserverdisconnected' — stocké pour pouvoir le retirer au disconnect()
  JSFunction? _disconnectListener;

  // ─── Scan ────────────────────────────────────────────────────────────────
  // Sur Web Bluetooth, il n'y a pas de scan passif en arrière-plan.
  // requestHeartRateDevice() ouvre le popup Chrome → l'utilisateur choisit.
  // Le stream émet une liste d'un seul device puis se ferme.
  // Si l'utilisateur annule → stream se ferme sans émettre (pas d'erreur).
  Stream<List<HrDevice>> scan({
    Duration timeout = const Duration(seconds: 30),
  }) {
    final controller = StreamController<List<HrDevice>>();

    requestHeartRateDevice().then((device) {
      _bleDevice = device;
      if (!controller.isClosed) {
        controller.add([
          HrDevice(
            id: device.id.toDart,
            name: device.name?.toDart ?? 'Capteur BLE',
          ),
        ]);
        controller.close();
      }
    }).catchError((Object e) {
      // Catégorisation des erreurs Web Bluetooth :
      // NotFoundError  → utilisateur a annulé le popup (comportement normal, pas d'alerte)
      // SecurityError  → HTTPS absent ou appel hors gesture utilisateur
      // NotSupportedError → navigateur incompatible (Firefox, Safari)
      // NetworkError   → échec connexion GATT
      final msg = e.toString();
      if (!msg.contains('NotFoundError') && !msg.contains('cancelled')) {
        debugPrint('[BLE Web] requestDevice erreur: $e');
      }
      if (!controller.isClosed) controller.close();
    });

    return controller.stream;
  }

  // ─── Connect ─────────────────────────────────────────────────────────────
  // deviceId ignoré sur Web — connexion via l'objet BluetoothDevice stocké
  // lors du dernier scan (requestDevice). Relancer scan() si _bleDevice == null.
  Future<void> connect(String deviceId) async {
    if (_bleDevice == null) {
      debugPrint('[BLE Web] Aucun device mémorisé — relancer le scan');
      return;
    }
    try {
      final server = await _bleDevice!.gatt.connect().toDart;
      debugPrint('[BLE Web] GATT connecté');

      _connectedDevice = HrDevice(
        id: _bleDevice!.id.toDart,
        name: _bleDevice!.name?.toDart ?? 'Capteur BLE',
      );
      _connController.add(true);

      await _subscribeHr(server);
    } catch (e) {
      debugPrint('[BLE Web] Erreur connect: $e');
      _connController.add(false);
    }
  }

  // Découverte du service HR + souscription aux notifications GATT
  // Identique au flux natif : écoute 'characteristicvaluechanged' (événement DOM)
  Future<void> _subscribeHr(BluetoothRemoteGATTServer server) async {
    final service =
        await server.getPrimaryService('heart_rate'.toJS).toDart;
    debugPrint('[BLE Web] Service Heart Rate obtenu');

    final char =
        await service.getCharacteristic('heart_rate_measurement'.toJS).toDart;
    debugPrint('[BLE Web] Caractéristique HR Measurement obtenue');

    await char.startNotifications().toDart;
    _hrChar = char;

    // SPEC-KIT §6.2 — Décodage paquet HR GATT :
    // Octet 0 = flags, bit 0 = format (0 → uint8, 1 → uint16 little-endian)
    // Octet(s) 1[–2] = valeur BPM
    _hrListener = ((JSAny? _) {
      final dv = char.value;
      if (dv == null) return;
      final flags = dv.getUint8(0.toJS).toDartDouble.toInt();
      final bpm = (flags & 0x01) == 0
          ? dv.getUint8(1.toJS).toDartDouble.toInt()
          : dv.getUint16(1.toJS, true.toJS).toDartDouble.toInt();
      debugPrint('[BLE Web] BPM: $bpm');
      _hrController.add(HrSample(bpm: bpm, timestamp: DateTime.now()));
    }).toJS;

    char.addEventListener('characteristicvaluechanged'.toJS, _hrListener!);
    debugPrint('[BLE Web] Notifications HR actives ✓');

    // SPEC-KIT §6.7 — Reconnect automatique Web :
    // 'gattserverdisconnected' fire quand le capteur sort de portée ou perd la connexion.
    // → émettre false sur connectionStream → HrSessionService._scheduleReconnect()
    //   rappelle connect() avec délai croissant (2s, 4s, 6s, 8s, 10s — max 5 tentatives)
    final prevListener = _disconnectListener;
    if (prevListener != null) {
      _bleDevice?.removeEventListener('gattserverdisconnected'.toJS, prevListener);
    }
    _disconnectListener = ((JSAny? _) {
      debugPrint('[BLE Web] gattserverdisconnected — connexion perdue');
      _connController.add(false);
    }).toJS;
    _bleDevice?.addEventListener('gattserverdisconnected'.toJS, _disconnectListener!);
  }

  // ─── Reconnect ───────────────────────────────────────────────────────────
  // Sur Web Bluetooth, si la connexion GATT est perdue, on peut tenter
  // device.gatt.connect() sans gesture utilisateur (si device déjà autorisé).
  // Appelé par HrSessionService._scheduleReconnect() (même mécanisme que natif).
  Future<void> reconnect() async {
    if (_bleDevice == null || _connectedDevice == null) return;
    debugPrint('[BLE Web] Tentative reconnexion...');
    await connect(_connectedDevice!.id);
  }

  // ─── Disconnect ──────────────────────────────────────────────────────────
  Future<void> disconnect() async {
    // Nettoyer les écouteurs DOM avant de déconnecter
    if (_hrChar != null && _hrListener != null) {
      _hrChar!.removeEventListener(
          'characteristicvaluechanged'.toJS, _hrListener!);
      _hrListener = null;
      _hrChar = null;
    }
    if (_bleDevice != null && _disconnectListener != null) {
      _bleDevice!.removeEventListener(
          'gattserverdisconnected'.toJS, _disconnectListener!);
      _disconnectListener = null;
    }
    _bleDevice?.gatt.disconnect();
    _connectedDevice = null;
    _connController.add(false);
    debugPrint('[BLE Web] Déconnecté');
  }

  void dispose() {
    _hrController.close();
    _connController.close();
  }
}
