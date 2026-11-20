import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────
// ONBOARDING AI SCREEN 2 — "Yours Alone, Unless You Say So"
// Hero: an animated illustration showing on-device lock → cloud toggle
// Matches the existing onboarding visual language exactly.
// ─────────────────────────────────────────────────────────────────────────

class OnboardingAiPrivacyScreen extends StatefulWidget {
  const OnboardingAiPrivacyScreen({super.key});

  @override
  State<OnboardingAiPrivacyScreen> createState() =>
      _OnboardingAiPrivacyScreenState();
}

class _OnboardingAiPrivacyScreenState extends State<OnboardingAiPrivacyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..forward();

  // Phone illustration fades in
  late final Animation<double> _phoneIn = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.0, 0.18, curve: Curves.easeOut),
  );

  // Lock icon scales in on the phone
  late final Animation<double> _lockIn = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.20, 0.36, curve: Curves.easeOutBack),
  );

  // "On device" label fades in
  late final Animation<double> _onDeviceFade = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.36, 0.50, curve: Curves.easeOut),
  );

  // Dashed line draws toward cloud
  late final Animation<double> _lineGrow = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.50, 0.66, curve: Curves.easeInOut),
  );

  // Cloud appears with a cross (blocked)
  late final Animation<double> _cloudIn = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.66, 0.78, curve: Curves.easeOutBack),
  );

  // Title and body
  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.82, 0.92, curve: Curves.easeOut),
  );
  late final Animation<double> _bodyFade = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.91, 1.0, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const subtextColor = Color(0xFF827057);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Hero illustration ───────────────────────────────────
          AnimatedBuilder(
            animation: _ac,
            builder: (context, _) {
              return SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dashed line from phone to cloud
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 70,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              _lineGrow.value.clamp(0.0, 1.0),
                          child: CustomPaint(
                            size: const Size(double.infinity, 2),
                            painter: _DashedLinePainter(
                              color: const Color(0xFF9A7B5A)
                                  .withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Phone (left)
                    Positioned(
                      left: 24,
                      top: 20,
                      child: Opacity(
                        opacity: _phoneIn.value.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale:
                              0.92 + _phoneIn.value.clamp(0.0, 1.0) * 0.08,
                          child: _PhoneWithLock(
                            lockScale:
                                _lockIn.value.clamp(0.0, 1.0),
                            labelOpacity:
                                _onDeviceFade.value.clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ),

                    // Cloud (right, blocked)
                    Positioned(
                      right: 24,
                      top: 20,
                      child: Opacity(
                        opacity: _cloudIn.value.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.88 +
                              _cloudIn.value.clamp(0.0, 1.0) * 0.12,
                          child: const _CloudBlocked(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // ── Title ───────────────────────────────────────────────
          FadeTransition(
            opacity: _titleFade,
            child: Text(
              'Yours Alone,\nUnless You Say So',
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
              'AI runs on your device, not in the cloud.\n'
              'Your memories never leave your phone\n'
              'without your permission.',
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
}

// ─────────────────────────────────────────────────────────────────────────
// Phone illustration with lock badge
// ─────────────────────────────────────────────────────────────────────────

class _PhoneWithLock extends StatelessWidget {
  final double lockScale;
  final double labelOpacity;

  const _PhoneWithLock({
    required this.lockScale,
    required this.labelOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Phone body
              Container(
                width: 72,
                height: 126,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B4A3A),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2B4A3A).withOpacity(0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              // Screen area
              Container(
                width: 60,
                height: 108,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5ECD3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Transform.scale(
                    scale: lockScale,
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF2B4A3A),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: labelOpacity,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2B4A3A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'on device',
              style: GoogleFonts.lora(
                fontSize: 11,
                color: const Color(0xFFF0E8D5),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Cloud with an X — blocked/disabled state
// ─────────────────────────────────────────────────────────────────────────

class _CloudBlocked extends StatelessWidget {
  const _CloudBlocked();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cloud shape via icon
              Icon(
                Icons.cloud_rounded,
                size: 80,
                color: const Color(0xFF827057).withOpacity(0.22),
              ),
              // Cross over the cloud
              Icon(
                Icons.block_rounded,
                size: 36,
                color: const Color(0xFF9A302B).withOpacity(0.55),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF9A302B).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF9A302B).withOpacity(0.30),
              width: 0.8,
            ),
          ),
          child: Text(
            'not uploaded',
            style: GoogleFonts.lora(
              fontSize: 11,
              color: const Color(0xFF9A302B),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Dashed line painter
// ─────────────────────────────────────────────────────────────────────────

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashGap = 5.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) =>
      old.color != color;
}