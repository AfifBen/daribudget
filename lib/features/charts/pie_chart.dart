import 'dart:math' as math;

import 'package:flutter/material.dart';

class PieSlice {
  final double value;
  final Color color;
  final String label;

  const PieSlice({required this.value, required this.color, required this.label});
}

class SimplePieChart extends StatelessWidget {
  final List<PieSlice> slices;
  final double size;
  final String? centerText;

  const SimplePieChart({super.key, required this.slices, this.size = 140, this.centerText});

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (s, x) => s + x.value);
    if (total <= 0) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: Text('0%')),
      );
    }

    return CustomPaint(
      size: Size.square(size),
      painter: _PiePainter(
        slices: slices,
        total: total,
        ringWidth: 18,
        centerText: centerText,
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<PieSlice> slices;
  final double total;
  final double ringWidth;
  final String? centerText;

  _PiePainter({required this.slices, required this.total, required this.ringWidth, this.centerText});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.butt
      ..color = Colors.white10;

    canvas.drawCircle(center, radius - ringWidth / 2, bgPaint);

    double startAngle = -math.pi / 2;
    for (final s in slices) {
      final sweep = (s.value / total) * (2 * math.pi);
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.butt
        ..color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - ringWidth / 2),
        startAngle,
        sweep,
        false,
        p,
      );
      startAngle += sweep;
    }

    // Center text
    final label = centerText;
    if (label != null && label.trim().isNotEmpty) {
      final tp = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      )..layout();

      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.total != total;
  }
}
