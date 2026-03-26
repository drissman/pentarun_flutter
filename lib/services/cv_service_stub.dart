// SPEC-KIT §3.5 — Phase 3.5 — Stub CV (Flutter Web — MediaPipe non disponible)
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/pose_landmark.dart';

/// CV non supporté sur Flutter Web — stub no-op
class CvServiceImpl {
  CvServiceImpl._();
  static final CvServiceImpl instance = CvServiceImpl._();

  bool get isSupported => false;

  Future<void> startCamera() async {}
  Future<void> stopCamera() async {}

  /// Flux de landmarks — toujours vide sur Web
  Stream<List<PoseLandmark>> get landmarkStream => const Stream.empty();

  /// Aperçu caméra — vide sur Web
  Widget buildPreview() => const SizedBox();
}
