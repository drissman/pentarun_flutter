// SPEC-KIT §3.5.3 — Phase 3.5 — Moteur de comptage de répétitions KB
// Algorithme machine à états angulaire (angle épaule-coude-poignet)
// Compatible on-device MediaPipe Pose Landmarker (33 landmarks BlazePose)
import 'dart:math' show acos, sqrt, pi;

import 'package:pentarun_flutter/models/pose_landmark.dart';
import 'package:pentarun_flutter/models/rep_counter_config.dart';

class RepCounterEngine {
  final RepCounterConfig config;

  // ─── État interne ─────────────────────────────────────────────────────────
  RepState _stateBras = RepState.neutral;
  int _repCount = 0;
  int _debounceCounter = 0;
  RepState _pendingState = RepState.neutral;

  RepCounterEngine({required this.config});

  int get repCount => _repCount;

  void reset() {
    _stateBras = RepState.neutral;
    _repCount = 0;
    _debounceCounter = 0;
    _pendingState = RepState.neutral;
  }

  // ─── Calcul d'angle entre 3 points ────────────────────────────────────────
  /// Angle (°) au point B (coude) formé par les segments BA et BC
  /// A = épaule, B = coude, C = poignet
  static double angleDegrees(
    PoseLandmark a,
    PoseLandmark b,
    PoseLandmark c,
  ) {
    final bax = a.x - b.x;
    final bay = a.y - b.y;
    final bcx = c.x - b.x;
    final bcy = c.y - b.y;

    final dot = bax * bcx + bay * bcy;
    final normBA = sqrt(bax * bax + bay * bay);
    final normBC = sqrt(bcx * bcx + bcy * bcy);

    if (normBA == 0 || normBC == 0) return 0;

    final cosAngle = (dot / (normBA * normBC)).clamp(-1.0, 1.0);
    return acos(cosAngle) * 180 / pi;
  }

  // ─── Traitement d'un frame ────────────────────────────────────────────────
  /// Retourne un [RepEvent] si une répétition est confirmée sur ce frame,
  /// sinon null. [side] détermine quel bras analyser.
  RepEvent? processFrame({
    required List<PoseLandmark> landmarks,
    required RepSide side,
  }) {
    // Sélectionne les landmarks selon le côté
    final shoulderIdx = side == RepSide.left
        ? PoseLandmark.leftShoulder
        : PoseLandmark.rightShoulder;
    final elbowIdx = side == RepSide.left
        ? PoseLandmark.leftElbow
        : PoseLandmark.rightElbow;
    final wristIdx = side == RepSide.left
        ? PoseLandmark.leftWrist
        : PoseLandmark.rightWrist;

    // Vérifie que les landmarks existent et sont suffisamment fiables
    PoseLandmark? findLm(int idx) {
      try {
        return landmarks.firstWhere(
          (l) => l.index == idx && l.confidence >= config.minConfidence,
        );
      } catch (_) {
        return null;
      }
    }

    final shoulder = findLm(shoulderIdx);
    final elbow    = findLm(elbowIdx);
    final wrist    = findLm(wristIdx);

    if (shoulder == null || elbow == null || wrist == null) return null;

    final angle = angleDegrees(shoulder, elbow, wrist);
    final avgConf = (shoulder.confidence + elbow.confidence + wrist.confidence) / 3;

    // ── Machine à états avec debounce ──────────────────────────────────────
    final newState = angle < config.seuilBas
        ? RepState.basse
        : angle > config.seuilHaut
            ? RepState.haute
            : RepState.neutral; // zone intermédiaire → conserve état précédent

    // Debounce : l'état doit être stable pendant [debounceFrames] frames
    if (newState != RepState.neutral && newState != _pendingState) {
      _pendingState = newState;
      _debounceCounter = 1;
    } else if (newState == _pendingState && newState != RepState.neutral) {
      _debounceCounter++;
    }

    if (_debounceCounter < config.debounceFrames) return null;

    // Transition confirmée
    final confirmedState = _pendingState;
    if (confirmedState == _stateBras) return null;

    // Détection BASSE → HAUTE → BASSE = +1 répétition
    RepEvent? event;
    if (_stateBras == RepState.haute && confirmedState == RepState.basse) {
      _repCount++;
      event = RepEvent(
        timestamp: DateTime.now(),
        side: side,
        confidence: avgConf,
        repNumber: _repCount,
      );
    }

    _stateBras = confirmedState;
    _debounceCounter = 0;
    return event;
  }

  // ─── Traitement automatique des deux bras ─────────────────────────────────
  /// Traite les deux bras et retourne la rep du bras le plus actif
  RepEvent? processFrameBothSides(List<PoseLandmark> landmarks) {
    // Pour le PENTARUN (snatch/jerk unilatéral), on prend la première rep détectée
    final leftRep  = processFrame(landmarks: landmarks, side: RepSide.left);
    if (leftRep != null) return leftRep;
    return processFrame(landmarks: landmarks, side: RepSide.right);
  }
}
