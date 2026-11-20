import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/features/home/models/controller/home_controller.dart';

class BookShowcase extends StatefulWidget {
  const BookShowcase({super.key});

  @override
  State<BookShowcase> createState() => _BookShowcaseState();
}

class _BookShowcaseState extends State<BookShowcase>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;

  late final AnimationController _pressController;
  late final Animation<double> _pressScale;

  late final AnimationController _glowController;

  final List<_Particle> _particles = List.generate(
    6,
    (i) => _Particle(seed: i),
  );

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _showStorySoFar(
    HomeController homeController,
    JournalController journalController,
  ) {
    final totalMemories = journalController.entries.length;
    
    final totalChapters = homeController.chapters.length;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        decoration: const BoxDecoration(
          color: Color(0xffF5EDD9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'YOUR STORY SO FAR',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
                color: Colors.brown.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatBlock(value: '$totalMemories', label: 'memories'),
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.brown.withOpacity(.15),
                ),
                
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '"Some moments deserve to live forever."',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.brown.shade500,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final journalController = Get.find<JournalController>();

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: () => _showStorySoFar(homeController, journalController),
      child: SizedBox(
        width: double.infinity,
        height: 230,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ── Ambient glow behind the book ──────────────────────
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glowStrength = 0.15 + (_glowController.value * 0.12);
                return Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xffE8C97A).withOpacity(glowStrength),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),

            // ── Floating light particles ───────────────────────────
            ..._particles.map((p) => _buildParticle(p)),

            // ── Shadow beneath the book, reacts to float height ────
            AnimatedBuilder(
              animation: _floatAnim,
              builder: (context, child) {
                final lift = _floatAnim.value;
                return Positioned(
                  bottom: 6,
                  child: Opacity(
                    opacity: 0.28 - (lift * 0.12),
                    child: Transform.scale(
                      scale: 1.0 - (lift * 0.12),
                      child: Container(
                        width: 130,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade900,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── The book itself, floating + pressable, full width ──
            Positioned(
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: Listenable.merge([_floatAnim, _pressScale]),
                builder: (context, child) {
                  final floatOffset = -10 * _floatAnim.value;
                  return Transform.translate(
                    offset: Offset(0, floatOffset),
                    child: Transform.scale(
                      scale: _pressScale.value,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  AppImages.bookIllustration,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),

            // ── Stats label ─────────────────────────────────────────
            Positioned(
              bottom: -22,
              child: Obx(
                () => Text(
                  '${journalController.entries.length} memories written',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.brown.shade400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(_Particle p) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final t = (_floatController.value + p.phase) % 1.0;
        final dy = sin(t * 2 * pi) * p.driftY;
        final dx = cos(t * 2 * pi) * p.driftX;
        final opacity = (sin(t * pi)).clamp(0.0, 1.0) * p.maxOpacity;

        return Positioned(
          left: 110 + p.baseX + dx,
          top: 90 + p.baseY + dy,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: p.size,
              height: p.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffF3D98B),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;

  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.brown.shade400),
        ),
      ],
    );
  }
}

class _Particle {
  final double phase;
  final double baseX;
  final double baseY;
  final double driftX;
  final double driftY;
  final double size;
  final double maxOpacity;

  _Particle({required int seed})
    : phase = (seed * 0.17) % 1.0,
      baseX = (seed.isEven ? -1 : 1) * (20.0 + seed * 8),
      baseY = (seed % 3) * 14.0 - 14,
      driftX = 6.0 + (seed % 3) * 3,
      driftY = 10.0 + (seed % 4) * 4,
      size = 3.0 + (seed % 3),
      maxOpacity = 0.35 + (seed % 3) * 0.1;
}
