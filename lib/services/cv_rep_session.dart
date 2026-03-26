// SPEC-KIT §3.5.4 — Phase 3.5 — Session de comptage CV (singleton)
// Gère le flux de landmarks → RepCounterEngine → compteur par athlète
import 'dart:async';

import 'package:pentarun_flutter/engine/rep_counter_engine.dart';
import 'package:pentarun_flutter/models/pose_landmark.dart';
import 'package:pentarun_flutter/models/rep_counter_config.dart';
import 'package:pentarun_flutter/services/cv_service.dart';

class CvRepSession {
  CvRepSession._();
  static final CvRepSession instance = CvRepSession._();

  final _cv = CvServiceImpl.instance;

  // ─── État de session ──────────────────────────────────────────────────────
  String? _activeAthleteId;
  RepCounterEngine? _engine;
  StreamSubscription<List<PoseLandmark>>? _subscription;
  bool _active = false;

  final _repController = StreamController<int>.broadcast();

  bool get isSupported => _cv.isSupported;
  bool get isActive => _active;

  /// Flux : nombre de reps de la station courante (s'incrémente à chaque rep)
  Stream<int> get repStream => _repController.stream;

  // ─── Démarrage session par athlète ────────────────────────────────────────
  Future<void> startFor({
    required String athleteId,
    required RepCounterConfig config,
  }) async {
    await stop();
    _activeAthleteId = athleteId;
    _engine = RepCounterEngine(config: config);
    await _cv.startCamera();
    _active = true;

    _subscription = _cv.landmarkStream.listen((landmarks) {
      final event = _engine!.processFrameBothSides(landmarks);
      if (event != null) {
        _repController.add(_engine!.repCount);
      }
    });
  }

  /// Réinitialise le compteur de station (appelé à chaque VALIDER)
  void resetStationCount() {
    _engine?.reset();
    if (_engine != null) _repController.add(0);
  }

  /// Arrêt complet de la session CV
  Future<void> stop() async {
    _subscription?.cancel();
    _subscription = null;
    await _cv.stopCamera();
    _active = false;
    _activeAthleteId = null;
    _engine = null;
  }

  /// Nombre de reps pour la station courante
  int get stationReps => _engine?.repCount ?? 0;

  String? get activeAthleteId => _activeAthleteId;
}
