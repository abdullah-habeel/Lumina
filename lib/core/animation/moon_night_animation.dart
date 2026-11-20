import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// ===============================================================
/// MOONLIT BOOK BACKGROUND
///
/// Interaction 1 — Tap the moon:
///   1. Moon slowly brightens.
///   2. A soft circle of moonlight expands across the sky.
///   3. Sky darkens into a beautiful midnight blue.
///   4. Tiny stars gradually appear.
///
/// Interaction 2 — Tap the sky (once night has settled):
///   Soft ribbons of muted green, gold, and blue flow across the
///   background — subtle and painterly, not a bright realistic
///   aurora. Lasts ~7 seconds, then slowly fades.
///
/// Designed for the "Book of Me" vintage/night aesthetic.
/// ===============================================================

class StarryBookBackground extends StatefulWidget {
  final Widget? child;

  const StarryBookBackground({super.key, this.child});

  @override
  State<StarryBookBackground> createState() => _StarryBookBackgroundState();
}

class _StarryBookBackgroundState extends State<StarryBookBackground>
    with TickerProviderStateMixin {
  // Drives the whole "moon brightens → sky darkens → stars appear"
  // sequence. 0.0 = dusky start, 1.0 = fully settled midnight sky.
  late final AnimationController _revealController;

  // Gentle continuous twinkle for stars, independent of reveal.
  late final AnimationController _twinkleController;

  late final List<_NightStar> _stars;

  // Aurora ribbons — a fresh burst is created each time the user
  // taps the sky (after the moon has been revealed). Multiple taps
  // can overlap; each fades on its own timeline.
  final List<_AuroraBurst> _auroraBursts = [];
  late final Ticker _auroraTicker;

  Size _lastSize = Size.zero;

  // Relative moon position/size (fraction of the canvas).
  static const Alignment _moonAlignment = Alignment(0.62, -0.68);
  static const double _moonRadiusFactor = 0.075;

  @override
  void initState() {
    super.initState();

    _stars = _generateStars();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _auroraTicker = createTicker((_) {
      if (_auroraBursts.isEmpty) return;
      final now = DateTime.now();
      _auroraBursts.removeWhere(
        (b) => now.difference(b.startedAt) > b.lifetime,
      );
      setState(() {});
    });
    _auroraTicker.start();
  }

  List<_NightStar> _generateStars() {
    final random = math.Random(7);
    return List.generate(140, (_) {
      final bright = random.nextDouble() < 0.12;
      return _NightStar(
        dx: random.nextDouble(),
        dy: random.nextDouble() * 0.85, // keep clear of the horizon
        size: bright ? 1.2 + random.nextDouble() * 1.3 : 0.5 + random.nextDouble() * 0.7,
        baseOpacity: bright ? 0.75 + random.nextDouble() * 0.25 : 0.3 + random.nextDouble() * 0.4,
        twinkleSpeed: 0.4 + random.nextDouble() * 1.1,
        twinkleOffset: random.nextDouble() * math.pi * 2,
        // Stars don't all appear at once — stagger their entrance
        // across the last portion of the reveal animation.
        appearAt: 0.45 + random.nextDouble() * 0.5,
      );
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _twinkleController.dispose();
    _auroraTicker.dispose();
    super.dispose();
  }

  // ===============================================================
  // TAP HANDLING
  // ===============================================================

  Offset _moonCenter(Size size) {
    return Offset(
      size.width * (0.5 + _moonAlignment.x * 0.5),
      size.height * (0.5 + _moonAlignment.y * 0.5),
    );
  }

  double _moonRadius(Size size) => size.shortestSide * _moonRadiusFactor;

  void _handleTap(TapUpDetails details, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final tapPos = details.localPosition;
    final moonCenter = _moonCenter(size);
    final moonRadius = _moonRadius(size);

    // Generous hit area — a little larger than the visual moon so
    // it's easy to tap accurately.
    final hitRadius = moonRadius * 1.9;
    final hitMoon = (tapPos - moonCenter).distance <= hitRadius;

    if (hitMoon) {
      if (_revealController.value < 1.0 && !_revealController.isAnimating) {
        _revealController.forward();
      }
      return;
    }

    // Sky tap only triggers ribbons once night has settled.
    if (_revealController.value >= 0.999) {
      setState(() {
        _auroraBursts.add(
          _AuroraBurst(
            startedAt: DateTime.now(),
            lifetime: const Duration(milliseconds: 7200),
            seed: math.Random().nextInt(1 << 30),
          ),
        );
        if (_auroraBursts.length > 3) {
          _auroraBursts.removeAt(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _lastSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (details) => _handleTap(details, _lastSize),
          child: AnimatedBuilder(
            animation: Listenable.merge([_revealController, _twinkleController]),
            builder: (context, child) {
              return CustomPaint(
                painter: _MoonlitSkyPainter(
                  reveal: _revealController.value,
                  twinkle: _twinkleController.value,
                  stars: _stars,
                  auroraBursts: List.unmodifiable(_auroraBursts),
                  moonAlignment: _moonAlignment,
                  moonRadiusFactor: _moonRadiusFactor,
                ),
                child: child,
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// ===============================================================
/// MODELS
/// ===============================================================

class _NightStar {
  final double dx; // 0..1 relative
  final double dy; // 0..1 relative
  final double size;
  final double baseOpacity;
  final double twinkleSpeed;
  final double twinkleOffset;
  final double appearAt; // reveal progress at which this star fades in

  const _NightStar({
    required this.dx,
    required this.dy,
    required this.size,
    required this.baseOpacity,
    required this.twinkleSpeed,
    required this.twinkleOffset,
    required this.appearAt,
  });
}

class _AuroraBurst {
  final DateTime startedAt;
  final Duration lifetime;
  final int seed;

  const _AuroraBurst({
    required this.startedAt,
    required this.lifetime,
    required this.seed,
  });

  double progressAt(DateTime now) {
    final elapsed = now.difference(startedAt).inMilliseconds;
    return (elapsed / lifetime.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Smooth fade envelope: gentle rise, long hold, slow fade out.
  double fadeAt(DateTime now) {
    final t = progressAt(now);
    if (t < 0.18) {
      return Curves.easeOut.transform(t / 0.18);
    } else if (t > 0.55) {
      return 1.0 - Curves.easeIn.transform((t - 0.55) / 0.45);
    }
    return 1.0;
  }
}

/// ===============================================================
/// PAINTER
/// ===============================================================

class _MoonlitSkyPainter extends CustomPainter {
  final double reveal; // 0..1
  final double twinkle; // 0..1 looping
  final List<_NightStar> stars;
  final List<_AuroraBurst> auroraBursts;
  final Alignment moonAlignment;
  final double moonRadiusFactor;

  const _MoonlitSkyPainter({
    required this.reveal,
    required this.twinkle,
    required this.stars,
    required this.auroraBursts,
    required this.moonAlignment,
    required this.moonRadiusFactor,
  });

  // Dusky start colors → midnight blue end colors.
  static const _duskTop = Color(0xFF6E5A4E);
  static const _duskMid = Color(0xFF4A4038);
  static const _duskBottom = Color(0xFF3A342E);

  static const _midnightTop = Color(0xFF0B1330);
  static const _midnightMid = Color(0xFF121D42);
  static const _midnightBottom = Color(0xFF0A1226);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final easedReveal = Curves.easeInOut.transform(reveal);

    _drawSky(canvas, size, easedReveal);
    _drawMoonGlow(canvas, size, easedReveal);
    _drawStars(canvas, size, easedReveal);
    _drawMoon(canvas, size, easedReveal);
    _drawAuroraBursts(canvas, size);
  }

  // =============================================================
  // SKY GRADIENT — dusk → midnight blue
  // =============================================================

  void _drawSky(Canvas canvas, Size size, double t) {
    final rect = Offset.zero & size;

    final top = Color.lerp(_duskTop, _midnightTop, t)!;
    final mid = Color.lerp(_duskMid, _midnightMid, t)!;
    final bottom = Color.lerp(_duskBottom, _midnightBottom, t)!;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, mid, bottom],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  // =============================================================
  // EXPANDING MOONLIGHT GLOW
  // =============================================================

  void _drawMoonGlow(Canvas canvas, Size size, double t) {
    if (t <= 0.0) return;

    final center = Offset(
      size.width * (0.5 + moonAlignment.x * 0.5),
      size.height * (0.5 + moonAlignment.y * 0.5),
    );

    // Glow radius expands from 0 to roughly half the screen's
    // longer side as the reveal progresses.
    final maxGlowRadius = size.longestSide * 0.62;
    final glowRadius = maxGlowRadius * Curves.easeOut.transform(t);

    final glowOpacity = 0.14 * t;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE9E4CF).withOpacity(glowOpacity),
          const Color(0xFFC9CFE0).withOpacity(glowOpacity * 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));

    canvas.drawCircle(center, glowRadius, paint);
  }

  // =============================================================
  // THE MOON
  // =============================================================

  void _drawMoon(Canvas canvas, Size size, double t) {
    final center = Offset(
      size.width * (0.5 + moonAlignment.x * 0.5),
      size.height * (0.5 + moonAlignment.y * 0.5),
    );

    final radius = size.shortestSide * moonRadiusFactor;

    // Dim, dull disc at rest → soft luminous cream when revealed.
    final moonColor = Color.lerp(
      const Color(0xFF8B8577),
      const Color(0xFFF6EFD9),
      t,
    )!;

    // Soft halo directly around the disc, separate from the wide
    // ambient glow above.
    final haloPaint = Paint()
      ..color = const Color(0xFFF8F1DC).withOpacity(0.25 * t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center, radius * 1.6, haloPaint);

    final moonPaint = Paint()..color = moonColor;
    canvas.drawCircle(center, radius, moonPaint);

    // A few faint craters for texture, only visible once brightened.
    if (t > 0.4) {
      final craterOpacity = (t - 0.4) / 0.6;
      final craterPaint = Paint()
        ..color = const Color(0xFFD8CFA9).withOpacity(0.30 * craterOpacity);

      canvas.drawCircle(
        center + Offset(-radius * 0.30, -radius * 0.20),
        radius * 0.18,
        craterPaint,
      );
      canvas.drawCircle(
        center + Offset(radius * 0.25, radius * 0.15),
        radius * 0.12,
        craterPaint,
      );
      canvas.drawCircle(
        center + Offset(radius * 0.05, -radius * 0.35),
        radius * 0.09,
        craterPaint,
      );
    }
  }

  // =============================================================
  // STARS — stagger in as the sky darkens
  // =============================================================

  void _drawStars(Canvas canvas, Size size, double t) {
    if (t <= 0.0) return;

    for (final star in stars) {
      if (t < star.appearAt) continue;

      // Fade this particular star in over a short window once its
      // appearAt threshold is crossed.
      final localT = ((t - star.appearAt) / 0.18).clamp(0.0, 1.0);
      final entrance = Curves.easeOut.transform(localT);

      final twinkleWave = math.sin(
        twinkle * math.pi * 2 * star.twinkleSpeed + star.twinkleOffset,
      );

      final opacity =
          (star.baseOpacity * entrance + twinkleWave * 0.08).clamp(0.0, 1.0);

      final pos = Offset(star.dx * size.width, star.dy * size.height);

      final paint = Paint()..color = const Color(0xFFF3EFE0).withOpacity(opacity);

      canvas.drawCircle(pos, star.size, paint);
    }
  }

  // =============================================================
  // AURORA RIBBONS — soft, painterly, muted
  // =============================================================

  void _drawAuroraBursts(Canvas canvas, Size size) {
    if (auroraBursts.isEmpty) return;

    final now = DateTime.now();

    for (final burst in auroraBursts) {
      final fade = burst.fadeAt(now);
      if (fade <= 0.0) continue;

      final elapsedSeconds =
          now.difference(burst.startedAt).inMilliseconds / 1000.0;

      _drawRibbonSet(canvas, size, burst.seed, elapsedSeconds, fade);
    }
  }

  void _drawRibbonSet(
    Canvas canvas,
    Size size,
    int seed,
    double elapsedSeconds,
    double fade,
  ) {
    final random = math.Random(seed);

    const bandColors = [
      Color(0xFF4E7C63), // muted green
      Color(0xFFC9A66C), // muted gold
      Color(0xFF5A7FA6), // muted blue
    ];

    // A handful of overlapping wavy ribbons, each with its own
    // vertical band, phase, and drift speed for an organic feel.
    const ribbonCount = 5;

    for (int i = 0; i < ribbonCount; i++) {
      final color = bandColors[i % bandColors.length];

      final bandCenterY =
          size.height * (0.12 + 0.6 * (i / (ribbonCount - 1))) +
              math.sin(seed + i) * 20;

      final amplitude = size.height * (0.05 + random.nextDouble() * 0.04);
      final wavelength = size.width * (0.55 + random.nextDouble() * 0.35);
      final driftSpeed = 12.0 + random.nextDouble() * 10.0;
      final phase = random.nextDouble() * math.pi * 2;

      final path = Path();
      const steps = 28;

      for (int s = 0; s <= steps; s++) {
        final xT = s / steps;
        final x = xT * size.width;

        final wave = math.sin(
          (x / wavelength) * math.pi * 2 +
              elapsedSeconds * (driftSpeed / 100.0) +
              phase,
        );

        final y = bandCenterY + wave * amplitude;

        if (s == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final ribbonOpacity = 0.10 * fade;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.height * 0.09
        ..strokeCap = StrokeCap.round
        ..color = color.withOpacity(ribbonOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);

      canvas.drawPath(path, paint);

      // A slightly brighter, thinner core line for gentle definition.
      final corePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.height * 0.02
        ..strokeCap = StrokeCap.round
        ..color = color.withOpacity(ribbonOpacity * 1.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawPath(path, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MoonlitSkyPainter oldDelegate) {
    return oldDelegate.reveal != reveal ||
        oldDelegate.twinkle != twinkle ||
        oldDelegate.auroraBursts.length != auroraBursts.length ||
        auroraBursts.isNotEmpty; // keep repainting while ribbons animate
  }
}