import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class StarryBookBackground extends StatefulWidget {
  final Widget? child;

  const StarryBookBackground({
    super.key,
    this.child,
  });

  @override
  State<StarryBookBackground> createState() =>
      _StarryBookBackgroundState();
}

class _StarryBookBackgroundState extends State<StarryBookBackground>
    with TickerProviderStateMixin {
  late final List<_NightStar> _stars;
  late final Ticker _ticker;

  final List<_AuroraBurst> _auroraBursts = [];

  final math.Random _random = math.Random();

  Size _lastSize = Size.zero;

  // Moon position
  static const Alignment _moonAlignment = Alignment(0.67, -0.78);
  static const double _moonRadiusFactor = 0.075;

  // Moon glow animation
  _MoonGlow? _moonGlow;

  // Shooting star animation
  _ShootingStar? _shootingStar;

  double _shootingStarTimer = 0.0;
  double _nextShootingStarIn = 20.0;

  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    _stars = _generateStars();

    // First shooting star appears after a random delay.
   _nextShootingStarIn = 2.0 + _random.nextDouble() * 3.0;

    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  // ================================================================
  // STATIC STARS
  // ================================================================

  List<_NightStar> _generateStars() {
    final rng = math.Random(42);

    return List.generate(110, (_) {
      return _NightStar(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 0.80,
        size: 0.8 + rng.nextDouble() * 1.0,
        opacity: 0.30 + rng.nextDouble() * 0.45,
      );
    });
  }

  // ================================================================
  // ANIMATION TICKER
  // ================================================================

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds /
            Duration.microsecondsPerSecond;

    _lastElapsed = elapsed;

    if (dt <= 0) return;

    final now = DateTime.now();

    bool needsRepaint = false;

    // ------------------------------------------------
    // Update aurora bursts
    // ------------------------------------------------

    if (_auroraBursts.isNotEmpty) {
      _auroraBursts.removeWhere(
        (burst) =>
            now.difference(burst.startedAt) > burst.lifetime,
      );

      if (_auroraBursts.isNotEmpty) {
        needsRepaint = true;
      }
    }

    // ------------------------------------------------
    // Update moon glow
    // ------------------------------------------------

    if (_moonGlow != null) {
      final progress = _moonGlow!.progress(now);

      if (progress >= 1.0) {
        _moonGlow = null;
      }

      needsRepaint = true;
    }

    // ------------------------------------------------
    // Update shooting star
    // ------------------------------------------------

    if (_shootingStar != null) {
      final progress = _shootingStar!.progress(now);

      if (progress >= 1.0) {
        _shootingStar = null;

        // Schedule the next shooting star.
        _shootingStarTimer = 0.0;
        _nextShootingStarIn = _randomShootingStarInterval();
      }

      needsRepaint = true;
    } else {
      _shootingStarTimer += dt;

      if (_shootingStarTimer >= _nextShootingStarIn) {
        _spawnShootingStar(now);
        needsRepaint = true;
      }
    }

    if (needsRepaint && mounted) {
      setState(() {});
    }
  }

  double _randomShootingStarInterval() {
  // Shooting stars appear every 3–4 seconds.
  return 3.0 + _random.nextDouble() * 1.0;
}

  // ================================================================
  // SHOOTING STAR
  // ================================================================

  void _spawnShootingStar(DateTime now) {
    _shootingStar = _ShootingStar(
      startedAt: now,

      // Random starting position in the sky.
      startX: 0.08 + _random.nextDouble() * 0.62,
      startY: 0.05 + _random.nextDouble() * 0.45,

      // Diagonal travel distance.
      travelX: 0.22 + _random.nextDouble() * 0.18,
      travelY: 0.12 + _random.nextDouble() * 0.12,

      // Slight variation in speed.
      duration: Duration(
        milliseconds: 700 + _random.nextInt(500),
      ),
    );
  }

  // ================================================================
  // TAP INTERACTIONS
  // ================================================================

  void _handleTap(TapUpDetails details, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final tapPos = details.localPosition;

    // ------------------------------------------------
    // 1. Moon tap → Moon glow
    // ------------------------------------------------

    final moonCenter = Offset(
      size.width * (0.5 + _moonAlignment.x * 0.5),
      size.height * (0.5 + _moonAlignment.y * 0.5),
    );

    final moonRadius = size.shortestSide * _moonRadiusFactor;

    // Slightly generous hit area for comfortable tapping.
    if ((tapPos - moonCenter).distance <= moonRadius * 1.8) {
      setState(() {
        _moonGlow = _MoonGlow(
          startedAt: DateTime.now(),
          duration: const Duration(milliseconds: 2200),
        );
      });

      return;
    }

    // ------------------------------------------------
    // 2. Other sky tap → Aurora
    // ------------------------------------------------

    setState(() {
      _auroraBursts.add(
        _AuroraBurst(
          startedAt: DateTime.now(),
          lifetime: const Duration(milliseconds: 7200),
          seed: math.Random().nextInt(1 << 30),
        ),
      );

      // Prevent too many overlapping aurora effects.
      if (_auroraBursts.length > 3) {
        _auroraBursts.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _lastSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (details) => _handleTap(details, _lastSize),

          child: CustomPaint(
            painter: _SkyPainter(
              stars: _stars,
              auroraBursts: List.unmodifiable(_auroraBursts),
              moonAlignment: _moonAlignment,
              moonRadiusFactor: _moonRadiusFactor,
              moonGlow: _moonGlow,
              shootingStar: _shootingStar,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ================================================================
// STATIC STAR MODEL
// ================================================================

class _NightStar {
  final double x;
  final double y;
  final double size;
  final double opacity;

  const _NightStar({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });
}

// ================================================================
// MOON GLOW MODEL
// ================================================================

class _MoonGlow {
  final DateTime startedAt;
  final Duration duration;

  const _MoonGlow({
    required this.startedAt,
    required this.duration,
  });

  double progress(DateTime now) {
    return (now.difference(startedAt).inMilliseconds /
            duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }
}

// ================================================================
// SHOOTING STAR MODEL
// ================================================================

class _ShootingStar {
  final DateTime startedAt;
  final Duration duration;

  final double startX;
  final double startY;

  final double travelX;
  final double travelY;

  const _ShootingStar({
    required this.startedAt,
    required this.duration,
    required this.startX,
    required this.startY,
    required this.travelX,
    required this.travelY,
  });

  double progress(DateTime now) {
    return (now.difference(startedAt).inMilliseconds /
            duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }
}

// ================================================================
// AURORA MODEL
// ================================================================

class _AuroraBurst {
  final DateTime startedAt;
  final Duration lifetime;
  final int seed;

  const _AuroraBurst({
    required this.startedAt,
    required this.lifetime,
    required this.seed,
  });

  double fadeAt(DateTime now) {
    final t = (now.difference(startedAt).inMilliseconds /
            lifetime.inMilliseconds)
        .clamp(0.0, 1.0);

    if (t < 0.18) {
      return Curves.easeOut.transform(t / 0.18);
    }

    if (t > 0.55) {
      return 1.0 -
          Curves.easeIn.transform((t - 0.55) / 0.45);
    }

    return 1.0;
  }
}

// ================================================================
// SKY PAINTER
// ================================================================

class _SkyPainter extends CustomPainter {
  final List<_NightStar> stars;
  final List<_AuroraBurst> auroraBursts;

  final Alignment moonAlignment;
  final double moonRadiusFactor;

  final _MoonGlow? moonGlow;
  final _ShootingStar? shootingStar;

  const _SkyPainter({
    required this.stars,
    required this.auroraBursts,
    required this.moonAlignment,
    required this.moonRadiusFactor,
    required this.moonGlow,
    required this.shootingStar,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    _drawSky(canvas, size);

    // Static background stars.
    _drawStars(canvas, size);

    // Moon glow interaction.
    _drawMoonGlow(canvas, size);

    // Shooting star.
    _drawShootingStar(canvas, size);

    // Moon on top of its glow.
    _drawMoon(canvas, size);

    // Existing aurora effect.
    _drawAuroraBursts(canvas, size);
  }

  // ================================================================
  // SKY BACKGROUND
  // ================================================================

  void _drawSky(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B1330),
            Color(0xFF121D42),
            Color(0xFF0A1226),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  // ================================================================
  // STATIC STARS
  // ================================================================

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint();

    for (final star in stars) {
      // Fixed positions and fixed opacity.
      canvas.drawCircle(
        Offset(
          star.x * size.width,
          star.y * size.height,
        ),
        star.size,
        paint..color = const Color(0xFFF0EDE0)
            .withOpacity(star.opacity),
      );
    }
  }

  // ================================================================
  // MOON GLOW
  // ================================================================

  void _drawMoonGlow(Canvas canvas, Size size) {
    final center = Offset(
      size.width * (0.5 + moonAlignment.x * 0.5),
      size.height * (0.5 + moonAlignment.y * 0.5),
    );

    final baseRadius = size.shortestSide * moonRadiusFactor;

    // Original ambient moonlight — remains subtle.
    final ambientRadius = size.longestSide * 0.62;

    canvas.drawCircle(
      center,
      ambientRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE9E4CF).withOpacity(0.14),
            const Color(0xFFC9CFE0).withOpacity(0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: ambientRadius,
          ),
        ),
    );

    // Interactive glow when moon is tapped.
    if (moonGlow == null) return;

    final now = DateTime.now();
    final t = moonGlow!.progress(now);

    // Smooth expansion and fade.
    final eased = Curves.easeOutCubic.transform(t);
    final fade = (1.0 - Curves.easeIn.transform(t))
        .clamp(0.0, 1.0);

    final glowRadius = baseRadius * (1.5 + eased * 5.0);

    // Expanding diffused halo.
    canvas.drawCircle(
      center,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF5D6).withOpacity(0.32 * fade),
            const Color(0xFFFFF1C2).withOpacity(0.15 * fade),
            const Color(0xFFDDE5FF).withOpacity(0.04 * fade),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.70, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: glowRadius,
          ),
        ),
    );

    // Soft light surrounding the moon.
    canvas.drawCircle(
      center,
      baseRadius * (1.5 + eased * 1.4),
      Paint()
        ..color = const Color(0xFFFFF4D5)
            .withOpacity(0.22 * fade)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          22,
        ),
    );
  }

  // ================================================================
  // MOON
  // ================================================================

  void _drawMoon(Canvas canvas, Size size) {
    final center = Offset(
      size.width * (0.5 + moonAlignment.x * 0.5),
      size.height * (0.5 + moonAlignment.y * 0.5),
    );

    final r = size.shortestSide * moonRadiusFactor;

    // Original soft moon halo.
    canvas.drawCircle(
      center,
      r * 1.6,
      Paint()
        ..color = const Color(0xFFF8F1DC).withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          14,
        ),
    );

    // Moon body.
    canvas.drawCircle(
      center,
      r,
      Paint()..color = const Color(0xFFF6EFD9),
    );

    // Moon surface details.
    final craterPaint = Paint()
      ..color = const Color(0xFFD8CFA9).withOpacity(0.30);

    canvas.drawCircle(
      center + Offset(-r * 0.30, -r * 0.20),
      r * 0.18,
      craterPaint,
    );

    canvas.drawCircle(
      center + Offset(r * 0.25, r * 0.15),
      r * 0.12,
      craterPaint,
    );

    canvas.drawCircle(
      center + Offset(r * 0.05, -r * 0.35),
      r * 0.09,
      craterPaint,
    );
  }

  // ================================================================
  // SHOOTING STAR
  // ================================================================

  void _drawShootingStar(Canvas canvas, Size size) {
    if (shootingStar == null) return;

    final now = DateTime.now();
    final star = shootingStar!;

    final rawT = star.progress(now);

    // Ease movement in and out.
    final t = Curves.easeOut.transform(rawT);

    // Fade in quickly, then fade out.
    final fadeIn = (rawT / 0.12).clamp(0.0, 1.0);
    final fadeOut = ((1.0 - rawT) / 0.35).clamp(0.0, 1.0);

    final opacity = fadeIn * fadeOut;

    if (opacity <= 0) return;

    final start = Offset(
      star.startX * size.width,
      star.startY * size.height,
    );

    final end = Offset(
      (star.startX + star.travelX) * size.width,
      (star.startY + star.travelY) * size.height,
    );

    final head = Offset.lerp(start, end, t)!;

    // Trail points backward from the moving star.
    final trailLength = size.shortestSide * 0.13;

    final direction = Offset(
      star.travelX * size.width,
      star.travelY * size.height,
    );

    final directionLength = direction.distance;

    if (directionLength == 0) return;

    final unitDirection = direction / directionLength;

    final tail = head - unitDirection * trailLength;

    // Blurred outer trail.
    canvas.drawLine(
      tail,
      head,
      Paint()
        ..color = const Color(0xFFFFE8AE).withOpacity(0.25 * opacity)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          5,
        ),
    );

    // Bright golden-white trail.
    canvas.drawLine(
      tail,
      head,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFFFE6A3).withOpacity(0.85 * opacity),
            Colors.white.withOpacity(opacity),
          ],
        ).createShader(
          Rect.fromPoints(tail, head),
        )
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // Bright moving head.
    canvas.drawCircle(
      head,
      2.0,
      Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          3,
        ),
    );
  }

  // ================================================================
  // AURORA BURSTS
  // ================================================================

  void _drawAuroraBursts(Canvas canvas, Size size) {
    if (auroraBursts.isEmpty) return;

    final now = DateTime.now();

    for (final burst in auroraBursts) {
      final fade = burst.fadeAt(now);

      if (fade <= 0.0) continue;

      final elapsed =
          now.difference(burst.startedAt).inMilliseconds / 1000.0;

      _drawRibbonSet(
        canvas,
        size,
        burst.seed,
        elapsed,
        fade,
      );
    }
  }

  void _drawRibbonSet(
    Canvas canvas,
    Size size,
    int seed,
    double elapsed,
    double fade,
  ) {
    final rng = math.Random(seed);

    const bandColors = [
      Color(0xFF4E7C63),
      Color(0xFFC9A66C),
      Color(0xFF5A7FA6),
    ];

    const ribbonCount = 5;

    for (int i = 0; i < ribbonCount; i++) {
      final color = bandColors[i % bandColors.length];

      final bandCenterY =
          size.height * (0.12 + 0.6 * (i / (ribbonCount - 1))) +
              math.sin(seed + i) * 20;

      final amplitude =
          size.height * (0.05 + rng.nextDouble() * 0.04);

      final wavelength =
          size.width * (0.55 + rng.nextDouble() * 0.35);

      final driftSpeed = 12.0 + rng.nextDouble() * 10.0;

      final phase = rng.nextDouble() * math.pi * 2;

      final path = Path();

      const steps = 28;

      for (int s = 0; s <= steps; s++) {
        final x = (s / steps) * size.width;

        final y = bandCenterY +
            math.sin(
              (x / wavelength) * math.pi * 2 +
                  elapsed * (driftSpeed / 100.0) +
                  phase,
            ) *
                amplitude;

        if (s == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final op = 0.10 * fade;

      // Wide, soft aurora ribbon.
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.height * 0.09
          ..strokeCap = StrokeCap.round
          ..color = color.withOpacity(op)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            26,
          ),
      );

      // Inner aurora highlight.
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.height * 0.02
          ..strokeCap = StrokeCap.round
          ..color = color.withOpacity(op * 1.6)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            10,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) {
    return true;
  }
}