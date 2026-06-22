import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/constants/app_colors.dart';

class ArcSpinnerPainter extends CustomPainter {
  final double progress;
  const ArcSpinnerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.navy.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + (progress * 2 * math.pi),
      math.pi * 1.3,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF3A8FE8), Color(0xFF3DAA5C)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(ArcSpinnerPainter old) => old.progress != progress;
}