import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_images.dart';

/// Shows a one-time "Memory saved" celebration overlay, then completes
/// after the animation finishes. Await this before navigating away.
Future<void> showMemorySavedCelebration(BuildContext context) async {
  final overlay = Overlay.of(context);
  final completer = Completer<void>();

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _MemorySavedOverlay(
      onFinished: () {
        entry.remove();
        completer.complete();
      },
    ),
  );

  overlay.insert(entry);
  return completer.future;
}

class _MemorySavedOverlay extends StatefulWidget {
  final VoidCallback onFinished;
  const _MemorySavedOverlay({required this.onFinished});

  @override
  State<_MemorySavedOverlay> createState() => _MemorySavedOverlayState();
}

class _MemorySavedOverlayState extends State<_MemorySavedOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final Animation<double> _iconScale;

  late final AnimationController _fadeController;
  late final Animation<double> _overlayFade;

  late final AnimationController _particleController;

  final List<_BurstParticle> _particles = List.generate(
    10,
    (i) => _BurstParticle(seed: i),
  );

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _overlayFade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_iconController);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _fadeController.forward();
    unawaited(_particleController.forward());
    await _iconController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    await _fadeController.reverse();
    widget.onFinished();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _iconController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _overlayFade,
      builder: (context, child) {
        return Opacity(opacity: _overlayFade.value, child: child);
      },
      child: Material(
        color: Colors.black.withOpacity(0.35),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ..._particles.map((p) => _buildParticle(p)),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _iconScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _iconScale.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xffF5EDD9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Color(0xff2F4E35),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _iconScale,
                    builder: (context, child) {
                      final opacity = _iconController.value.clamp(0.0, 1.0);
                      return Opacity(opacity: opacity, child: child);
                    },
                    child: const Text(
                      'Memory saved',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticle(_BurstParticle p) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_particleController.value);
        final dx = cos(p.angle) * p.distance * t;
        final dy = sin(p.angle) * p.distance * t;
        final opacity = (1.0 - t).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: p.size,
              height: p.size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffE8C97A),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BurstParticle {
  final double angle;
  final double distance;
  final double size;

  _BurstParticle({required int seed})
    : angle = (seed / 10) * 2 * pi,
      distance = 60.0 + (seed % 3) * 15,
      size = 4.0 + (seed % 3);
}
