// SPEC-KIT §3.5 — Phase 3.5 : CV Assist natif — MLKit Pose Detection + camera
// Compilé uniquement sur Android + iOS (dart.library.io)
// Exporté via cv_service.dart (conditional import)

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:pentarun_flutter/models/pose_landmark.dart' as app;

class CvServiceImpl {
  CvServiceImpl._();
  static final CvServiceImpl instance = CvServiceImpl._();

  bool get isSupported => true;

  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  bool _processing = false; // anti-pile-up : on skip les frames en cours de traitement

  final _controller = StreamController<List<app.PoseLandmark>>.broadcast();
  Stream<List<app.PoseLandmark>> get landmarkStream => _controller.stream;

  // ─── Start ────────────────────────────────────────────────────────────────
  Future<void> startCamera() async {
    final cameras = await availableCameras();
    // Préférence caméra frontale pour capturer le mouvement de l'athlète face au juge
    final cam = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      cam,
      ResolutionPreset.medium, // 720p — bon équilibre latence / qualité ML
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Android natif NV21
    );
    await _cameraController!.initialize();

    // Mode stream — traitement continu frame par frame
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      ),
    );

    _cameraController!.startImageStream((CameraImage img) async {
      // Skip si frame précédente encore en cours — évite l'accumulation mémoire
      if (_processing || _cameraController == null) return;
      _processing = true;
      try {
        final poses = await _poseDetector!.processImage(_buildInputImage(img));
        if (poses.isNotEmpty) {
          _controller.add(_mapLandmarks(poses.first));
        }
      } finally {
        _processing = false;
      }
    });
  }

  // ─── Stop ─────────────────────────────────────────────────────────────────
  Future<void> stopCamera() async {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
    await _cameraController?.dispose();
    _cameraController = null;
    await _poseDetector?.close();
    _poseDetector = null;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  // Convertit CameraImage NV21 → InputImage MLKit
  // NV21 = plan Y (luminance) + plan UV interleaved → concaténation directe
  InputImage _buildInputImage(CameraImage img) {
    final allBytes = BytesBuilder();
    for (final plane in img.planes) {
      allBytes.add(plane.bytes);
    }
    return InputImage.fromBytes(
      bytes: allBytes.toBytes(),
      metadata: InputImageMetadata(
        size: Size(img.width.toDouble(), img.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: img.planes[0].bytesPerRow,
      ),
    );
  }

  // Mappe les landmarks MLKit vers notre modèle PoseLandmark
  // Indices MediaPipe : shoulder=11/12 · elbow=13/14 · wrist=15/16
  List<app.PoseLandmark> _mapLandmarks(Pose pose) {
    return pose.landmarks.entries
        .map((e) => app.PoseLandmark(
              index: e.key.index,
              x: e.value.x,
              y: e.value.y,
              z: e.value.z,
              confidence: e.value.likelihood,
            ))
        .toList();
  }

  void dispose() {
    _controller.close();
  }
}
