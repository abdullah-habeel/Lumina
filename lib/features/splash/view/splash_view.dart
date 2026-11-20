import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/features/splash/controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5EDD9),
      body: Center(child: _AnimatedSplashContent()),
    );
  }
}

class _AnimatedSplashContent extends StatefulWidget {
  const _AnimatedSplashContent();

  @override
  State<_AnimatedSplashContent> createState() =>
      _AnimatedSplashContentState();
}

class _AnimatedSplashContentState extends State<_AnimatedSplashContent>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _rayController;
  late final AnimationController _pulseController;

  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _rayOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _coreScale;

  @override
  void initState() {
    super.initState();

    // Slide + fade in
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Rays burst in once
    _rayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rayOpacity = Tween<double>(begin: 0, end: 0.75).animate(
      CurvedAnimation(parent: _rayController, curve: Curves.easeOut),
    );

    // Continuous pulse on core + ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _ringScale = Tween<double>(begin: 0.5, end: 1.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _ringOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _coreScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Sequence: slide in first, then rays burst
    _slideController.forward().then((_) {
      _rayController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _rayController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _ray({
    required double top,
    required double? bottom,
    required double? left,
    required double? right,
    required double width,
    required double height,
    required double angle,
  }) {
    return Positioned(
      top: top == -1 ? null : top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: angle,
        child: FadeTransition(
          opacity: _rayOpacity,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFC8933A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Lumina text ──────────────────────────────────
            const Text(
              'Lumina',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E2C1C),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 10),

            // ── Light icon ───────────────────────────────────
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing ring
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Transform.scale(
                      scale: _ringScale.value,
                      child: Opacity(
                        opacity: _ringOpacity.value,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFC8933A),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Top ray
                  _ray(top: 2, bottom: null, left: 17, right: null, width: 2, height: 10, angle: 0),
                  // Bottom ray
                  _ray(top: -1, bottom: 2, left: 17, right: null, width: 2, height: 10, angle: 0),
                  // Left ray
                  _ray(top: 17, bottom: null, left: 2, right: null, width: 10, height: 2, angle: 0),
                  // Right ray
                  _ray(top: 17, bottom: null, left: null, right: 2, width: 10, height: 2, angle: 0),
                  // Top-right diagonal
                  _ray(top: 4, bottom: null, left: null, right: 4, width: 2, height: 8, angle: 0.785),
                  // Bottom-left diagonal
                  _ray(top: -1, bottom: 4, left: 4, right: null, width: 2, height: 8, angle: 0.785),
                  // Top-left diagonal
                  _ray(top: 4, bottom: null, left: 4, right: null, width: 2, height: 8, angle: -0.785),
                  // Bottom-right diagonal
                  _ray(top: -1, bottom: 4, left: null, right: 4, width: 2, height: 8, angle: -0.785),

                  // Core dot
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Transform.scale(
                      scale: _coreScale.value,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC8933A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}