// SPEC-KIT §3.5 — Phase 3.5 — Export conditionnel CV stub/native
// Web (dart.library.html) → stub no-op
// Native Android/iOS (dart.library.io) → implémentation google_mlkit + camera
export 'cv_service_stub.dart'
    if (dart.library.io) 'cv_service_native.dart';
