import 'dart:math';
import 'package:flutter/material.dart';

class PaperTexture extends StatelessWidget {
  const PaperTexture({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _PaperPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  final Random random = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < 350; i++) {
      paint.color = Colors.brown.withOpacity(0.015);

      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 1.3,
        paint,
      );
    }

    paint.color = Colors.white.withOpacity(.03);

    for (int i = 0; i < 180; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 1.6,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}