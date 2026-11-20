import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────
// ONBOARDING AI SCREEN 3 — "Seal It. The Rest Isn't Up to You."
// Hero: envelope card sealing shut → date label → unsealing with a glow
// Matches the existing onboarding visual language exactly.
// ─────────────────────────────────────────────────────────────────────────

class OnboardingAiCapsuleScreen extends StatefulWidget {
  const OnboardingAiCapsuleScreen({super.key});

  @override
  State<OnboardingAiCapsuleScreen> createState() =>
      _OnboardingAiCapsuleScreenState();
}

class _OnboardingAiCapsuleScreenState extends State<OnboardingAiCapsuleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..forward();

  // Envelope fades in closed
  late final Animation<double> _envelopeIn = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.0, 0.16, curve: Curves.easeOut),
  );

  // Flap closes (0 → 1 means flap rotates down and seals)
  late final Animation<double> _flapClose = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.16, 0.32, curve: Curves.easeInOut),
  );

  // Wax seal stamps
  late final Animation<double> _sealIn = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.34, 0.46, curve: Curves.easeOutBack),
  );

  // Date ribbon slides in
  late final Animation<double> _dateIn = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.48, 0.60, curve: Curves.easeOut),
  );

  // Soft glow pulses (sealed and waiting)
  late final Animation<double> _glowPulse = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.62, 0.78, curve: Curves.easeInOut),
  );

  // Title and body
  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.80, 0.90, curve: Curves.easeOut),
  );
  late final Animation<double> _bodyFade = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.89, 1.0, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const subtextColor = Color(0xFF827057);
    const accent = Color(0xFF9A302B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Hero: envelope illustration ─────────────────────────
          AnimatedBuilder(
            animation: _ac,
            builder: (context, _) {
              final envOpacity = _envelopeIn.value.clamp(0.0, 1.0);
              final envScale = 0.92 + envOpacity * 0.08;
              final flapT = _flapClose.value.clamp(0.0, 1.0);
              final sealT = _sealIn.value.clamp(0.0, 1.0);
              final dateT = _dateIn.value.clamp(0.0, 1.0);
              final glowT = _glowPulse.value.clamp(0.0, 1.0);

              return Opacity(
                opacity: envOpacity,
                child: Transform.scale(
                  scale: envScale,
                  child: SizedBox(
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Warm glow behind envelope
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              width: 180 + glowT * 20,
                              height: 180 + glowT * 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFB49A6A)
                                        .withOpacity(0.18 * glowT),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Envelope body
                        _EnvelopeBody(
                          flapClosed: flapT,
                          sealScale: sealT,
                          sealAccent: accent,
                        ),

                        // Date ribbon below envelope
                        Positioned(
                          bottom: 10,
                          child: Opacity(
                            opacity: dateT,
                            child: Transform.translate(
                              offset: Offset(0, (1 - dateT) * 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2B4A3A),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2B4A3A)
                                          .withOpacity(0.22),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.hourglass_empty_rounded,
                                      size: 12,
                                      color: Color(0xFFB8D4C0),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Opens  ${_futureDate()}',
                                      style: GoogleFonts.lora(
                                        fontSize: 12,
                                        color: const Color(0xFFF0E8D5),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // ── Title ───────────────────────────────────────────────
          FadeTransition(
            opacity: _titleFade,
            child: Text(
              'Seal It.\nThe Rest Isn\'t Up to You.',
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B1A14),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Description ─────────────────────────────────────────
          FadeTransition(
            opacity: _bodyFade,
            child: const Text(
              'Lock a memory away. When the moment\n'
              'arrives, the app writes its story — the\n'
              'way only time can tell it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 14,
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: subtextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _futureDate() {
    final future = DateTime.now().add(const Duration(days: 365));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[future.month - 1]} ${future.day}, ${future.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Envelope body — drawn with CustomPaint, flap animates closed
// ─────────────────────────────────────────────────────────────────────────

class _EnvelopeBody extends StatelessWidget {
  final double flapClosed; // 0 = open flap, 1 = sealed
  final double sealScale;
  final Color sealAccent;

  const _EnvelopeBody({
    required this.flapClosed,
    required this.sealScale,
    required this.sealAccent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Envelope body
          CustomPaint(
            size: const Size(200, 140),
            painter: _EnvelopePainter(
              flapClosed: flapClosed,
              bodyColor: const Color(0xFFF5ECD3),
              borderColor: const Color(0xFFB49A6A),
              flapColor: const Color(0xFFEEDFBF),
            ),
          ),

          // Wax seal at centre, appears after flap is closed
          if (flapClosed > 0.6)
            Positioned(
              top: 48,
              child: Transform.scale(
                scale: sealScale,
                child: Opacity(
                  opacity: sealScale,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sealAccent,
                      boxShadow: [
                        BoxShadow(
                          color: sealAccent.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.spa_outlined,
                      color: Color(0xFFF5E9CE),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EnvelopePainter extends CustomPainter {
  final double flapClosed;
  final Color bodyColor;
  final Color borderColor;
  final Color flapColor;

  const _EnvelopePainter({
    required this.flapClosed,
    required this.bodyColor,
    required this.borderColor,
    required this.flapColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()..color = bodyColor;
    final borderPaint = Paint()
      ..color = borderColor.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final flapPaint = Paint()..color = flapColor;

    // Shadow
    final bodyPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, h * 0.18, w, h * 0.82),
          const Radius.circular(6)));
    canvas.drawShadow(
        bodyPath.shift(const Offset(0, 4)), const Color(0xFF6B5032), 10, false);

    // Envelope body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, h * 0.18, w, h * 0.82), const Radius.circular(6)),
      bodyPaint,
    );

    // Bottom triangle fold lines (V shape inside the body)
    final vPath = Path()
      ..moveTo(0, h * 0.18)
      ..lineTo(w / 2, h * 0.62)
      ..lineTo(w, h * 0.18);
    canvas.drawPath(vPath, borderPaint);

    // Left and right triangle folds
    final leftFold = Path()
      ..moveTo(0, h * 0.18)
      ..lineTo(w * 0.42, h * 0.62)
      ..lineTo(0, h);
    canvas.drawPath(leftFold, Paint()..color = bodyColor.withOpacity(0.6));

    final rightFold = Path()
      ..moveTo(w, h * 0.18)
      ..lineTo(w * 0.58, h * 0.62)
      ..lineTo(w, h);
    canvas.drawPath(rightFold, Paint()..color = bodyColor.withOpacity(0.6));

    // Flap — rotates from open (pointing up, triangle above body)
    // to closed (flap folds down over the body top)
    final flapTopY = h * 0.18 - (1 - flapClosed) * h * 0.36;
    final flapPath = Path()
      ..moveTo(0, h * 0.18)
      ..lineTo(w / 2, flapTopY)
      ..lineTo(w, h * 0.18)
      ..close();
    canvas.drawPath(flapPath, flapPaint);
    canvas.drawPath(flapPath, borderPaint);

    // Body border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, h * 0.18, w, h * 0.82), const Radius.circular(6)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _EnvelopePainter old) =>
      old.flapClosed != flapClosed;
}