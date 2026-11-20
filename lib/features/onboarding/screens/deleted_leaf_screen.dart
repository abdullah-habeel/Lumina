import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/features/home/widgets/tree/growing_memory_tree.dart';
import 'package:lumina/features/home/widgets/tree/tree_leaf_anchor.dart';

class OnboardingDeletedLeavesScreen extends StatefulWidget {
  const OnboardingDeletedLeavesScreen({super.key});

  @override
  State<OnboardingDeletedLeavesScreen> createState() =>
      _OnboardingDeletedLeavesScreenState();
}

class _OnboardingDeletedLeavesScreenState
    extends State<OnboardingDeletedLeavesScreen>
    with TickerProviderStateMixin {
  // ── Screen fade ───────────────────────────────────────────────
  late final AnimationController _fadeAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();
  late final Animation<double> _screenFade = CurvedAnimation(
    parent: _fadeAc,
    curve: Curves.easeOut,
  );

  // ── Staggered reveal controllers ──────────────────────────────
  late final AnimationController _titleAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final AnimationController _subtitleAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final AnimationController _treeAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final AnimationController _hintAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  // ── Fallen-state reveal controllers ───────────────────────────
  late final AnimationController _cardAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final AnimationController _row1Ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final AnimationController _row2Ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final AnimationController _row3Ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  // ── Leaf pulse ────────────────────────────────────────────────
  late final AnimationController _pulseAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  static const int _anchorIndex = 0;
  static const double _treeHeight = 300;

  bool _fallen = false;
  int _fallTriggerIndex = -1;

  @override
  void initState() {
    super.initState();
    _runEntrySequence();
  }

  Future<void> _runEntrySequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _titleAc.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    _subtitleAc.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _treeAc.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    _hintAc.forward();
  }

  Future<void> _runFallenSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cardAc.forward();
    await Future.delayed(const Duration(milliseconds: 180));
    _row1Ac.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _row2Ac.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _row3Ac.forward();
  }

  void _onDeadLeafFallComplete(int anchorIndex) {
    if (!mounted) return;
    setState(() {
      _fallen = true;
      _fallTriggerIndex = -1;
      _pulseAc.stop();
    });
    _runFallenSequence();
  }

  void _handleTapUp(TapUpDetails details, double treeWidth) {
    if (_fallen || _fallTriggerIndex != -1) return;
    if (_anchorIndex >= treeLeafAnchors.length) return;

    final localPos = details.localPosition;
    final anchor = treeLeafAnchors[_anchorIndex];
    final leafWidth = treeWidth * 0.042;
    final leafHeight = leafWidth * 1.5;
    final anchorX = anchor.x * treeWidth;
    final anchorY = anchor.y * _treeHeight;
    final left = anchorX - leafWidth * 0.5;
    final top = anchorY - leafHeight * 0.90;
    final rect = Rect.fromLTWH(left, top, leafWidth, leafHeight).inflate(10);

    if (rect.contains(localPos)) {
      setState(() => _fallTriggerIndex = _anchorIndex);
    }
  }

  @override
  void dispose() {
    _fadeAc.dispose();
    _titleAc.dispose();
    _subtitleAc.dispose();
    _treeAc.dispose();
    _hintAc.dispose();
    _cardAc.dispose();
    _row1Ac.dispose();
    _row2Ac.dispose();
    _row3Ac.dispose();
    _pulseAc.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────

  Widget _fadeSlide(AnimationController ac, Widget child) {
    return AnimatedBuilder(
      animation: ac,
      builder: (_, __) {
        final curved = CurvedAnimation(parent: ac, curve: Curves.easeOut);
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - curved.value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _infoRow(AnimationController ac, IconData icon, String text) {
    return _fadeSlide(
      ac,
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5016).withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: const Color(0xFF2D5016)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.lora(
                  fontSize: 13,
                  height: 1.5,
                  color: const Color(0xFF4A3728),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final treeWidth = MediaQuery.sizeOf(context).width - 32;

    return FadeTransition(
      opacity: _screenFade,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            // ── Title ──────────────────────────────────────────
            _fadeSlide(
              _titleAc,
              Text(
                'Deleted memories\nbecome fallen leaves',
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B251B),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Subtitle ───────────────────────────────────────
            _fadeSlide(
              _subtitleAc,
              Text(
                _fallen
                    ? 'That memory is gone for good.'
                    : 'Tap the dead leaf on the tree to let it fall.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0xFF6B5D4C),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Tree ───────────────────────────────────────────
            _fadeSlide(
              _treeAc,
              Stack(
                alignment: Alignment.center,
                children: [
                  // Warm oval ground shadow
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: treeWidth * 0.55,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B6A4A).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTapUp: (details) => _handleTapUp(details, treeWidth),
                    child: SizedBox(
                      height: _treeHeight,
                      width: treeWidth,
                      child: GrowingMemoryTree(
                        entryCount: 0,
                        maxLeaves: 96,
                        height: _treeHeight,
                        animateNewLeaves: false,
                        deletedAnchorIndices: _fallen ? {} : {_anchorIndex},
                        skippedAnchorIndices: _fallen ? {_anchorIndex} : {},
                        fallTriggerIndex: _fallTriggerIndex,
                        onDeadLeafFallComplete: _onDeadLeafFallComplete,
                      ),
                    ),
                  ),

                  // Pulse ring on leaf position (before fallen)
                  if (!_fallen && _fallTriggerIndex == -1)
                    _LeafPulse(
                      animation: _pulseAc,
                      anchorIndex: _anchorIndex,
                      treeWidth: treeWidth,
                      treeHeight: _treeHeight,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tap hint ──────────────────────────────────────
            if (!_fallen)
              _fadeSlide(
                _hintAc,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 14,
                      color: const Color(0xFF8B6A4A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap the withered leaf',
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF8B6A4A),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Post-fall content ─────────────────────────────
            if (_fallen) ...[
              // Card
              _fadeSlide(
                _cardAc,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EDE0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD4B896),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'In the real app, deleted memories leave a permanent gap on your tree — a quiet reminder of what once was.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                      color: const Color(0xFF6B4C2A),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _infoRow(
                _row3Ac,
                Icons.eco_outlined,
                'Every new memory you write grows your tree back.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Leaf pulse indicator ────────────────────────────────────────────────────

class _LeafPulse extends StatelessWidget {
  const _LeafPulse({
    required this.animation,
    required this.anchorIndex,
    required this.treeWidth,
    required this.treeHeight,
  });

  final Animation<double> animation;
  final int anchorIndex;
  final double treeWidth;
  final double treeHeight;

  @override
  Widget build(BuildContext context) {
    if (anchorIndex >= treeLeafAnchors.length) return const SizedBox.shrink();

    final anchor = treeLeafAnchors[anchorIndex];
    final leafWidth = treeWidth * 0.042;
    final leafHeight = leafWidth * 1.5;
    final anchorX = anchor.x * treeWidth;
    final anchorY = anchor.y * treeHeight;

    // Match exactly how _handleTapUp computes the leaf center
    final leafCenterX =
        anchorX - leafWidth * 0.5 + leafWidth * 0.5; // = anchorX
    final leafCenterY = anchorY - leafHeight * 0.90 + leafHeight * 0.5;

    const circleSize = 32.0;

    return Positioned(
      left: leafCenterX - circleSize / 2,
      top: leafCenterY - circleSize / 2,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          final scale = 0.85 + 0.30 * animation.value;
          final opacity = 0.20 + 0.40 * (1 - animation.value);
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC0392B),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
