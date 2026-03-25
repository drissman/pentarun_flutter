// SPEC-KIT §7.2 — Phase 2.2 Sprint 5 — Stub non-web (no-op)

Future<void> offlineEnqueue(Map<String, dynamic> item) async {}

Future<int> offlineFlush(
    Future<void> Function(Map<String, dynamic>) processor) async => 0;

Future<int> offlinePendingCount() async => 0;
