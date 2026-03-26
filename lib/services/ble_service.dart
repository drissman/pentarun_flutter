// SPEC-KIT §6.2 — Phase 3 — Export conditionnel BLE stub/native
// Web (dart.library.html) → stub no-op
// Native Android/iOS (dart.library.io) → BleServiceNative (flutter_blue_plus)
export 'ble_service_stub.dart'
    if (dart.library.io) 'ble_service_native.dart';
