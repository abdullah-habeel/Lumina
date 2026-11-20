import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/music/controller/sound_effects_controller.dart';

/// ===============================================================
/// DAYLIGHT BOOK BACKGROUND
///
/// Features:
/// • Full-day color cycle (6 AM → 7 PM) built from distinct
///   keyframe stages: sunrise, morning, noon, afternoon,
///   late afternoon, sunset — each with its own sky + sun colors
/// • Smooth interpolation between whichever two stages the
///   current hour falls between
/// • Sun moves along a shallow arc near the top of the screen
/// • Clouds drift ABOVE the sun (in front), partially crossing it
/// • Gently falling leaf particles
/// • Continuous time-based animation — no reset/jump on loop
/// • Debug override hour for easy testing
/// • No assets required
/// ===============================================================

class DaylightBookBackground extends StatefulWidget {
  final Widget? child;

  /// TESTING ONLY. Set a decimal hour (e.g. 6.0, 12.0, 18.5) to
  /// force that time of day instead of using the real device clock.
  /// Set to null for normal (real time) behavior.
  ///
  /// Try: 6.0 (sunrise), 9.0 (morning), 12.0 (noon),
  /// 15.0 (afternoon), 17.5 (late afternoon), 19.0 (sunset)
  final double? debugOverrideHour;

  const DaylightBookBackground({super.key, this.child, this.debugOverrideHour});

  @override
  State<DaylightBookBackground> createState() => _DaylightBookBackgroundState();
}

class _DaylightBookBackgroundState extends State<DaylightBookBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  double _elapsed = 0.0;
  double? _rainStart;

  void _onRain() {
    if (_rainStart != null && _elapsed - _rainStart! < 4.0) return;
    _rainStart = _elapsed;

    if (Get.isRegistered<SoundEffectsController>()) {
      Get.find<SoundEffectsController>().playStorm(
        strikeTimes: CloudRain.strikeTimes,
        totalSeconds: 4.0,
      );
    }
  }

  late final List<_DriftCloud> _clouds;
  // late final List<_FallingLeaf> _leaves;
  late final List<_Bird> _birds;

  @override
  void initState() {
    super.initState();
    CloudRain.trigger.addListener(_onRain);

    _clouds = _generateClouds();
    // _leaves = _generateLeaves();
    _birds = _generateBirds();

    _ticker = createTicker((elapsed) {
      setState(() {
        _elapsed = elapsed.inMilliseconds / 1000.0;
      });
    })..start();
  }

  List<_Bird> _generateBirds() {
    final random = math.Random(42);

    return List.generate(4, (i) {
      return _Bird(
        startX: random.nextDouble(),
        y: 0.08 + random.nextDouble() * 0.20,
        scale: 0.7 + random.nextDouble() * 0.7,
        speedPxPerSec: 22.0 + random.nextDouble() * 18.0,
        flapSpeed: 5.0 + random.nextDouble() * 3.0,
        flapOffset: random.nextDouble() * math.pi * 2,
        glidePhase: random.nextDouble() * math.pi * 2,
        bobAmount: 4.0 + random.nextDouble() * 6.0,
        bobOffset: random.nextDouble() * math.pi * 2,
      );
    });
  }

  List<_DriftCloud> _generateClouds() {
    final random = math.Random(7);

    return List.generate(3, (index) {
      final bool background = index == 0;

      return _DriftCloud(
        startX: random.nextDouble() * 1.4 - 0.2,
        y: index == 0
            ? 0.02 + random.nextDouble() * 0.04
            : 0.06 + random.nextDouble() * 0.08,
        scale: background
            ? 0.55 + random.nextDouble() * 0.30
            : 0.85 + random.nextDouble() * 0.45,
        speedPxPerSec: background
            ? 6.0 + random.nextDouble() * 3.0
            : 10.0 + random.nextDouble() * 4.0,
        opacity: background
            ? 0.40 + random.nextDouble() * 0.15
            : 0.60 + random.nextDouble() * 0.20,
        bobOffset: random.nextDouble() * math.pi * 2,
      );
    });
  }

  // List<_FallingLeaf> _generateLeaves() {
  //   final random = math.Random(21);

  //   return List.generate(10, (_) {
  //     return _FallingLeaf(
  //       startX: random.nextDouble(),
  //       startDelay: random.nextDouble() * 10,
  //       fallSpeedPxPerSec: 14.0 + random.nextDouble() * 10.0,
  //       size: 5.0 + random.nextDouble() * 6.0,
  //       swayAmount: 10.0 + random.nextDouble() * 18.0,
  //       swaySpeed: 0.6 + random.nextDouble() * 1.0,
  //       swayOffset: random.nextDouble() * math.pi * 2,
  //       opacity: 0.35 + random.nextDouble() * 0.45,
  //       color: random.nextBool()
  //           ? const Color(0xFF8A9B5E)
  //           : const Color(0xFFB9A25A),
  //     );
  //   });
  // }

  @override
  void dispose() {
    CloudRain.trigger.removeListener(_onRain);
    if (Get.isRegistered<SoundEffectsController>()) {
      Get.find<SoundEffectsController>().stopStorm();
    }
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double currentHour;

    final override = widget.debugOverrideHour ?? DaylightDebug.hour;
    if (override != null) {
      currentHour = override;
    } else {
      final now = DateTime.now();
      currentHour = now.hour + now.minute / 60.0;
    }

    // Clamp into the defined day window (6 AM – 7 PM).
    final clampedHour = currentHour.clamp(
      DayStages.stages.first.hour,
      DayStages.stages.last.hour,
    );

    // dayProgress (0→1) is still used for the sun's ARC POSITION
    // (shallow rise-and-fall path), separate from its COLOR
    // (which now comes from the keyframe stages below).
    final dayProgress =
        (clampedHour - DayStages.stages.first.hour) /
        (DayStages.stages.last.hour - DayStages.stages.first.hour);

    final rainT = _rainStart == null ? null : _elapsed - _rainStart!;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (d) {
        if (CloudRain.hit(d.localPosition)) CloudRain.start();
      },
      child: CustomPaint(
        painter: _DaylightSkyPainter(
          elapsed: _elapsed,
          currentHour: clampedHour,
          dayProgress: dayProgress.clamp(0.0, 1.0),
          clouds: _clouds,
          birds: _birds,
          rainT: (rainT != null && rainT < 4.0) ? rainT : null,
        ),
        child: DaylightTime(
          hour: clampedHour,
          child: widget.child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// ===============================================================
/// SKY STAGE — one color "keyframe" pinned to a specific hour.
/// The painter finds the two stages surrounding the current hour
/// and blends smoothly between them.
/// ===============================================================

class SkyStage {
  final double hour;
  final Color skyTop;
  final Color skyMid;
  final Color skyBottom;
  final Color hazeColor;
  final Color sunCore;
  final Color sunHalo;
  final Color sunRim;

  const SkyStage({
    required this.hour,
    required this.skyTop,
    required this.skyMid,
    required this.skyBottom,
    required this.hazeColor,
    required this.sunCore,
    required this.sunHalo,
    required this.sunRim,
  });
}

class DayStages {
  // ---------------------------------------------------------------
  // Six keyframes across the day. Add more stages here any time
  // you want finer control over a particular part of the day.
  // ---------------------------------------------------------------
  static final List<SkyStage> stages = [
    // 6:00 AM — SUNRISE: soft pink-orange, hazy and gentle.
    const SkyStage(
      hour: 6.0,
      skyTop: Color(0xFF4A5568), // deep muted blue-gray, not bright
      skyMid: Color(0xFF7C818A), // transitional cool gray
      skyBottom: Color(0xFFB8A98F), // faint warm horizon, muted not orange
      hazeColor: Color(0xFFC9A57E), // soft, low-intensity warmth
      sunCore: Color(0xFFE8C79A), // dim, not fully bright yet
      sunHalo: Color(0xFFD9A876),
      sunRim: Color(0xFFB98559),
    ),

    // 9:00 AM — MORNING: brightening, cool blue with warm undertone.
    const SkyStage(
      hour: 9.0,
      skyTop: Color(0xFFAFCBD8),
      skyMid: Color(0xFFDFE0C6),
      skyBottom: Color(0xFFF1EAD3),
      hazeColor: Color(0xFFFFEFC2),
      sunCore: Color(0xFFFFF6DA),
      sunHalo: Color(0xFFFFECAF),
      sunRim: Color(0xFFFFD98A),
    ),

    // 12:00 PM — NOON: brightest, coolest, most neutral light.
    const SkyStage(
      hour: 12.0,
      skyTop: Color(0xFFCBD6D8),
      skyMid: Color(0xFFE7E4CF),
      skyBottom: Color(0xFFF5EFDD),
      hazeColor: Color(0xFFFFF6DC),
      sunCore: Color(0xFFFFFEF6),
      sunHalo: Color(0xFFFFF6D0),
      sunRim: Color(0xFFFFECA8),
    ),

    // 3:00 PM — AFTERNOON: still bright, slightly warming.
    const SkyStage(
      hour: 15.0,
      skyTop: Color(0xFFC9D2C8),
      skyMid: Color(0xFFE8DFC0),
      skyBottom: Color(0xFFF6E9CC),
      hazeColor: Color(0xFFFFEBB8),
      sunCore: Color(0xFFFFF4DA),
      sunHalo: Color(0xFFFFDF9E),
      sunRim: Color(0xFFFFC978),
    ),

    // 5:30 PM — LATE AFTERNOON: golden hour, noticeably warm.
    const SkyStage(
      hour: 17.5,
      skyTop: Color(0xFFCBAF9C),
      skyMid: Color(0xFFECB77E),
      skyBottom: Color(0xFFF8D49B),
      hazeColor: Color(0xFFFFA25E),
      sunCore: Color(0xFFFFCB80),
      sunHalo: Color(0xFFFF9F55),
      sunRim: Color(0xFFFF7A3D),
    ),

    // 7:00 PM — SUNSET: deep orange-red, dramatic and saturated.
    const SkyStage(
      hour: 19.0,
      skyTop: Color(0xFF1A1620), // near-black, deep dusky purple-black
      skyMid: Color(0xFF4A2A2E), // dark muted red-brown
      skyBottom: Color(0xFF8C4A3E), // dim red-orange glow at horizon only
      hazeColor: Color(0xFF9C3A2A), // deep red haze, not bright orange
      sunCore: Color(0xFFB8503A), // dim red sun, losing brightness
      sunHalo: Color(0xFF8C3226),
      sunRim: Color(0xFF5C1E18), // near-black-red rim
    ),
  ];

  /// Given the current hour, finds the two surrounding stages and
  /// returns a blended _SkyStage between them.
  static SkyStage resolve(double hour) {
    // Before the first stage or after the last — clamp to the edge.
    if (hour <= stages.first.hour) return stages.first;
    if (hour >= stages.last.hour) return stages.last;

    for (int i = 0; i < stages.length - 1; i++) {
      final a = stages[i];
      final b = stages[i + 1];

      if (hour >= a.hour && hour <= b.hour) {
        final t = (hour - a.hour) / (b.hour - a.hour);

        return SkyStage(
          hour: hour,
          skyTop: Color.lerp(a.skyTop, b.skyTop, t)!,
          skyMid: Color.lerp(a.skyMid, b.skyMid, t)!,
          skyBottom: Color.lerp(a.skyBottom, b.skyBottom, t)!,
          hazeColor: Color.lerp(a.hazeColor, b.hazeColor, t)!,
          sunCore: Color.lerp(a.sunCore, b.sunCore, t)!,
          sunHalo: Color.lerp(a.sunHalo, b.sunHalo, t)!,
          sunRim: Color.lerp(a.sunRim, b.sunRim, t)!,
        );
      }
    }

    return stages.last;
  }
}

/// ===============================================================
/// PAINTER
/// ===============================================================

class _DaylightSkyPainter extends CustomPainter {
  final double elapsed;
  final double currentHour;
  final double
  dayProgress; // 0.0 = day start, 1.0 = day end (for sun ARC position only)
  final List<_DriftCloud> clouds;
  // final List<_FallingLeaf> leaves;
  final List<_Bird> birds;
  final double? rainT;

  const _DaylightSkyPainter({
    this.rainT,
    required this.elapsed,
    required this.birds,
    required this.currentHour,
    required this.dayProgress,
    required this.clouds,
    // required this.leaves,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final stage = DayStages.resolve(currentHour);

    _drawBackground(canvas, size, stage);
    _drawSun(canvas, size, stage);
    _drawStormDarkness(canvas, size);
    _drawClouds(canvas, size);
    _drawBirds(canvas, size);
    _drawFlash(canvas, size);
    // _drawLeaves(canvas, size);
  }

  // =============================================================
  // BACKGROUND — colors come from the resolved keyframe stage.
  // =============================================================

  void _drawBackground(Canvas canvas, Size size, SkyStage stage) {
    final rect = Offset.zero & size;

    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [stage.skyTop, stage.skyMid, stage.skyBottom],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    final hazePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.35),
        radius: 1.1,
        colors: [
          stage.hazeColor.withOpacity(0.30),
          stage.hazeColor.withOpacity(0.0),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, hazePaint);
  }

  // =============================================================
  // SUN — position from arc (dayProgress), color from stage.
  // =============================================================

  void _drawSun(Canvas canvas, Size size, SkyStage stage) {
    // Shallow arc across the top band, matching the flat path
    // you want — left to right near the very top of the screen.
    final sunX = size.width * (0.10 + dayProgress * 0.80);

    final arcHeight = math.sin(dayProgress * math.pi);

    // Very shallow vertical range, confined to the top band —
    // never dips down toward the tree/branches.
    final sunY = 0.16 - (arcHeight * 0.05);

    final center = Offset(sunX, sunY * size.height);

    // Warmth still used for the subtle size boost near the
    // edges of the day (sun looks a touch bigger at sunrise/sunset).
    final warmth = 1.0 - arcHeight;

    final pulse = 0.97 + math.sin(elapsed * 0.6) * 0.03;

    final coreRadius = size.width * (0.09 + warmth * 0.015) * pulse;

    final outerGlowPaint = Paint()
      ..color = stage.sunHalo.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);

    canvas.drawCircle(center, coreRadius * 1.9, outerGlowPaint);

    final midGlowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              stage.sunHalo.withOpacity(0.9),
              stage.sunHalo.withOpacity(0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: coreRadius * 1.35),
          );

    canvas.drawCircle(center, coreRadius * 1.35, midGlowPaint);

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [stage.sunCore, Color.lerp(stage.sunCore, stage.sunRim, 0.5)!],
        stops: const [0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: coreRadius));

    canvas.drawCircle(center, coreRadius, corePaint);

    final rimPaint = Paint()
      ..color = stage.sunRim.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, coreRadius, rimPaint);
  }

  // =============================================================
  // CLOUDS — drift above (in front of) the sun
  // =============================================================

  void _drawClouds(Canvas canvas, Size size) {
    final rects = <Rect>[];

    for (int i = 0; i < clouds.length; i++) {
      final cloud = clouds[i];

      final travelled = elapsed * cloud.speedPxPerSec;
      final wrapWidth = size.width * 1.6;
      double x = (cloud.startX * size.width + travelled) % wrapWidth;
      x -= size.width * 0.3;

      final bob = math.sin(elapsed * 0.5 + cloud.bobOffset) * 4.0;
      final center = Offset(x, cloud.y * size.height + bob);
      final radius = size.width * 0.16 * cloud.scale;

      rects.add(
        Rect.fromCenter(
          center: center,
          width: radius * 3.4,
          height: radius * 1.6,
        ),
      );

      final t = rainT;
      if (t != null) _drawRain(canvas, size, center, radius, t);

      _drawCloudShape(canvas, center, radius, cloud.opacity);
      if (t != null) _drawLightning(canvas, size, center, radius, t, i);
    }

    CloudRain.rects = rects;
  }

  void _drawRain(
    Canvas canvas,
    Size size,
    Offset cloudCenter,
    double radius,
    double t,
  ) {
    const duration = 4.0;
    final intensity =
        (t / 0.5).clamp(0.0, 1.0) * ((duration - t) / 1.0).clamp(0.0, 1.0);
    if (intensity <= 0) return;

    final rainBase = DaylightAppColors.rainColor(currentHour);

    final startY = cloudCenter.dy + radius * 0.5;
    final fallHeight = size.height * 0.22;
    final width = radius * 2.6;

    final paint = Paint()
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 28; i++) {
      final rx = ((i * 37) % 100) / 100.0 - 0.5;
      final speed = 0.9 + ((i * 53) % 10) / 10.0 * 0.6;
      final p = (t * speed + i * 0.137) % 1.0;

      final x = cloudCenter.dx + rx * width;
      final y = startY + p * fallHeight;

      paint.color = rainBase.withOpacity((1 - p) * 0.9 * intensity);
      canvas.drawLine(Offset(x, y), Offset(x - 2, y + 12), paint);
    }
  }

  void _drawLightning(
    Canvas canvas,
    Size size,
    Offset origin,
    double radius,
    double t,
    int cloudIndex,
  ) {
    final strikes = CloudRain.strikeTimes;

    final glowColor = DaylightAppColors.lightningGlow(currentHour);
    final outlineColor = DaylightAppColors.lightningOutline(currentHour);

    for (int k = 0; k < strikes.length; k++) {
      // each strike comes from one cloud
      if (k % clouds.length != cloudIndex) continue;

      final dt = t - strikes[k];
      if (dt < 0 || dt > 0.4) continue;
      final fade = 1.0 - dt / 0.4;

      final rand = math.Random(k * 11 + 3);
      double x = origin.dx + (rand.nextDouble() - 0.5) * radius;
      double y = origin.dy + radius * 0.4;

      final path = Path()..moveTo(x, y);
      const segments = 7;
      final segH = size.height * 0.20 / segments;

      for (int s = 0; s < segments; s++) {
        x += (rand.nextDouble() - 0.5) * radius * 0.6;
        y += segH;
        path.lineTo(x, y);
      }

      // 1. soft colored glow
      final glow = Paint()
        ..color = glowColor.withOpacity(0.8 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      // 2. dark edge (strong in daylight, invisible at night)
      final outline = Paint()
        ..color = outlineColor.withOpacity(outlineColor.opacity * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeJoin = StrokeJoin.round;

      // 3. bright white core
      final core = Paint()
        ..color = Colors.white.withOpacity(fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, glow);
      canvas.drawPath(path, outline);
      canvas.drawPath(path, core);
    }
  }

  // How bright the flash is at time t (0 to 1), as a quick flicker:
  // bright, short dip, then a softer second pulse that fades.
  double _flashAt(double t) {
    double best = 0;
    for (final s in CloudRain.strikeTimes) {
      final dt = t - s;
      double v;
      if (dt < 0 || dt > 0.45) {
        v = 0;
      } else if (dt < 0.08) {
        v = 1.0;
      } else if (dt < 0.16) {
        v = 0.25;
      } else {
        v = 0.8 * (1 - (dt - 0.16) / 0.29);
      }
      best = math.max(best, v);
    }
    return best;
  }

  // The sky gets dark and gray-blue while it rains, and lifts
  // for a moment when lightning flashes.
  void _drawStormDarkness(Canvas canvas, Size size) {
    final t = rainT;
    if (t == null) return;

    const duration = 4.0;
    final envelope =
        (t / 0.6).clamp(0.0, 1.0) * ((duration - t) / 1.2).clamp(0.0, 1.0);
    if (envelope <= 0) return;

    final flash = _flashAt(t);
    final opacity = 0.38 * envelope * (1 - 0.8 * flash);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF141C2B).withOpacity(opacity),
    );
  }

  // Cool blue-white flash on top of the sky.
  void _drawFlash(Canvas canvas, Size size) {
    final t = rainT;
    if (t == null) return;

    final flash = _flashAt(t);
    if (flash <= 0) return;

    final color = Color.lerp(
      DaylightAppColors.lightningGlow(currentHour),
      const Color(0xFFE6EEFF),
      0.6,
    )!;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = color.withOpacity(0.38 * flash),
    );
  }

  void _drawCloudShape(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final puffs = [
      Offset(center.dx, center.dy),
      Offset(center.dx + radius * 0.9, center.dy + radius * 0.15),
      Offset(center.dx - radius * 0.85, center.dy + radius * 0.18),
      Offset(center.dx + radius * 0.35, center.dy - radius * 0.35),
      Offset(center.dx - radius * 0.30, center.dy - radius * 0.28),
      Offset(center.dx + radius * 1.5, center.dy + radius * 0.25),
      Offset(center.dx - radius * 1.4, center.dy + radius * 0.25),
    ];

    final sizes = [
      radius * 0.75,
      radius * 0.55,
      radius * 0.55,
      radius * 0.45,
      radius * 0.42,
      radius * 0.35,
      radius * 0.35,
    ];

    for (int i = 0; i < puffs.length; i++) {
      canvas.drawCircle(puffs[i], sizes[i], paint);
    }

    final basePaint = Paint()
      ..color = const Color(0xFFE9E4D2).withOpacity(opacity * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.35),
        width: radius * 3.2,
        height: radius * 0.9,
      ),
      basePaint,
    );
  }

  void _drawBirds(Canvas canvas, Size size) {
    // Fade out toward dusk (17.5 -> 18.5), and dim a little at sunrise.
    final dusk = ((18.5 - currentHour) / 1.0).clamp(0.0, 1.0);
    final dawn = ((currentHour - 6.0) / 1.0).clamp(0.3, 1.0);
    final visibility = dusk * dawn;
    if (visibility <= 0.01) return;

    for (final bird in birds) {
      final wrapWidth = size.width * 1.4;
      double x =
          (bird.startX * size.width + elapsed * bird.speedPxPerSec) % wrapWidth;
      x -= size.width * 0.2;

      final bob = math.sin(elapsed * 0.7 + bird.bobOffset) * bird.bobAmount;
      final center = Offset(x, bird.y * size.height + bob);

      // Glide cycle: every so often the bird stops flapping and holds its wings.
      final glide = math.sin(elapsed * 0.35 + bird.glidePhase);
      final flapAmount = glide > 0.55 ? 0.15 : 1.0;

      final flap = math.sin(elapsed * bird.flapSpeed + bird.flapOffset);
      final wingLift = flap * flapAmount;

      _drawBird(canvas, center, 9.0 * bird.scale, wingLift, visibility);
    }
  }

  void _drawBird(
    Canvas canvas,
    Offset c,
    double span,
    double wingLift,
    double visibility,
  ) {
    final color = const Color(0xFF3B3630).withOpacity(0.55 * visibility);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final tipY = c.dy - wingLift * span * 0.6;
    final ctrlY = c.dy - span * 0.55 - wingLift * span * 0.25;

    final path = Path()
      ..moveTo(c.dx - span, tipY)
      ..quadraticBezierTo(c.dx - span * 0.5, ctrlY, c.dx, c.dy)
      ..quadraticBezierTo(c.dx + span * 0.5, ctrlY, c.dx + span, tipY);

    canvas.drawPath(path, paint);
  }
  // =============================================================
  // FALLING LEAVES
  // =============================================================

  // void _drawLeaves(Canvas canvas, Size size) {
  //   for (final leaf in leaves) {
  //     final totalDistance = (elapsed * leaf.fallSpeedPxPerSec) +
  //         leaf.startDelay * leaf.fallSpeedPxPerSec;

  //     final cycleHeight = size.height + 40;
  //     final y = (totalDistance % cycleHeight) - 20;

  //     final sway =
  //         math.sin(elapsed * leaf.swaySpeed + leaf.swayOffset) * leaf.swayAmount;

  //     final x = leaf.startX * size.width + sway;

  //     final t = (totalDistance % cycleHeight) / cycleHeight;

  //     double fade;
  //     if (t < 0.08) {
  //       fade = t / 0.08;
  //     } else if (t > 0.92) {
  //       fade = (1.0 - t) / 0.08;
  //     } else {
  //       fade = 1.0;
  //     }
  //     fade = fade.clamp(0.0, 1.0);

  //     final rotation = elapsed * 1.2 + leaf.swayOffset;

  //     canvas.save();
  //     canvas.translate(x, y);
  //     canvas.rotate(rotation);

  //     final leafPaint = Paint()
  //       ..color = leaf.color.withOpacity(leaf.opacity * fade);

  //     final path = Path()
  //       ..moveTo(0, -leaf.size)
  //       ..quadraticBezierTo(leaf.size * 0.7, 0, 0, leaf.size)
  //       ..quadraticBezierTo(-leaf.size * 0.7, 0, 0, -leaf.size)
  //       ..close();

  //     canvas.drawPath(path, leafPaint);

  //     canvas.restore();
  //   }
  // }

  @override
  bool shouldRepaint(covariant _DaylightSkyPainter oldDelegate) {
    return oldDelegate.elapsed != elapsed ||
        oldDelegate.currentHour != currentHour ||
        oldDelegate.dayProgress != dayProgress ||
        oldDelegate.rainT != rainT;
  }
}

/// ===============================================================
/// MODELS
/// ===============================================================

class _DriftCloud {
  final double startX;
  final double y;
  final double scale;
  final double speedPxPerSec;
  final double opacity;
  final double bobOffset;

  const _DriftCloud({
    required this.startX,
    required this.y,
    required this.scale,
    required this.speedPxPerSec,
    required this.opacity,
    required this.bobOffset,
  });
}

class _FallingLeaf {
  final double startX;
  final double startDelay;
  final double fallSpeedPxPerSec;
  final double size;
  final double swayAmount;
  final double swaySpeed;
  final double swayOffset;
  final double opacity;
  final Color color;

  const _FallingLeaf({
    required this.startX,
    required this.startDelay,
    required this.fallSpeedPxPerSec,
    required this.size,
    required this.swayAmount,
    required this.swaySpeed,
    required this.swayOffset,
    required this.opacity,
    required this.color,
  });
}

class _Bird {
  final double startX; // 0..1 fraction of width
  final double y; // 0..1 fraction of height
  final double scale;
  final double speedPxPerSec;
  final double flapSpeed;
  final double flapOffset;
  final double glidePhase; // offsets the glide/flap cycle
  final double bobAmount;
  final double bobOffset;

  const _Bird({
    required this.startX,
    required this.y,
    required this.scale,
    required this.speedPxPerSec,
    required this.flapSpeed,
    required this.flapOffset,
    required this.glidePhase,
    required this.bobAmount,
    required this.bobOffset,
  });
}

class DaylightTime extends InheritedWidget {
  final double hour;

  const DaylightTime({super.key, required this.hour, required super.child});

  static double of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<DaylightTime>();
    if (widget == null) {
      final now = DateTime.now();
      return now.hour + now.minute / 60.0;
    }
    return widget.hour;
  }

  @override
  bool updateShouldNotify(DaylightTime old) => old.hour != hour;
}

class DaylightDebug {
  /// Global test hour. null = real device time.
  static double? hour;
}

class DayNight {
  /// Real hour, or the global debug hour if set.
  static double currentHour() {
    final override = DaylightDebug.hour;
    if (override != null) return override;
    final now = DateTime.now();
    return now.hour + now.minute / 60.0;
  }

  /// Night = after 19:00 or before 6:00.
  static bool isNight(double hour) => hour > 19.0 || hour < 6.0;
}

class CloudRain {
  static final ValueNotifier<int> trigger = ValueNotifier(0);
  static List<Rect> rects = [];
  static const List<double> strikeTimes = [0.9, 1.9, 2.7];

  static bool hit(Offset p) => rects.any((r) => r.contains(p));
  static void start() => trigger.value++;
}
