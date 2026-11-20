import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';

class TornPaperClipper extends CustomClipper<Path> {
  const TornPaperClipper({required this.seed, this.foldProgress = 0});

  final double seed;
  final double foldProgress;

  static Path buildPath(Size size, double seed, {double foldProgress = 0}) {
    const margin = 5.0;
    const steps = 26;
    final variance = 2.0 + foldProgress * 6.0;

    double hash(double n) {
      final s = math.sin(n * 127.1 + seed * 311.7) * 43758.5453;
      return s - s.floor();
    }

    double noise(double t) => (hash(t) * 2) - 1;

    final path = Path()..moveTo(margin, margin + noise(0) * variance);

    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      path.lineTo(
        margin + t * (size.width - margin * 2),
        margin + noise(t * 3.1) * variance,
      );
    }
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      path.lineTo(
        (size.width - margin) + noise(t * 2.7 + 10) * variance,
        margin + t * (size.height - margin * 2),
      );
    }
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      path.lineTo(
        (size.width - margin) - t * (size.width - margin * 2),
        (size.height - margin) + noise(t * 3.3 + 20) * variance,
      );
    }
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      path.lineTo(
        margin + noise(t * 2.9 + 30) * variance,
        (size.height - margin) - t * (size.height - margin * 2),
      );
    }

    path.close();
    return path;
  }

  @override
  Path getClip(Size size) => buildPath(size, seed, foldProgress: foldProgress);

  @override
  bool shouldReclip(covariant TornPaperClipper old) =>
      old.seed != seed || old.foldProgress != foldProgress;
}

// ── Paper grain — more dots, slightly stronger ──────────────────────────────
class PaperGrainPainter extends CustomPainter {
  const PaperGrainPainter({required this.seed});

  final double seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random((seed * 1000).toInt());

    // Fine dust
    final dustPaint = Paint()
      ..color = const Color(0xFF8B7D6B).withOpacity(0.045);
    for (int i = 0; i < 500; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 0.75 + 0.1,
        dustPaint,
      );
    }

    // Slightly larger fibre flecks
    final fleckPaint = Paint()
      ..color = const Color(0xFF7A6A58).withOpacity(0.022);
    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final len = random.nextDouble() * 4 + 1;
      final angle = random.nextDouble() * math.pi;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + math.cos(angle) * len, y + math.sin(angle) * len),
        fleckPaint..strokeWidth = random.nextDouble() * 0.5 + 0.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PaperGrainPainter old) => old.seed != seed;
}

// ── Outer torn-edge border (gold) ───────────────────────────────────────────
class ShareOuterBorderPainter extends CustomPainter {
  const ShareOuterBorderPainter({required this.seed});

  final double seed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      TornPaperClipper.buildPath(size, seed),
      Paint()
        ..color = AppColors.borderGold.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant ShareOuterBorderPainter old) => old.seed != seed;
}

// ── Inner paper edge + highlight ────────────────────────────────────────────
class ShareInnerBorderPainter extends CustomPainter {
  const ShareInnerBorderPainter({required this.seed});

  final double seed;

  @override
  void paint(Canvas canvas, Size size) {
    final original = TornPaperClipper.buildPath(size, seed);

    // Inner shadow line — deeper brown, slightly thicker
    final inner = original.transform(
      (Matrix4.identity()
            ..translate(size.width * 0.004, size.height * 0.006)
            ..scale(0.992, 0.988))
          .storage,
    );

    canvas.drawPath(
      inner,
      Paint()
        ..color = const Color(0xFF7A6348).withOpacity(0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Second inner shadow — softer, further in
    final inner2 = original.transform(
      (Matrix4.identity()
            ..translate(size.width * 0.007, size.height * 0.009)
            ..scale(0.985, 0.978))
          .storage,
    );

    canvas.drawPath(
      inner2,
      Paint()
        ..color = const Color(0xFF9B896E).withOpacity(0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // White highlight — paper catching light
    final highlight = original.transform(
      (Matrix4.identity()
            ..translate(size.width * 0.008, size.height * 0.010)
            ..scale(0.976, 0.958))
          .storage,
    );

    canvas.drawPath(
      highlight,
      Paint()
        ..color = Colors.white.withOpacity(0.52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
  }

  @override
  bool shouldRepaint(covariant ShareInnerBorderPainter old) => old.seed != seed;
}

// ── Top-left highlight shimmer ───────────────────────────────────────────────
class ShareHighlightPainter extends CustomPainter {
  const ShareHighlightPainter({required this.seed, this.t = 0});

  final double seed;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final shift = (t - 0.5) * 10;

    canvas.drawPath(
      TornPaperClipper.buildPath(
        size,
        seed,
      ).shift(Offset(-0.4 + shift * 0.05, -0.4)),
      Paint()
        ..color = Colors.white.withOpacity(0.18 + t * 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(-0.75 + t * 0.2, -0.75),
          radius: 1.05,
          colors: [
            Colors.white.withOpacity(0.07 + t * 0.05),
            Colors.transparent,
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant ShareHighlightPainter old) =>
      old.seed != seed || old.t != t;
}

// ── Brown drop shadow painter (used behind the card) ────────────────────────
class PaperShadowPainter extends CustomPainter {
  const PaperShadowPainter({required this.seed, this.elevation = 1.0});

  final double seed;
  final double elevation; // 0.0 → 1.0, press drives this

  @override
  void paint(Canvas canvas, Size size) {
    final path = TornPaperClipper.buildPath(size, seed);

    // Layer 1 — wide soft shadow
    canvas.drawShadow(
      path.shift(Offset(0, 3 + elevation * 4)),
      const Color(0xFF5C4030),
      6 + elevation * 6,
      false,
    );

    // Layer 2 — tighter darker core
    canvas.drawShadow(
      path.shift(Offset(0, 1.5 + elevation * 2)),
      const Color(0xFF3D2A1A),
      2 + elevation * 3,
      false,
    );
  }

  @override
  bool shouldRepaint(covariant PaperShadowPainter old) =>
      old.seed != old.seed || old.elevation != elevation;
}

// ── Disintegrating clipper (delete animation) ────────────────────────────────
class DisintegratingCardClipper extends CustomClipper<Path> {
  const DisintegratingCardClipper({required this.progress, required this.seed});

  final double progress;
  final double seed;

  double _hash(double n) {
    final s = math.sin(n * 127.1 + seed * 311.7) * 43758.5453;
    return s - s.floor();
  }

  double _noise(double n) => (_hash(n) * 2.0) - 1.0;

  @override
  Path getClip(Size size) {
    final path = Path();

    if (progress <= 0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    final eased = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
    final edgeX = size.width - (size.width * eased);
    const points = 42;

    path.moveTo(0, 0);
    path.lineTo(math.max(0, edgeX), 0);

    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final y = t * size.height;
      final noise = _noise(i * 4.73 + 17.0) * (4.0 + progress * 10.0);
      final x = math.max(0.0, edgeX + noise);
      path.lineTo(x, y);
    }

    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant DisintegratingCardClipper old) =>
      old.progress != progress || old.seed != seed;
}

// ── Edge dust (delete animation) ─────────────────────────────────────────────
class EdgeDustPainter extends CustomPainter {
  const EdgeDustPainter({required this.progress, required this.seed});

  final double progress;
  final double seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.05 || progress >= 1.0) return;

    final random = math.Random((seed * 1000).toInt());
    final eased = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
    final edgeX = size.width - (size.width * eased);

    for (int i = 0; i < 150; i++) {
      final normalized = i / 150;
      final y = random.nextDouble() * size.height;
      final distance = random.nextDouble() * (18 + progress * 45);
      final x = edgeX + distance * Curves.easeOut.transform(progress);
      final drift = math.sin(normalized * math.pi * 6 + seed) * 7;
      final finalY = y + drift + (progress * 10 * (random.nextDouble() - 0.5));
      final radius = 0.35 + random.nextDouble() * (1.4 - progress * 0.45);
      final opacity = ((1.0 - progress) * (0.25 + random.nextDouble() * 0.55))
          .clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(x, finalY),
        radius,
        Paint()..color = Color.fromRGBO(139, 125, 107, opacity),
      );
    }

    for (int i = 0; i < 22; i++) {
      final y = random.nextDouble() * size.height;
      final distance = random.nextDouble() * (12 + progress * 35);
      final x = edgeX + distance;
      final sizeParticle = 1.2 + random.nextDouble() * 2.0;
      final opacity = ((1.0 - progress) * 0.45).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * math.pi);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: sizeParticle * 1.7,
          height: sizeParticle,
        ),
        Paint()..color = Color.fromRGBO(211, 198, 175, opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant EdgeDustPainter old) =>
      old.progress != progress || old.seed != seed;
}
