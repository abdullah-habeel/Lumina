import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'dart:math' as math;
import 'package:flutter/material.dart';

class QuestionTimelineClipper extends CustomClipper<Path> {
  const QuestionTimelineClipper();

  @override
  Path getClip(Size size) {
    final path = Path();

    const inset = 3.0;

    // ─────────────────────────────────────────────
    // TOP EDGE — subtle handmade paper variation
    // ─────────────────────────────────────────────

    path.moveTo(inset, inset);

    const topSteps = 40;

    for (int i = 1; i <= topSteps; i++) {
      final x =
          inset + (size.width - inset * 2) * i / topSteps;

      final y = inset +
          math.sin(i * 0.9) * 0.45 +
          math.sin(i * 0.27) * 0.25;

      path.lineTo(x, y);
    }

    // ─────────────────────────────────────────────
    // RIGHT EDGE — almost straight
    // ─────────────────────────────────────────────

    const rightSteps = 20;

    for (int i = 1; i <= rightSteps; i++) {
      final y =
          inset + (size.height - inset * 2) * i / rightSteps;

      final x = size.width -
          inset +
          math.sin(i * 0.8) * 0.25;

      path.lineTo(x, y);
    }

    // ─────────────────────────────────────────────
    // BOTTOM EDGE — subtle handmade variation
    // ─────────────────────────────────────────────

    const bottomSteps = 40;

    for (int i = 1; i <= bottomSteps; i++) {
      final x = size.width -
          inset -
          (size.width - inset * 2) * i / bottomSteps;

      final y = size.height -
          inset +
          math.sin(i * 0.9 + 1.5) * 0.45 +
          math.sin(i * 0.27) * 0.25;

      path.lineTo(x, y);
    }

    // ─────────────────────────────────────────────
    // LEFT EDGE — subtle torn paper
    // ─────────────────────────────────────────────

    const leftSteps = 28;

    for (int i = 1; i <= leftSteps; i++) {
      final y =
          size.height -
          inset -
          (size.height - inset * 2) * i / leftSteps;

      final x = inset +
          math.sin(i * 1.15) * 0.9 +
          math.sin(i * 0.43) * 0.35;

      path.lineTo(x, y);
    }

    path.close();

    return path;
  }

  @override
  bool shouldReclip(
    covariant QuestionTimelineClipper oldClipper,
  ) {
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHADOW
// ─────────────────────────────────────────────────────────────────────────────

class QuestionTimelineShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path =
        const QuestionTimelineClipper().getClip(size);

    canvas.drawShadow(
      path.shift(const Offset(0, 3)),
      const Color(0xFF6B4A2E),
      4,
      false,
    );
  }

  @override
  bool shouldRepaint(
    covariant QuestionTimelineShadowPainter oldDelegate,
  ) {
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BORDER
// ─────────────────────────────────────────────────────────────────────────────

class QuestionTimelineBorderPainter
    extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path =
        const QuestionTimelineClipper().getClip(size);

    // Main antique border.
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB18A4B)
            .withOpacity(.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8,
    );

    // Very subtle inner line.
    final inner = path.transform(
      (Matrix4.identity()
            ..translate(1.2, 1.0)
            ..scale(.994, .978))
          .storage,
    );

    canvas.drawPath(
      inner,
      Paint()
        ..color = const Color(0xFF80613A)
            .withOpacity(.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .65,
    );
  }

  @override
  bool shouldRepaint(
    covariant QuestionTimelineBorderPainter oldDelegate,
  ) {
    return false;
  }
}