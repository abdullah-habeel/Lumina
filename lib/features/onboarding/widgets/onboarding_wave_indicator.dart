import 'package:flutter/material.dart';

class OnboardingWaveIndicator extends StatelessWidget {
  final int totalPages;
  final int currentIndex;

  const OnboardingWaveIndicator({
    super.key,
    required this.totalPages,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        height: 20,
        child: CustomPaint(
          painter: _WavePainter(
            progress: (currentIndex + 1) / totalPages,
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  _WavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double midY = size.height / 2;
    final double filledWidth = size.width * progress;

    // --- background wave (unfilled) ---
    final bgPaint = Paint()
      ..color = const Color(0xFFD4C5A9)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(_buildWavePath(size.width, midY, size), bgPaint);

    // --- filled wave (clipped to progress) ---
    final filledPaint = Paint()
      ..color = const Color(0xFF2F4F3F)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, filledWidth, size.height));
    canvas.drawPath(_buildWavePath(size.width, midY, size), filledPaint);
    canvas.restore();
  }

  Path _buildWavePath(double width, double midY, Size size) {
    final path = Path();
    path.moveTo(0, midY);

    const int waves = 6;
    final double waveWidth = width / waves;

    for (int i = 0; i < waves; i++) {
      final double startX = i * waveWidth;
      final bool isUp = i.isEven;

      path.cubicTo(
        startX + waveWidth * 0.25,
        isUp ? midY - 6 : midY + 6,
        startX + waveWidth * 0.75,
        isUp ? midY - 6 : midY + 6,
        startX + waveWidth,
        midY,
      );
    }

    return path;
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}