import 'package:flutter/material.dart';
import 'package:lumina/features/time_capsule/model/time_capsule_model.dart';
import 'package:lumina/features/time_capsule/widgets/sealed_capsule_card.dart';

class SealedCapsuleCardWrapper extends StatefulWidget {
  final TimeCapsuleModel capsule;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;
  final int index;

  const SealedCapsuleCardWrapper({
    super.key,
    required this.capsule,
    required this.onTap,
    required this.onMoreTap,
    required this.index,
  });

  @override
  State<SealedCapsuleCardWrapper> createState() =>
      _SealedCapsuleCardWrapperState();
}

class _SealedCapsuleCardWrapperState extends State<SealedCapsuleCardWrapper>
    with TickerProviderStateMixin {
  // ── Entry ──────────────────────────────────────────────────────
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  // ── Press ──────────────────────────────────────────────────────
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
        );

    final delay = Duration(milliseconds: 120 * widget.index);
    Future.delayed(delay, () {
      if (mounted) _entryController.forward();
    });

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: ScaleTransition(
          scale: _scale,
          // ── No GestureDetector here at all ──────────────────────
          // SealedCapsuleCard and its children own all taps.
          child: SealedCapsuleCard(
            capsule: widget.capsule,
            onTap: widget.onTap,
            onMoreTap: widget.onMoreTap,
            onPressDown: () => _pressController.forward(),
            onPressUp: () => _pressController.reverse(),
          ),
        ),
      ),
    );
  }
}
