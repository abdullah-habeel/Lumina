// features/time_capsule/widgets/lock_interaction.dart

import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_images.dart';

class LockInteraction extends StatefulWidget {
  final bool isUnlocked;
  final Color borderColor;
  final Color glowColor;

  const LockInteraction({
    super.key,
    required this.isUnlocked,
    required this.borderColor,
    required this.glowColor,
  });

  @override
  State<LockInteraction> createState() => _LockInteractionState();
}

class _LockInteractionState extends State<LockInteraction>
    with TickerProviderStateMixin {
  // ── Wiggle ─────────────────────────────────────────────────────
  late final AnimationController _wiggleController;
  late final Animation<double> _wiggle;

  // ── Glow ───────────────────────────────────────────────────────
  late final AnimationController _glowController;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _wiggle =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -0.08), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -0.08, end: 0.08), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 0.08, end: -0.06), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -0.06, end: 0.06), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 0.06, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _wiggleController, curve: Curves.easeInOut),
        );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _glow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTap() {
    _wiggleController.forward(from: 0);
    _glowController.forward(from: 0).then((_) {
      _glowController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_wiggle, _glow]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _wiggle.value,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.borderColor.withOpacity(0.55),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(_glow.value * 0.7),
                    blurRadius: 18 * _glow.value,
                    spreadRadius: 4 * _glow.value,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  widget.isUnlocked ? AppImages.lockopen : AppImages.padlock,
                  width: 31,
                  height: 31,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
