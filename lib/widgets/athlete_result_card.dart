import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/models/athlete.dart';
import 'package:pentarun_flutter/models/station.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';
import 'package:pentarun_flutter/utils/time_formatter.dart';
import 'package:pentarun_flutter/widgets/send_dialog.dart';
import 'package:pentarun_flutter/widgets/signature_pad.dart';

class AthleteResultCard extends StatelessWidget {
  final Athlete athlete;
  const AthleteResultCard({super.key, required this.athlete});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final finished = athlete.status == AthleteStatus.finished;

    return Container(
      decoration: BoxDecoration(
        color: A2Colors.card,
        border: Border.all(color: A2Colors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 500;
                final nameAndTags = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        color: A2Colors.blanc,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _tag(athlete.level.label),
                        _tag('${athlete.weightKb} KG', color: A2Colors.cyan),
                        _tag('COEFF: ${athlete.coeff.toStringAsFixed(3)}',
                            mono: true),
                        if (athlete.noCountEvents > 0)
                          _tag('No-Count ×${athlete.noCountEvents}',
                              color: A2Colors.rouge),
                      ],
                    ),
                  ],
                );

                final scoreBox = finished
                    ? _scoreBox()
                    : _dnfBox();

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: nameAndTags),
                      const SizedBox(width: 16),
                      scoreBox,
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      nameAndTags,
                      const SizedBox(height: 16),
                      scoreBox,
                    ],
                  );
                }
              },
            ),
          ),

          // Energy breakdown
          if (finished) _energyBreakdown(),

          // Graphique splits par station
          if (finished && athlete.splits.length == Station.count)
            _splitChart(state.startTime ?? DateTime.now()),

          // Signatures
          if (finished) _signaturesSection(context, state),
        ],
      ),
    );
  }

  Widget _scoreBox() {
    return Container(
      constraints: const BoxConstraints(minWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: A2Colors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF052E16), width: 2),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: A2Colors.vert, size: 12),
              SizedBox(width: 4),
              Text(
                'SCORE OFFICIEL PENTARUN',
                style: TextStyle(
                  color: A2Colors.vert,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            TimeFormatter.format(athlete.officialScore?.round()),
            style: const TextStyle(
              fontFamily: 'monospace',
              color: A2Colors.blanc,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'T.BRUT: ${TimeFormatter.format(athlete.finalTimeMs)} · C: ${athlete.coeff.toStringAsFixed(3)}',
            style: const TextStyle(
              fontFamily: 'monospace',
              color: A2Colors.gris1,
              fontSize: 10,
            ),
          ),
          // SPEC-KIT §5.2 — scorePlateforme (affiché si profil lié)
          if (athlete.platformScore != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: A2Colors.cyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: A2Colors.cyan.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'SCORE PLATEFORME',
                    style: TextStyle(
                      color: A2Colors.cyan,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    TimeFormatter.format(athlete.platformScore!.round()),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: A2Colors.cyan,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Cage×${athlete.coeff.toStringAsFixed(3)}'
                    ' · Age×${athlete.coeffAge?.toStringAsFixed(3) ?? '—'}'
                    ' · Sexe×${athlete.coeffSexe?.toStringAsFixed(3) ?? '—'}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: A2Colors.gris1,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dnfBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0505),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5A1A1A), width: 2),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close, color: A2Colors.rouge, size: 16),
          SizedBox(width: 6),
          Text(
            'DNF — NON TERMINÉ',
            style: TextStyle(
              color: A2Colors.rouge,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _energyBreakdown() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF110D00),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 500;
          final header = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flash_on, color: A2Colors.ambre, size: 26),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    // SPEC-KIT §3.2 ERRATA v1.4 — h_oh=H×1.22 (recalibré)
                    'BILAN MÉTABOLIQUE (h_oh=H×1.22 ✓)',
                    style: TextStyle(
                      color: A2Colors.ambre,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'H:${athlete.heightAthlete}cm / M:${athlete.weightAthlete}kg',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: A2Colors.gris1,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          );

          final values = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _energyValue('Course', athlete.energy.run.round()),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('+',
                    style: TextStyle(color: A2Colors.gris1, fontSize: 22)),
              ),
              _energyValue('Acier', athlete.energy.steel.round()),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('=',
                    style: TextStyle(color: Color(0xFF664400), fontSize: 22)),
              ),
              _totalBox(),
            ],
          );

          if (wide) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: header),
                const SizedBox(width: 16),
                values,
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 16),
                Center(child: values),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _energyValue(String label, int value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: A2Colors.gris1,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                fontFamily: 'monospace',
                color: A2Colors.blanc,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              ' KCAL',
              style: TextStyle(
                fontFamily: 'monospace',
                color: A2Colors.gris1,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _totalBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1800),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF664400)),
      ),
      child: Column(
        children: [
          // SPEC-KIT §3.2 ERRATA v1.4 — EPOC HIIT : 1.15 → 1.30
          const Text(
            'TOTAL EPOC ×1.30',
            style: TextStyle(
              color: A2Colors.ambre,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                athlete.energy.total.round().toString(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: A2Colors.ambre,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                ' KCAL',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: A2Colors.ambre,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signaturesSection(BuildContext context, AppState state) {
    final hasBoth =
        athlete.judgeSignature != null && athlete.athleteSignature != null;

    return Container(
      color: const Color(0xFF070707),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (ctx, constraints) {
              final wide = constraints.maxWidth > 580;
              final pads = [
                Flexible(
                  child: SignaturePad(
                    title: 'Juge Officiel',
                    onSign: (data) =>
                        state.setJudgeSignature(athlete.id, data),
                  ),
                ),
                if (wide) const SizedBox(width: 16) else const SizedBox(height: 16),
                Flexible(
                  child: SignaturePad(
                    title: 'Athlète',
                    onSign: (data) =>
                        state.setAthleteSignature(athlete.id, data),
                  ),
                ),
              ];
              return wide
                  ? Row(children: pads)
                  : Column(children: pads);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: hasBoth
                ? () => showDialog(
                      context: context,
                      builder: (_) => SendDialog(
                        athlete: athlete,
                        onSealed: () {
                          Navigator.of(context).pop();
                          state.sealAthlete(athlete);
                        },
                      ),
                    )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasBoth ? A2Colors.cyan : const Color(0xFF1A1A1A),
              foregroundColor: hasBoth ? Colors.black : A2Colors.gris1,
              disabledBackgroundColor: const Color(0xFF252525),
              disabledForegroundColor: A2Colors.gris1,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.lock, size: 18),
            label: const Text(
              'SCELLER & TRANSMETTRE',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _splitChart(DateTime startTime) {
    final deltas = athlete.splits.asMap().entries.map((e) {
      final prev = e.key == 0 ? startTime : athlete.splits[e.key - 1];
      return e.value.difference(prev).inMilliseconds;
    }).toList();

    return Container(
      width: double.infinity,
      color: const Color(0xFF0D0D0D),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: A2Colors.cyan, size: 18),
              SizedBox(width: 8),
              Text(
                'ANALYSE PAR STATION — SPLITS',
                style: TextStyle(
                  color: A2Colors.cyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: CustomPaint(
              painter: _SplitChartPainter(deltas: deltas),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, {Color color = A2Colors.gris1, bool mono = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: mono ? 'monospace' : null,
        ),
      ),
    );
  }
}

// ─── Graphique Splits par Station ─────────────────────────────────────────────

class _SplitChartPainter extends CustomPainter {
  final List<int> deltas;

  const _SplitChartPainter({required this.deltas});

  @override
  void paint(Canvas canvas, Size size) {
    if (deltas.isEmpty) return;

    final maxVal = deltas.reduce((a, b) => a > b ? a : b).toDouble();
    final minIdx = deltas.indexOf(deltas.reduce((a, b) => a < b ? a : b));
    final maxIdx = deltas.indexOf(deltas.reduce((a, b) => a > b ? a : b));

    const labelH = 28.0;
    const valueH = 16.0;
    final chartH = size.height - labelH - valueH;
    final count = deltas.length;
    final gap = 8.0;
    final barW = (size.width - (count - 1) * gap) / count;

    for (int i = 0; i < count; i++) {
      final ratio = maxVal > 0 ? deltas[i] / maxVal : 0.0;
      final barH = chartH * ratio;
      final x = i * (barW + gap);
      final y = valueH + (chartH - barH);

      final Color barColor;
      if (i == minIdx) {
        barColor = A2Colors.vert;
      } else if (i == maxIdx) {
        barColor = A2Colors.ambre;
      } else {
        barColor = A2Colors.cyan.withValues(alpha: 0.55);
      }

      // Barre
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barW, barH),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()..color = barColor,
      );

      // Label station sous barre
      _drawText(
        canvas,
        'S${i + 1}',
        Offset(x + barW / 2, size.height - labelH + 6),
        const TextStyle(
          color: A2Colors.gris1,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
        centerX: true,
      );

      // Valeur temps au-dessus
      final ms = deltas[i];
      final secs = ms ~/ 1000;
      final mins = secs ~/ 60;
      final s = secs % 60;
      final cs = (ms % 1000) ~/ 10;
      final timeStr =
          '${mins.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${cs.toString().padLeft(2, '0')}';

      _drawText(
        canvas,
        timeStr,
        Offset(x + barW / 2, y - 14),
        TextStyle(
          color: barColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
        centerX: true,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style,
      {bool centerX = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final dx = centerX ? position.dx - tp.width / 2 : position.dx;
    tp.paint(canvas, Offset(dx, position.dy));
  }

  @override
  bool shouldRepaint(_SplitChartPainter old) => old.deltas != deltas;
}
