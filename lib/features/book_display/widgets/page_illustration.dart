import 'package:flutter/material.dart';

/// Draws an ornate corner-flourish frame directly on the canvas.
/// The center is fully transparent so the real page texture behind it
/// shows through — no more mismatched rectangle / white overlay.
class PageIllustration extends StatelessWidget {
  final double width;
  final double height;
  final Color lineColor;

  const PageIllustration({
    super.key,
    this.width = 130,
    this.height = 170,
    this.lineColor = const Color(0xFF8B6B4A), // warm brown, matches ink tone
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _FrameCornerPainter(color: lineColor),
      ),
    );
  }
}

class _FrameCornerPainter extends CustomPainter {
  final Color color;

  _FrameCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint border = Paint()
      ..color = color.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final Paint flourish = Paint()
      ..color = color.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final Rect borderRect = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
    canvas.drawRect(borderRect, border);

    const double cornerSize = 22;

    _drawCorner(canvas, flourish, const Offset(3, 3), cornerSize, 0);
    _drawCorner(canvas, flourish, Offset(size.width - 3, 3), cornerSize, 90);
    _drawCorner(canvas, flourish, Offset(size.width - 3, size.height - 3), cornerSize, 180);
    _drawCorner(canvas, flourish, Offset(3, size.height - 3), cornerSize, 270);
  }

  void _drawCorner(Canvas canvas, Paint paint, Offset corner, double s, double angleDeg) {
    canvas.save();
    canvas.translate(corner.dx, corner.dy);
    canvas.rotate(angleDeg * 3.1415926535 / 180);

    final Path path = Path()
      ..moveTo(0, s)
      ..quadraticBezierTo(0, 0, s, 0)
      ..moveTo(s * 0.35, 0)
      ..quadraticBezierTo(s * 0.55, s * 0.2, s * 0.35, s * 0.4)
      ..moveTo(0, s * 0.35)
      ..quadraticBezierTo(s * 0.2, s * 0.55, s * 0.4, s * 0.35);

    canvas.drawPath(path, paint);

    canvas.drawCircle(Offset(s * 0.15, s * 0.15), 1.6, paint..style = PaintingStyle.fill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FrameCornerPainter oldDelegate) =>
      oldDelegate.color != color;
}