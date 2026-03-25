// SPEC-KIT §7.2 — Phase 2.2 Sprint 5 — File d'attente offline via localStorage
// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

const _key = 'pentarun_offline_queue';

/// Ajoute une entrée non synchronisée dans la file locale
Future<void> offlineEnqueue(Map<String, dynamic> item) async {
  final raw = html.window.localStorage[_key];
  final queue = raw != null
      ? (jsonDecode(raw) as List).cast<Map<String, dynamic>>()
      : <Map<String, dynamic>>[];
  queue.add({...item, '_ts': DateTime.now().millisecondsSinceEpoch});
  html.window.localStorage[_key] = jsonEncode(queue);
}

/// Rejoue les entrées en attente via [processor]
/// Retourne le nombre d'entrées rejouées avec succès
Future<int> offlineFlush(
    Future<void> Function(Map<String, dynamic>) processor) async {
  final raw = html.window.localStorage[_key];
  if (raw == null) return 0;
  final queue = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  if (queue.isEmpty) return 0;

  int replayed = 0;
  final remaining = <Map<String, dynamic>>[];

  for (final item in queue) {
    try {
      await processor(item);
      replayed++;
    } catch (_) {
      remaining.add(item); // conservé pour la prochaine tentative
    }
  }

  if (remaining.isEmpty) {
    html.window.localStorage.remove(_key);
  } else {
    html.window.localStorage[_key] = jsonEncode(remaining);
  }
  return replayed;
}

/// Nombre d'entrées en attente dans la file
Future<int> offlinePendingCount() async {
  final raw = html.window.localStorage[_key];
  if (raw == null) return 0;
  return (jsonDecode(raw) as List).length;
}
