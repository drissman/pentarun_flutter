// SPEC-KIT §4.1 — Phase 2.3 Sprint 3+4 — Historique + graphique progression + export PDF
import 'dart:math' show min, max;

import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/athlete_profile.dart';
import 'package:pentarun_flutter/models/race_result.dart';
import 'package:pentarun_flutter/services/pdf_export_service.dart';
import 'package:pentarun_flutter/services/results_service.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';
import 'package:pentarun_flutter/utils/time_formatter.dart';

class HistoryScreen extends StatefulWidget {
  final AthleteProfile profile;
  const HistoryScreen({super.key, required this.profile});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RaceResult>? _results;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await ResultsService.getHistoryForProfile(widget.profile.id);
    if (mounted) setState(() { _results = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: A2Colors.bg,
      appBar: AppBar(
        backgroundColor: A2Colors.card,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: A2Colors.gris1),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.profile.displayName,
              style: const TextStyle(
                color: A2Colors.blanc,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            Text(
              '${widget.profile.ageCategory.label} · ${widget.profile.sexe.label}',
              style: const TextStyle(
                color: A2Colors.gris1,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: A2Colors.cyan))
          : (_results == null || _results!.isEmpty)
              ? _emptyState()
              : _body(),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, color: A2Colors.border2, size: 48),
          SizedBox(height: 16),
          Text(
            'AUCUNE COURSE ENREGISTRÉE',
            style: TextStyle(
              color: A2Colors.gris1,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    // _results est trié DESC (plus récent en premier) — on inverse pour le graphique
    final ascResults = _results!.reversed.toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Graphique progression (Sprint 3) — affiché si ≥ 2 résultats
        if (_results!.length >= 2) ...[
          const Text(
            'PROGRESSION',
            style: TextStyle(
              color: A2Colors.gris1,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          _ProgressionChart(results: ascResults),
          const SizedBox(height: 24),
        ],
        // Liste des résultats (Sprint 4 : bouton PDF sur chaque carte)
        ..._results!.asMap().entries.map((e) => _resultCard(e.value, e.key)),
      ],
    );
  }

  Widget _resultCard(RaceResult r, int index) {
    final isPb = index == 0; // Premier = meilleur score (trié DESC par platformScore asc)
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: A2Colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPb ? A2Colors.ambre : A2Colors.border,
          width: isPb ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + niveau + PB badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPb)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: A2Colors.ambre.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: A2Colors.ambre.withValues(alpha: 0.4)),
                    ),
                    child: const Text('MEILLEUR SCORE',
                        style: TextStyle(color: A2Colors.ambre, fontSize: 9,
                            fontWeight: FontWeight.w900)),
                  ),
                Text(
                  '${r.waveDate.day.toString().padLeft(2,'0')}/'
                  '${r.waveDate.month.toString().padLeft(2,'0')}/'
                  '${r.waveDate.year}',
                  style: const TextStyle(
                    color: A2Colors.gris1, fontWeight: FontWeight.w700, fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${r.level.label} · ${r.weightKbKg} KG',
                  style: const TextStyle(
                    color: A2Colors.cyan, fontWeight: FontWeight.w900, fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Scores + bouton PDF (Sprint 4)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                TimeFormatter.format(r.finalTimeMs),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: A2Colors.blanc,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'SCORE ${TimeFormatter.format(r.platformScore.round())}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: A2Colors.vert,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              // SPEC-KIT §9.4 — Sprint 4 : export PDF
              GestureDetector(
                onTap: () => _exportPdf(r),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: A2Colors.border,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: A2Colors.border2),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.picture_as_pdf, color: A2Colors.gris1, size: 12),
                      SizedBox(width: 4),
                      Text('PDF',
                          style: TextStyle(color: A2Colors.gris1, fontSize: 9,
                              fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportPdf(RaceResult r) {
    // Injecte le nom d'affichage depuis le profil si absent dans le résultat
    final enriched = r.athleteDisplayName != null
        ? r
        : RaceResult(
            id: r.id,
            profileId: r.profileId,
            competitionName: r.competitionName,
            waveDate: r.waveDate,
            level: r.level,
            weightKbKg: r.weightKbKg,
            coeffKb: r.coeffKb,
            coeffAge: r.coeffAge,
            coeffSexe: r.coeffSexe,
            finalTimeMs: r.finalTimeMs,
            officialScore: r.officialScore,
            platformScore: r.platformScore,
            splitsMs: r.splitsMs,
            noCountEvents: r.noCountEvents,
            energyRunKcal: r.energyRunKcal,
            energySteelKcal: r.energySteelKcal,
            energyTotalKcal: r.energyTotalKcal,
            athleteDisplayName: widget.profile.displayName,
          );
    PdfExportService.exportResult(enriched);
  }
}

// ─── Graphique de progression ─────────────────────────────────────────────────

class _ProgressionChart extends StatelessWidget {
  final List<RaceResult> results; // Triés ASC par date

  const _ProgressionChart({required this.results});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: A2Colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: A2Colors.border),
      ),
      child: CustomPaint(
        painter: _ChartPainter(results: results),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<RaceResult> results;

  _ChartPainter({required this.results});

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 60.0, padR = 12.0, padT = 12.0, padB = 28.0;
    final chartW = size.width - padL - padR;
    final chartH = size.height - padT - padB;

    final scores = results.map((r) => r.platformScore).toList();
    final minScore = scores.reduce(min);
    final maxScore = scores.reduce(max);
    // Ajoute une marge de 10% pour que les points ne collent pas aux bords
    final range = (maxScore - minScore) * 1.2;
    final effectiveMin = minScore - (range - (maxScore - minScore)) / 2;

    // ── Grilles horizontales (4 lignes) ──────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0xFF1F1F1F)
      ..strokeWidth = 1;

    const labelStyle = TextStyle(
      color: A2Colors.gris1,
      fontSize: 8,
      fontFamily: 'monospace',
      fontWeight: FontWeight.w700,
    );

    for (int i = 0; i <= 3; i++) {
      final t = i / 3.0;
      final y = padT + t * chartH;
      canvas.drawLine(Offset(padL, y), Offset(padL + chartW, y), gridPaint);

      // Valeur du score à cette hauteur (y=0 → maxScore+marge, y=chartH → minScore-marge)
      final scoreAtY = effectiveMin + (1 - t) * range;
      final label = TimeFormatter.format(scoreAtY.round().clamp(0, 9999999));
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(padL - tp.width - 4, y - tp.height / 2));
    }

    // ── Axe X — dates ─────────────────────────────────────────────────────────
    final maxLabels = (chartW / 60).floor().clamp(2, results.length);
    final step = (results.length / maxLabels).ceil();
    for (int i = 0; i < results.length; i += step) {
      final x = padL + (results.length == 1 ? 0.5 : i / (results.length - 1)) * chartW;
      final d = results[i].waveDate;
      final label = '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}';
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - padB + 6));
    }

    // ── Ligne de progression ──────────────────────────────────────────────────
    final linePaint = Paint()
      ..color = A2Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final points = <Offset>[];
    for (int i = 0; i < results.length; i++) {
      final x = padL + (results.length == 1 ? 0.5 : i / (results.length - 1)) * chartW;
      final normalizedY = range > 0
          ? (results[i].platformScore - effectiveMin) / range
          : 0.5;
      final y = padT + (1 - normalizedY) * chartH;
      points.add(Offset(x, y));
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, linePaint);

    // ── Points de données ─────────────────────────────────────────────────────
    final pbIndex = scores.indexOf(minScore); // Meilleur score = valeur la plus basse

    for (int i = 0; i < points.length; i++) {
      final isPb = i == pbIndex;

      // Halo pour le PB
      if (isPb) {
        canvas.drawCircle(
          points[i],
          8,
          Paint()..color = A2Colors.ambre.withValues(alpha: 0.2),
        );
      }

      // Remplissage du point
      canvas.drawCircle(
        points[i],
        isPb ? 5 : 3.5,
        Paint()..color = isPb ? A2Colors.ambre : A2Colors.blanc,
      );

      // Label PB au-dessus
      if (isPb) {
        final tp = TextPainter(
          text: const TextSpan(
            text: 'PB',
            style: TextStyle(color: A2Colors.ambre, fontSize: 8,
                fontWeight: FontWeight.w900, fontFamily: 'monospace'),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(points[i].dx - tp.width / 2, points[i].dy - 18));
      }
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.results.length != results.length ||
      (results.isNotEmpty && old.results.first.id != results.first.id);
}
