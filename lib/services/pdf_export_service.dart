// SPEC-KIT §9.4 — Phase 2.3 Sprint 4 — Génération fiche PDF résultat
// Package `pdf` (pub.dev) — compatible Flutter Web (canvas renderer)
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pentarun_flutter/models/race_result.dart';
import 'package:pentarun_flutter/utils/pdf_download.dart';
import 'package:pentarun_flutter/utils/time_formatter.dart';

class PdfExportService {
  PdfExportService._();

  // ─── Couleurs A2UI mappées en PDF ─────────────────────────────────────────
  static const _bg    = PdfColor.fromInt(0xFF090909);
  static const _cardBg = PdfColor.fromInt(0xFF111111);
  static const _cyan  = PdfColor.fromInt(0xFF06B6D4);
  static const _vert  = PdfColor.fromInt(0xFF10B981);
  static const _ambre = PdfColor.fromInt(0xFFF59E0B);
  static const _blanc = PdfColor.fromInt(0xFFF0F0F0);
  static const _gris1 = PdfColor.fromInt(0xFF9CA3AF);

  /// Génère et télécharge la fiche PDF d'un résultat
  static Future<void> exportResult(RaceResult r) async {
    final bytes = await _buildPdf(r);
    final athleteName = (r.athleteDisplayName ?? r.profileId)
        .replaceAll(' ', '_')
        .toLowerCase();
    final date = '${r.waveDate.year}'
        '${r.waveDate.month.toString().padLeft(2, '0')}'
        '${r.waveDate.day.toString().padLeft(2, '0')}';
    downloadPdfBytes(bytes, 'pentarun_${athleteName}_$date.pdf');
  }

  static Future<Uint8List> _buildPdf(RaceResult r) async {
    final doc = pw.Document();

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildHeader(r),
          pw.SizedBox(height: 20),
          _buildAthlete(r),
          pw.SizedBox(height: 12),
          _buildScores(r),
          pw.SizedBox(height: 12),
          _buildSplits(r),
          pw.SizedBox(height: 12),
          _buildCoefficients(r),
          if (r.energyTotalKcal != null) ...[
            pw.SizedBox(height: 12),
            _buildEnergie(r),
          ],
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    ));

    return doc.save();
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  static pw.Widget _buildHeader(RaceResult r) {
    final date = '${r.waveDate.day.toString().padLeft(2, '0')}/'
        '${r.waveDate.month.toString().padLeft(2, '0')}/'
        '${r.waveDate.year}';
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: _bg,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('PENTARUN',
                style: pw.TextStyle(color: _cyan, fontSize: 22,
                    fontWeight: pw.FontWeight.bold)),
            pw.Text('FICHE DE RESULTAT',
                style: pw.TextStyle(color: _gris1, fontSize: 10, letterSpacing: 2)),
          ]),
          pw.Text(date, style: pw.TextStyle(color: _gris1, fontSize: 10)),
        ],
      ),
    );
  }

  // ─── Section Athlète ───────────────────────────────────────────────────────

  static pw.Widget _buildAthlete(RaceResult r) {
    return _section([
      _dataRow('ATHLETE', r.athleteDisplayName ?? r.profileId),
      _dataRow('NIVEAU', r.level.label),
      _dataRow('KETTLEBELL', '${r.weightKbKg} kg'),
      if (r.competitionName != null) _dataRow('COMPETITION', r.competitionName!),
    ]);
  }

  // ─── Section Scores ────────────────────────────────────────────────────────

  static pw.Widget _buildScores(RaceResult r) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      color: _cardBg,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('TEMPS OFFICIEL',
                  style: pw.TextStyle(color: _gris1, fontSize: 9)),
              pw.SizedBox(height: 4),
              pw.Text(TimeFormatter.format(r.finalTimeMs),
                  style: pw.TextStyle(color: _blanc, fontSize: 20,
                      fontWeight: pw.FontWeight.bold)),
            ],
          )),
          pw.Container(width: 1, height: 40, color: _gris1),
          pw.SizedBox(width: 16),
          pw.Expanded(child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('SCORE PLATEFORME',
                  style: pw.TextStyle(color: _gris1, fontSize: 9)),
              pw.SizedBox(height: 4),
              pw.Text(TimeFormatter.format(r.platformScore.round()),
                  style: pw.TextStyle(color: _vert, fontSize: 20,
                      fontWeight: pw.FontWeight.bold)),
            ],
          )),
        ],
      ),
    );
  }

  // ─── Section Splits ────────────────────────────────────────────────────────

  static pw.Widget _buildSplits(RaceResult r) {
    final rows = <pw.Widget>[
      for (int i = 0; i < r.splitsMs.length; i++)
        _dataRow('STATION ${i + 1}', TimeFormatter.format(r.splitsMs[i])),
      if (r.noCountEvents > 0)
        _dataRow('NO-COUNT', '${r.noCountEvents}x penalite'),
    ];
    return _section(rows, title: 'SPLITS');
  }

  // ─── Section Coefficients ──────────────────────────────────────────────────

  static pw.Widget _buildCoefficients(RaceResult r) {
    return _section([
      _dataRow('coeff_KB',   'x ${r.coeffKb.toStringAsFixed(3)}'),
      _dataRow('coeff_age',  'x ${r.coeffAge.toStringAsFixed(3)}'),
      _dataRow('coeff_sexe', 'x ${r.coeffSexe.toStringAsFixed(3)}'),
    ], title: 'COEFFICIENTS');
  }

  // ─── Section Energie ───────────────────────────────────────────────────────

  static pw.Widget _buildEnergie(RaceResult r) {
    return _section([
      _dataRow('Course', '${r.energyRunKcal?.toStringAsFixed(0)} kcal'),
      _dataRow('Acier',  '${r.energySteelKcal?.toStringAsFixed(0)} kcal'),
      _dataRow('Total',  '${r.energyTotalKcal?.toStringAsFixed(0)} kcal'),
    ], title: 'BILAN ENERGETIQUE', highlight: _ambre);
  }

  // ─── Footer ────────────────────────────────────────────────────────────────

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _gris1, width: 0.5)),
      ),
      child: pw.Text(
        'PENTARUN (c) KINETIC AXIOM / KAFORGE -- pentarun.netlify.app',
        style: pw.TextStyle(color: _gris1, fontSize: 8),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  static pw.Widget _section(List<pw.Widget> rows,
      {String? title, PdfColor? highlight}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      color: _cardBg,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            pw.Text(title,
                style: pw.TextStyle(color: highlight ?? _cyan, fontSize: 9,
                    fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
            pw.SizedBox(height: 8),
          ],
          ...rows,
        ],
      ),
    );
  }

  static pw.Widget _dataRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: _gris1, fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(color: _blanc, fontSize: 10,
              fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
