// SPEC-KIT §7.2 — Phase 2.2 Sprint 5 — Export conditionnel offline queue
// Sur web : localStorage. Sur autre plateforme : no-op stub.
export 'offline_queue_stub.dart'
    if (dart.library.html) 'offline_queue_web.dart';
