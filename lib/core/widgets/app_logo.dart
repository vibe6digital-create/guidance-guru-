import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Guidance Guru logo — a stylised compass rose with an elongated north
/// needle and a four-pointed AI-sparkle at the tip.
///
/// Works at any size (32–100 px) and inherits [color] for tinting.
class AppLogo extends StatelessWidget {
  final double size;
  final Color color;

  const AppLogo({
    super.key,
    this.size = 40,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(color: color),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;
  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dimFill = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    // ── North needle (tall, prominent) ──────────────────────────
    final north = Path()
      ..moveTo(cx, cy - r * 0.92) // tip
      ..lineTo(cx + r * 0.19, cy) // right base
      ..lineTo(cx, cy + r * 0.06) // inner notch
      ..lineTo(cx - r * 0.19, cy) // left base
      ..close();
    canvas.drawPath(north, fill);

    // ── South needle (shorter, dimmer) ──────────────────────────
    final south = Path()
      ..moveTo(cx, cy + r * 0.62)
      ..lineTo(cx + r * 0.15, cy)
      ..lineTo(cx, cy - r * 0.06)
      ..lineTo(cx - r * 0.15, cy)
      ..close();
    canvas.drawPath(south, dimFill);

    // ── East needle ─────────────────────────────────────────────
    final east = Path()
      ..moveTo(cx + r * 0.62, cy)
      ..lineTo(cx, cy - r * 0.15)
      ..lineTo(cx - r * 0.06, cy)
      ..lineTo(cx, cy + r * 0.15)
      ..close();
    canvas.drawPath(east, dimFill);

    // ── West needle ─────────────────────────────────────────────
    final west = Path()
      ..moveTo(cx - r * 0.62, cy)
      ..lineTo(cx, cy - r * 0.15)
      ..lineTo(cx + r * 0.06, cy)
      ..lineTo(cx, cy + r * 0.15)
      ..close();
    canvas.drawPath(west, dimFill);

    // ── Centre dot ──────────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), r * 0.09, fill);

    // ── Sparkle at the top of the north needle ──────────────────
    // A tiny 4-pointed star that gives an "AI / guiding light" feel.
    final sparkCy = cy - r * 0.92;
    final sp = r * 0.18; // sparkle radius

    final sparkle = Path()
      // vertical line
      ..moveTo(cx, sparkCy - sp)
      ..lineTo(cx + sp * 0.22, sparkCy)
      ..lineTo(cx, sparkCy + sp * 0.55)
      ..lineTo(cx - sp * 0.22, sparkCy)
      ..close()
      // horizontal line
      ..moveTo(cx - sp * 0.65, sparkCy)
      ..lineTo(cx, sparkCy - sp * 0.22)
      ..lineTo(cx + sp * 0.65, sparkCy)
      ..lineTo(cx, sparkCy + sp * 0.22)
      ..close();

    canvas.drawPath(sparkle, fill);

    // ── Small accent dots at 45° positions ──────────────────────
    final dotR = r * 0.035;
    final dotDist = r * 0.50;
    for (final angle in [math.pi / 4, 3 * math.pi / 4, 5 * math.pi / 4, 7 * math.pi / 4]) {
      canvas.drawCircle(
        Offset(cx + dotDist * math.cos(angle), cy - dotDist * math.sin(angle)),
        dotR,
        Paint()..color = color.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.color != color;
}
