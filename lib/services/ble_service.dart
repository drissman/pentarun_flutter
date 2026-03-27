// SPEC-KIT §6.7 — Phase 3.6 — Export conditionnel BLE web/native
// Web             → ble_service_web.dart    (Web Bluetooth API Chrome/Edge)
// Native (io)     → ble_service_native.dart (flutter_blue_plus Android/iOS)
export 'ble_service_web.dart'
    if (dart.library.io) 'ble_service_native.dart';
