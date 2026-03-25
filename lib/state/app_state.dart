import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/engine/energy_calculator.dart';
import 'package:pentarun_flutter/services/offline_queue.dart';
import 'package:pentarun_flutter/models/age_category.dart';
import 'package:pentarun_flutter/models/athlete.dart';
import 'package:pentarun_flutter/models/energy_breakdown.dart';
import 'package:pentarun_flutter/models/kettlebell.dart';
import 'package:pentarun_flutter/models/level.dart';
import 'package:pentarun_flutter/models/race_result.dart';
import 'package:pentarun_flutter/models/sex.dart';
import 'package:pentarun_flutter/models/station.dart';
import 'package:pentarun_flutter/services/results_service.dart';
import 'package:pentarun_flutter/services/wave_service.dart';

// SPEC-KIT §4 — Machine à états : §4.1→setup | §4.2→racing | §4.3→summary
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

  // SPEC-KIT §7.1 — Phase 2.2 : contexte compétition (null = mode libre Phase 1)
  String? _currentWaveId;
  String? _currentCompetitionId;
  String? get currentWaveId => _currentWaveId;
  String? get currentCompetitionId => _currentCompetitionId;
  bool get isConnectedMode => _currentWaveId != null;

  // Form state
  // SPEC-KIT §5.1 — Valeurs par défaut athlète référence CHALLENGER (75kg, 175cm, 24kg KB)
  String formName = '';
  Level formLevel = Level.decouverte;
  int formKb = 16;
  int formHeight = 175;
  int formWeight = 75;
  // SPEC-KIT §5.2 — Champs plateforme (optionnels pour mode juge)
  Sex formSexe = Sex.homme;
  DateTime formDateNaissance = DateTime(1990, 1, 1);
  String? formProfileId;

  // ─── CHRONO ─────────────────────────────────────────────────────────────────
  void updateElapsed() {
    if (_startTime != null) {
      _elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds;
      notifyListeners();
    }
  }

  // ─── CONTEXTE COMPÉTITION ────────────────────────────────────────────────────
  void setCompetitionContext(String competitionId, String waveId) {
    _currentCompetitionId = competitionId;
    _currentWaveId = waveId;
  }

  void clearCompetitionContext() {
    _currentCompetitionId = null;
    _currentWaveId = null;
  }

  // Ajoute un athlète pré-inscrit depuis wave_athletes Supabase
  void addAthleteFromWave({
    required String waveAthleteId,
    required String name,
    required Level level,
    required int kbKg,
    required int heightCm,
    required int weightKg,
    required double coeffKb,
    required EnergyBreakdown energy,
    required String profileId,
    double? coeffAge,
    double? coeffSexe,
  }) {
    _athletes.add(Athlete(
      id: waveAthleteId, // L'ID local = l'ID wave_athletes pour la synchro
      name: name,
      level: level,
      weightKb: kbKg,
      heightAthlete: heightCm,
      weightAthlete: weightKg,
      coeff: coeffKb,
      energy: energy,
      profileId: profileId,
      coeffAge: coeffAge,
      coeffSexe: coeffSexe,
      waveAthleteId: waveAthleteId,
    ));
    notifyListeners();
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
    final age = DateTime.now().year - formDateNaissance.year;
    final cat = AgeCategory.fromAge(age);
    _athletes.add(Athlete(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: formName.toUpperCase(),
      level: formLevel,
      weightKb: formKb,
      heightAthlete: formHeight,
      weightAthlete: formWeight,
      coeff: Kettlebell.coeffFor(formKb),
      energy: energy,
      profileId: formProfileId,
      coeffAge: cat.coeff,
      coeffSexe: formSexe.coeff,
    ));
    formName = '';
    formProfileId = null;
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
    _currentWaveId = null;
    _currentCompetitionId = null;
    formName = '';
    formLevel = Level.decouverte;
    formKb = 16;
    formHeight = 175;
    formWeight = 75;
    formSexe = Sex.homme;
    formDateNaissance = DateTime(1990, 1, 1);
    formProfileId = null;
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
        // SPEC-KIT §5.3 — Score officiel : T.brut(ms) × coefficient KB
        final official = rawMs * a.coeff;
        // SPEC-KIT §5.2 — scorePlateforme : officialScore × coeffAge × coeffSexe
        final platform = (a.coeffAge != null && a.coeffSexe != null)
            ? official * a.coeffAge! * a.coeffSexe!
            : null;
        return a.copyWith(
          splits: [...a.splits, now],
          currentStation: Station.count,
          status: AthleteStatus.finished,
          finalTimeMs: rawMs,
          officialScore: official,
          platformScore: platform,
        );
      }
      return a.copyWith(
        splits: [...a.splits, now],
        currentStation: next,
      );
    }).toList();
    notifyListeners();
    _checkAutoSummary();

    // SPEC-KIT §7.1 — Phase 2.2 : push Realtime intermédiaire (fire-and-forget)
    // SPEC-KIT §7.2 Sprint 5 — offline queue : enqueue si réseau absent, flush si succès
    if (_currentWaveId != null) {
      final updated = _athletes.firstWhere((a) => a.id == id, orElse: () => _athletes.first);
      if (updated.waveAthleteId != null) {
        final payload = _buildPayload(updated);
        WaveService.pushProgress(
          waveAthleteId: updated.waveAthleteId!,
          stationActuelle: updated.currentStation,
          splitsMs: updated.splits
              .map((s) => s.difference(_startTime!).inMilliseconds)
              .toList(),
          statutAthlete: updated.status == AthleteStatus.finished ? 'termine' : 'en_course',
          noCountEvents: updated.noCountEvents,
          finalTimeMs: updated.finalTimeMs,
          officialScore: updated.officialScore,
          platformScore: updated.platformScore,
        ).then((_) {
          offlineFlush(_replayItem).catchError((_) {});
        }).catchError((_) {
          offlineEnqueue(payload).catchError((_) {});
        });
      }
    }
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

  // SPEC-KIT §4.3 — Transition auto vers summary quand tous les athlètes sont finished
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

  // SPEC-KIT §7.3 — Scellement + save Supabase fire-and-forget
  void sealAthlete(Athlete athlete) {
    showToast('Fiche scellée et transmise — ${athlete.name}.');
    // Sauvegarde uniquement si profil lié et résultat complet
    if (athlete.profileId != null &&
        athlete.finalTimeMs != null &&
        athlete.officialScore != null &&
        athlete.platformScore != null &&
        athlete.coeffAge != null &&
        athlete.coeffSexe != null) {
      final result = RaceResult(
        profileId: athlete.profileId!,
        waveDate: DateTime.now(),
        level: athlete.level,
        weightKbKg: athlete.weightKb,
        coeffKb: athlete.coeff,
        coeffAge: athlete.coeffAge!,
        coeffSexe: athlete.coeffSexe!,
        finalTimeMs: athlete.finalTimeMs!,
        officialScore: athlete.officialScore!,
        platformScore: athlete.platformScore!,
        splitsMs: athlete.splits
            .map((s) => s.difference(_startTime!).inMilliseconds)
            .toList(),
        noCountEvents: athlete.noCountEvents,
        energyRunKcal: athlete.energy.run,
        energySteelKcal: athlete.energy.steel,
        energyTotalKcal: athlete.energy.total,
      );
      // Fire-and-forget — SPEC-KIT §7.3
      ResultsService.saveResult(result);
    }

    // SPEC-KIT §7.1 — Phase 2.2 : marque l'athlète "termine" dans wave_athletes
    // SPEC-KIT §7.2 Sprint 5 — offline queue
    if (_currentWaveId != null && athlete.waveAthleteId != null) {
      final splitsMs = athlete.splits
          .map((s) => s.difference(_startTime!).inMilliseconds)
          .toList();
      final payload = {
        'waveAthleteId': athlete.waveAthleteId!,
        'stationActuelle': Station.count,
        'splitsMs': splitsMs,
        'statutAthlete': 'termine',
        'noCountEvents': athlete.noCountEvents,
        if (athlete.finalTimeMs != null) 'finalTimeMs': athlete.finalTimeMs,
        if (athlete.officialScore != null) 'officialScore': athlete.officialScore,
        if (athlete.platformScore != null) 'platformScore': athlete.platformScore,
      };
      WaveService.pushProgress(
        waveAthleteId: athlete.waveAthleteId!,
        stationActuelle: Station.count,
        splitsMs: splitsMs,
        statutAthlete: 'termine',
        noCountEvents: athlete.noCountEvents,
        finalTimeMs: athlete.finalTimeMs,
        officialScore: athlete.officialScore,
        platformScore: athlete.platformScore,
      ).then((_) {
        offlineFlush(_replayItem).catchError((_) {});
      }).catchError((_) {
        offlineEnqueue(payload).catchError((_) {});
      });
    }
  }

  // ─── OFFLINE QUEUE HELPERS ──────────────────────────────────────────────────

  Map<String, dynamic> _buildPayload(Athlete a) => {
    'waveAthleteId': a.waveAthleteId!,
    'stationActuelle': a.currentStation,
    'splitsMs': a.splits
        .map((s) => s.difference(_startTime!).inMilliseconds)
        .toList(),
    'statutAthlete': a.status == AthleteStatus.finished ? 'termine' : 'en_course',
    'noCountEvents': a.noCountEvents,
    if (a.finalTimeMs != null) 'finalTimeMs': a.finalTimeMs,
    if (a.officialScore != null) 'officialScore': a.officialScore,
    if (a.platformScore != null) 'platformScore': a.platformScore,
  };

  static Future<void> _replayItem(Map<String, dynamic> item) =>
      WaveService.pushProgress(
        waveAthleteId: item['waveAthleteId'] as String,
        stationActuelle: item['stationActuelle'] as int,
        splitsMs: (item['splitsMs'] as List)
            .map((e) => (e as num).toInt())
            .toList(),
        statutAthlete: item['statutAthlete'] as String,
        noCountEvents: (item['noCountEvents'] as num?)?.toInt() ?? 0,
        finalTimeMs: (item['finalTimeMs'] as num?)?.toInt(),
        officialScore: (item['officialScore'] as num?)?.toDouble(),
        platformScore: (item['platformScore'] as num?)?.toDouble(),
      );

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

  // SPEC-KIT §4.3 — Classement : officialScore ASC, ex-æquo par finalTimeMs, DNF en derniers
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

  void updateFormSexe(Sex v) {
    formSexe = v;
    notifyListeners();
  }

  void updateFormDateNaissance(DateTime v) {
    formDateNaissance = v;
    notifyListeners();
  }

  void updateFormProfileId(String? v) {
    formProfileId = v;
    // No notifyListeners needed — internal state only
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
