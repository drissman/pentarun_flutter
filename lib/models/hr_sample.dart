// SPEC-KIT §6.2 — Phase 3 — Mesure FC instantanée (GATT 0x2A37)
class HrSample {
  final int bpm;
  final DateTime timestamp;

  const HrSample({required this.bpm, required this.timestamp});
}
