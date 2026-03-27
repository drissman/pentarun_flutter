// SPEC-KIT §6.7 — Phase 3.6 — Déclarations JS interop Web Bluetooth API
// Utilisé uniquement sur Flutter Web (compilé via ble_service.dart → ble_service_web.dart)
// Référence W3C : https://webbluetoothcg.github.io/web-bluetooth/
// Compatibilité : Chrome ✅ · Edge ✅ · Firefox ❌ · Safari ❌

import 'dart:js_interop';

// ─── Accès à navigator.bluetooth ─────────────────────────────────────────────

extension type _JsNavigator._(JSObject _) implements JSObject {
  external _Bluetooth get bluetooth;
}

@JS('navigator')
external _JsNavigator get _jsNavigator;

// Point d'entrée interne — non exposé publiquement (type privé)
_Bluetooth get _webBluetooth => _jsNavigator.bluetooth;

// ─── Bluetooth (interface principale) ────────────────────────────────────────

extension type _Bluetooth._(JSObject _) implements JSObject {
  /// Ouvre le popup de sélection de device dans le navigateur.
  /// Requiert un gesture utilisateur (clic) — non appelable programmatiquement.
  external JSPromise<BluetoothDevice> requestDevice(JSObject options);
}

// ─── Options du popup de scan ─────────────────────────────────────────────────

extension type _BleFilter._(JSObject _) implements JSObject {
  /// Crée un filtre de scan (objet JS littéral {services: [...]})
  external factory _BleFilter({JSArray<JSAny> services});
}

extension type _BleOptions._(JSObject _) implements JSObject {
  /// Crée les options requestDevice (objet JS littéral)
  external factory _BleOptions({
    JSBoolean acceptAllDevices,
    JSArray<JSAny> filters,
    JSArray<JSAny> optionalServices,
  });
}

// ─── BluetoothDevice ─────────────────────────────────────────────────────────

/// Device BLE sélectionné par l'utilisateur dans le popup Chrome
extension type BluetoothDevice._(JSObject _) implements JSObject {
  external JSString get id;
  external JSString? get name;
  external BluetoothRemoteGATTServer get gatt;
  // Événements device : 'gattserverdisconnected' fire quand la connexion GATT est perdue
  external void addEventListener(JSString type, JSFunction listener);
  external void removeEventListener(JSString type, JSFunction listener);
}

// ─── GATT Server ─────────────────────────────────────────────────────────────

/// Serveur GATT du capteur BLE (point d'entrée des services)
extension type BluetoothRemoteGATTServer._(JSObject _) implements JSObject {
  external JSBoolean get connected;
  external JSPromise<BluetoothRemoteGATTServer> connect();
  external JSPromise<BluetoothRemoteGATTService> getPrimaryService(
      JSString service);
  external void disconnect();
}

// ─── GATT Service ────────────────────────────────────────────────────────────

/// Service GATT (ex: Heart Rate Service 0x180D)
extension type BluetoothRemoteGATTService._(JSObject _) implements JSObject {
  external JSPromise<BluetoothRemoteGATTCharacteristic> getCharacteristic(
      JSString characteristic);
}

// ─── GATT Characteristic ─────────────────────────────────────────────────────

/// Caractéristique GATT (ex: Heart Rate Measurement 0x2A37)
extension type BluetoothRemoteGATTCharacteristic._(JSObject _)
    implements JSObject {
  external JSPromise<BluetoothRemoteGATTCharacteristic> startNotifications();

  /// Dernière valeur reçue — DataView contenant les octets BLE bruts
  external BleDataView? get value;

  external void addEventListener(JSString type, JSFunction listener);
  external void removeEventListener(JSString type, JSFunction listener);
}

// ─── DataView — lecture des octets BLE HR ────────────────────────────────────

/// Wrapper JS DataView pour lire les octets du paquet HR GATT
extension type BleDataView._(JSObject _) implements JSObject {
  /// Lit 1 octet non signé à l'offset donné
  external JSNumber getUint8(JSNumber byteOffset);

  /// Lit 2 octets non signés (little-endian si littleEndian=true)
  external JSNumber getUint16(JSNumber byteOffset, JSBoolean littleEndian);
}

// ─── Fonction utilitaire publique ─────────────────────────────────────────────

/// Ouvre le popup Chrome de sélection d'un capteur Heart Rate.
/// Filtre sur le service GATT Heart Rate (UUID 0x180D / 'heart_rate').
/// Lance NotFoundError si l'utilisateur annule.
/// Lance SecurityError si appelé hors HTTPS ou hors gesture utilisateur.
Future<BluetoothDevice> requestHeartRateDevice() {
  final filter = _BleFilter(
    services: <JSAny>['heart_rate'.toJS].toJS,
  );
  final options = _BleOptions(
    acceptAllDevices: false.toJS,
    filters: <JSAny>[filter].toJS,
    optionalServices: <JSAny>['heart_rate'.toJS].toJS,
  );
  return _webBluetooth.requestDevice(options).toDart;
}
