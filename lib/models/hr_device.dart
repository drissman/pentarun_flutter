// SPEC-KIT §6.2 — Phase 3 — Capteur BLE détecté (Heart Rate Service 0x180D)
class HrDevice {
  final String id;
  final String name;
  final int rssi;

  const HrDevice({required this.id, required this.name, this.rssi = 0});

  @override
  String toString() => '$name ($id)';
}
