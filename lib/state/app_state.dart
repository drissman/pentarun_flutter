import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/engine/energy_calculator.dart';
import 'package:pentarun_flutter/models/athlete.dart';
import 'package:pentarun_flutter/models/kettlebell.dart';
import 'package:pentarun_flutter/models/level.dart';
import 'package:pentarun_flutter/models/station.dart';

enum AppPhase { setup, racing, summary }

class AppState extends ChangeNotifier {
  // Phase
  AppPhase _phase = AppPhase.setup;
  AppPhase get phase => _phase;

  // Athletes
  List<Athlete> _athletes = [];
  List<Athlete> get athletes => List.unmodifiable(_athletes);

  // Chrono
  DateTime? _startTime;
  DateTime? get startTime => _startTime;
  int _elapsedMs = 0;
  int get elapsedMs => _elapsedMs;

  // Toast
  String? _toast;
  String? get toast => _toast;

  // Form state
  String formName = '';
  Level formLevel = Level.decouverte;
  int formKb = 16;
  int formHeight = 175;
  int formWeight = 75;

  // ─── CHRONO ─────────────────────────────────────────────────────────────────
  void updateElapsed() {
    if (_startTime != null) {
      _elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds;
      notifyListeners();
    }
  }

  // ─── ATHLETES ───────────────────────────────────────────────────────────────
  void addAthlete() {
    if (formName.trim().isEmpty) return;
    final energy = EnergyCalculator.calculate(
      weightAthleteKg: formWeight,
      heightAthleteCm: formHeight,
      weightKbKg: formKb,
      level: formLevel,
    );
    _athletes.add(Athlete(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: formName.toUpperCase(),
      level: formLevel,
      weightKb: formKb,
      heightAthlete: formHeight,
      weightAthlete: formWeight,
      coeff: Kettlebell.coeffFor(formKb),
      energy: energy,
    ));
    formName = '';
    notifyListeners();
  }

  void removeAthlete(String id) {
    _athletes.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // ─── PHASE TRANSITIONS ─────────────────────────────────────────────────────
  void startRacing() {
    if (_athletes.isEmpty) return;
    _startTime = DateTime.now();
    _athletes = _athletes
        .map((a) => a.copyWith(status: AthleteStatus.running))
        .toList();
    _phase = AppPhase.racing;
    notifyListeners();
  }

  void goToSummary() {
    _phase = AppPhase.summary;
    notifyListeners();
  }

  void resetAll() {
    _phase = AppPhase.setup;
    _athletes = [];
    _startTime = null;
    _elapsedMs = 0;
    formName = '';
    formLevel = Level.decouverte;
    formKb = 16;
    formHeight = 175;
    formWeight = 75;
    notifyListeners();
  }

  // ─── RACING ACTIONS ─────────────────────────────────────────────────────────
  void validateStation(String id) {
    final now = DateTime.now();
    _athletes = _athletes.map((a) {
      if (a.id != id || a.status != AthleteStatus.running) return a;
      final next = a.currentStation + 1;
      if (next >= Station.count) {
        final rawMs = now.difference(_startTime!).inMilliseconds;
        return a.copyWith(
          splits: [...a.splits, now],
          currentStation: Station.count,
          status: AthleteStatus.finished,
          finalTimeMs: rawMs,
          officialScore: rawMs * a.coeff,
        );
      }
      return a.copyWith(
        splits: [...a.splits, now],
        currentStation: next,
      );
    }).toList();
    notifyListeners();
    _checkAutoSummary();
  }

  void noCount(String id) {
    _athletes = _athletes.map((a) {
      if (a.id != id || a.status != AthleteStatus.running) return a;
      return a.copyWith(noCountEvents: a.noCountEvents + 1);
    }).toList();
    showToast('NO COUNT enregistré');
    notifyListeners();
  }

  void undo(String id) {
    _athletes = _athletes.map((a) {
      if (a.id != id || a.currentStation == 0) return a;
      return a.copyWith(
        splits: a.splits.sublist(0, a.splits.length - 1),
        currentStation: a.currentStation - 1,
        status: AthleteStatus.running,
        clearFinalTime: true,
        clearOfficialScore: true,
      );
    }).toList();
    notifyListeners();
  }

  void _checkAutoSummary() {
    if (_phase == AppPhase.racing &&
        _athletes.isNotEmpty &&
        _athletes.every((a) => a.status == AthleteStatus.finished)) {
      _phase = AppPhase.summary;
      notifyListeners();
    }
  }

  // ─── SIGNATURES ─────────────────────────────────────────────────────────────
  void setJudgeSignature(String id, Uint8List? data) {
    _athletes = _athletes.map((a) {
      if (a.id != id) return a;
      return a.copyWith(judgeSignature: data);
    }).toList();
    notifyListeners();
  }

  void setAthleteSignature(String id, Uint8List? data) {
    _athletes = _athletes.map((a) {
      if (a.id != id) return a;
      return a.copyWith(athleteSignature: data);
    }).toList();
    notifyListeners();
  }

  void sealAthlete(String athleteName) {
    showToast('Fiche scellée et transmise — $athleteName.');
  }

  // ─── TOAST ──────────────────────────────────────────────────────────────────
  void showToast(String message) {
    _toast = message;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (_toast == message) {
        _toast = null;
        notifyListeners();
      }
    });
  }

  // ─── COMPUTED ───────────────────────────────────────────────────────────────
  EnergyBreakdown get formEnergy => EnergyCalculator.calculate(
        weightAthleteKg: formWeight,
        heightAthleteCm: formHeight,
        weightKbKg: formKb,
        level: formLevel,
      );

  List<Athlete> get rankedAthletes {
    final finished =
        _athletes.where((a) => a.status == AthleteStatus.finished).toList();
    finished.sort((a, b) {
      final sa = a.officialScore ?? double.maxFinite;
      final sb = b.officialScore ?? double.maxFinite;
      if (sa != sb) return sa.compareTo(sb);
      return (a.finalTimeMs ?? 0).compareTo(b.finalTimeMs ?? 0);
    });
    final dnf =
        _athletes.where((a) => a.status != AthleteStatus.finished).toList();
    return [...finished, ...dnf];
  }

  // ─── FORM HELPERS ───────────────────────────────────────────────────────────
  void updateFormName(String v) {
    formName = v;
    // No notifyListeners — TextEditingController manages display
  }

  void updateFormLevel(Level v) {
    formLevel = v;
    notifyListeners();
  }

  void updateFormKb(int v) {
    formKb = v;
    notifyListeners();
  }

  void updateFormHeight(int v) {
    formHeight = v;
    notifyListeners();
  }

  void updateFormWeight(int v) {
    formWeight = v;
    notifyListeners();
  }
}

/// InheritedNotifier to provide AppState down the widget tree
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
        .notifier!;
  }
}
