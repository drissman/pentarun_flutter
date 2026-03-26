// SPEC-KIT §3.5 — Phase 3.5 — Service CV natif (Android + iOS)
// ─────────────────────────────────────────────────────────────────────────────
// ACTIVATION BUILD NATIF :
//   1. Ajouter dans pubspec.yaml :
//        google_mlkit_pose_detection: ^0.12.0
//        camera: ^0.11.0
//   2. Android : minSdkVersion 21 dans android/app/build.gradle
//   3. iOS : NSCameraUsageDescription dans Info.plist
//   4. Décommenter les imports et l'implémentation ci-dessous
//   5. flutter build apk --release  ou  flutter build ios --release
// ─────────────────────────────────────────────────────────────────────────────
// import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
// import 'package:camera/camera.dart';
import 'dart:async';

import 'package:pentarun_flutter/models/pose_landmark.dart';

class CvServiceImpl {
  CvServiceImpl._();
  static final CvServiceImpl instance = CvServiceImpl._();

  bool get isSupported => true; // Disponible sur Android / iOS

  final _controller = StreamController<List<PoseLandmark>>.broadcast();

  // ── Caméra ────────────────────────────────────────────────────────────────
  Future<void> startCamera() async {
    // TODO (camera + google_mlkit_pose_detection) :
    //
    // final cameras = await availableCameras();
    // final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front,
    //   orElse: () => cameras.first);
    // _cameraController = CameraController(front, ResolutionPreset.medium,
    //   enableAudio: false, imageFormatGroup: ImageFormatGroup.bgra8888);
    // await _cameraController!.initialize();
    //
    // _poseDetector = PoseDetector(options: PoseDetectorOptions(
    //   mode: PoseDetectionMode.stream,
    //   model: PoseDetectionModel.base,
    // ));
    //
    // _cameraController!.startImageStream((CameraImage img) async {
    //   final inputImage = _buildInputImage(img);
    //   final poses = await _poseDetector!.processImage(inputImage);
    //   if (poses.isNotEmpty) {
    //     _controller.add(_mapLandmarks(poses.first));
    //   }
    // });
  }

  Future<void> stopCamera() async {
    // TODO : await _cameraController?.stopImageStream();
    //        await _cameraController?.dispose();
    //        await _poseDetector?.close();
  }

  Stream<List<PoseLandmark>> get landmarkStream => _controller.stream;

  // ── Mapping landmarks MediaPipe → PoseLandmark ────────────────────────────
  // ignore: unused_element
  List<PoseLandmark> _mapLandmarks(dynamic pose) {
    // TODO (google_mlkit_pose_detection) :
    // return (pose as Pose).landmarks.entries.map((e) {
    //   return PoseLandmark(
    //     index: e.key.index,
    //     x: e.value.x,
    //     y: e.value.y,
    //     z: e.value.z,
    //     confidence: e.value.likelihood,
    //   );
    // }).toList();
    return [];
  }

  // ── Conversion CameraImage → InputImage ──────────────────────────────────
  // ignore: unused_element
  dynamic _buildInputImage(dynamic img) {
    // TODO (camera + google_mlkit_pose_detection) :
    // InputImage.fromBytes(bytes: ..., metadata: InputImageMetadata(...))
    return null;
  }
}
