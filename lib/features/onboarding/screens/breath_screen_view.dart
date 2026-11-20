import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_background.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';

class BreatheScreenView extends StatefulWidget {
  const BreatheScreenView({super.key});

  @override
  State<BreatheScreenView> createState() => _BreatheScreenViewState();
}

class _BreatheScreenViewState extends State<BreatheScreenView>
    with TickerProviderStateMixin {
  // --- Cinematic timing ---
  // Title holds on screen alone, then a beat of silence, then the
  // subtitle drifts in, then another beat before the button appears.
  static const _titleStart = Duration(milliseconds: 300);
  static const _titleFadeDuration = Duration(milliseconds: 1400);
  static const _gapAfterTitle = Duration(milliseconds: 900);
  static const _subtitleFadeDuration = Duration(milliseconds: 1400);
  static const _gapAfterSubtitle = Duration(milliseconds: 700);

  static final Duration _subtitleStart =
      _titleStart + _titleFadeDuration + _gapAfterTitle;
  static final Duration _buttonStart =
      _subtitleStart + _subtitleFadeDuration + _gapAfterSubtitle;

  // Looping breathing glow — runs the whole time, independent of the text.
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat(reverse: true);

  late final Animation<double> _breatheCurve = CurvedAnimation(
    parent: _breathe,
    curve: Curves.easeInOut,
  );

  // Title: fade + gentle rise.
  late final AnimationController _titleController = AnimationController(
    vsync: this,
    duration: _titleFadeDuration,
  );
  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _titleController,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _titleSlide = Tween(
    begin: const Offset(0, 0.1),
    end: Offset.zero,
  ).animate(_titleFade);

  // Subtitle: fade + gentle rise, starts only after the title's beat.
  late final AnimationController _subtitleController = AnimationController(
    vsync: this,
    duration: _subtitleFadeDuration,
  );
  late final Animation<double> _subtitleFade = CurvedAnimation(
    parent: _subtitleController,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _subtitleSlide = Tween(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(_subtitleFade);

  // Button, last to arrive.
  late final AnimationController _buttonController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _buttonFade = CurvedAnimation(
    parent: _buttonController,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(_titleStart, () {
      if (mounted) _titleController.forward();
    });
    Future.delayed(_subtitleStart, () {
      if (mounted) _subtitleController.forward();
    });
    Future.delayed(_buttonStart, () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _breathe.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const subtextColor = Color(0xFF3D2B20);

    return DaylightBookBackground(
      debugOverrideHour: 10,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Animation + text, centered.
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _breatheCurve,
                        builder: (context, _) {
                          final t = _breatheCurve.value;
                          final scale = 1.0 + t * 0.18;
                          final glowOpacity = 0.22 + t * 0.18;

                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(
                                      0xFFF5ECD3,
                                    ).withOpacity(glowOpacity),
                                    const Color(0xFFF5ECD3).withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: Text(
                            'Take a Deep Breath',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fraunces(
                              fontSize: 28,
                              height: 1.15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2B1A14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      FadeTransition(
                        opacity: _subtitleFade,
                        child: SlideTransition(
                          position: _subtitleSlide,
                          child: const Text(
                            'And start writing your book ',

                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 16,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                              color: subtextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Button, floating at the bottom, delayed fade-in.
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: FadeTransition(
                    opacity: _buttonFade,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(_buttonFade),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.offAllNamed(AppRoutes.register);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1f3d2e),
                            foregroundColor: const Color(0xFFF5EDD9),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create My Story',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
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
  }
}
