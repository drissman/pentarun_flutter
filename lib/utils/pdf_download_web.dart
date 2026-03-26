// SPEC-KIT §9.4 — Phase 2.3 Sprint 4 — Téléchargement PDF via dart:html
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

void downloadPdfBytes(Uint8List bytes, String filename) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
