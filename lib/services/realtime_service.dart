// SPEC-KIT §7.1 — Phase 2.2 — Abonnements Supabase Realtime
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pentarun_flutter/models/wave_athlete.dart';
import 'package:pentarun_flutter/models/wave.dart';

class RealtimeService {
  RealtimeService._();

  static final Map<String, RealtimeChannel> _channels = {};

  // ─── Abonnement vague ──────────────────────────────────────────────────────

  /// Écoute les mises à jour d'une vague (juge, directeur, spectateur)
  static void subscribeToWave(
    String waveId, {
    required void Function(WaveAthlete) onAthleteUpdated,
    void Function(Wave)? onWaveUpdated,
  }) {
    final key = 'wave:$waveId';
    _channels[key]?.unsubscribe();

    final channel = Supabase.instance.client.channel(key);

    // Mise à jour progression athlète
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'wave_athletes',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'wave_id',
        value: waveId,
      ),
      callback: (payload) {
        try {
          onAthleteUpdated(WaveAthlete.fromJson(payload.newRecord));
        } catch (_) {}
      },
    );

    // Nouvel athlète inscrit en cours de vague
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'wave_athletes',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'wave_id',
        value: waveId,
      ),
      callback: (payload) {
        try {
          onAthleteUpdated(WaveAthlete.fromJson(payload.newRecord));
        } catch (_) {}
      },
    );

    // Changement de statut de la vague elle-même
    if (onWaveUpdated != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'waves',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: waveId,
        ),
        callback: (payload) {
          try {
            onWaveUpdated(Wave.fromJson(payload.newRecord));
          } catch (_) {}
        },
      );
    }

    channel.subscribe();
    _channels[key] = channel;
  }

  // ─── Abonnement compétition (vue directeur) ────────────────────────────────

  /// Écoute toutes les vagues d'une compétition (pour le DirectorScreen)
  static void subscribeToCompetition(
    String competitionId, {
    required void Function(WaveAthlete) onAthleteUpdated,
    required void Function(Wave) onWaveUpdated,
  }) {
    final key = 'competition:$competitionId';
    _channels[key]?.unsubscribe();

    final channel = Supabase.instance.client.channel(key);

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'wave_athletes',
      callback: (payload) {
        try {
          onAthleteUpdated(WaveAthlete.fromJson(payload.newRecord));
        } catch (_) {}
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'waves',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'competition_id',
        value: competitionId,
      ),
      callback: (payload) {
        try {
          onWaveUpdated(Wave.fromJson(payload.newRecord));
        } catch (_) {}
      },
    );

    channel.subscribe();
    _channels[key] = channel;
  }

  // ─── Désabonnement ─────────────────────────────────────────────────────────

  static void unsubscribe(String key) {
    _channels[key]?.unsubscribe();
    _channels.remove(key);
  }

  static void unsubscribeAll() {
    for (final ch in _channels.values) {
      ch.unsubscribe();
    }
    _channels.clear();
  }
}
