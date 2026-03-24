import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class SignaturePad extends StatefulWidget {
  final String title;
  final ValueChanged<Uint8List?> onSign;

  const SignaturePad({super.key, required this.title, required this.onSign});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;
  final GlobalKey _repaintKey = GlobalKey();

  void _onPanStart(DragStartDetails details) {
    _currentStroke = [details.localPosition];
    setState(() {
      _strokes.add(_currentStroke!);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _currentStroke?.add(details.localPosition);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    _currentStroke = null;
    _captureSignature();
  }

  Future<void> _captureSignature() async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      widget.onSign(byteData.buffer.asUint8List());
    }
  }

  void _clear() {
    setState(() {
      _strokes.clear();
    });
    widget.onSign(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: A2Colors.surfaceDark,
        border: Border.all(color: A2Colors.border2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit, color: A2Colors.cyan, size: 13),
              const SizedBox(width: 6),
              Text(
                widget.title.toUpperCase(),
                style: const TextStyle(
                  color: A2Colors.cyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RepaintBoundary(
            key: _repaintKey,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                width: 280,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF030303),
                  border: Border.all(color: A2Colors.border2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CustomPaint(
                    painter: _SignaturePainter(_strokes),
                    size: const Size(280, 110),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _clear,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: A2Colors.gris1, size: 11),
                SizedBox(width: 4),
                Text(
                  'RÉINITIALISER',
                  style: TextStyle(
                    color: A2Colors.gris1,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = A2Colors.cyan
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}
