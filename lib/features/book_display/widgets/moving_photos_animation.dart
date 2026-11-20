import 'package:flutter/material.dart';

class SwayingPolaroid extends StatefulWidget {
  final Widget child;
  final double swayAngle;
  final Duration duration;

  const SwayingPolaroid({
    super.key,
    required this.child,
    this.swayAngle = 0.03,
    required this.duration,
  });

  @override
  State<SwayingPolaroid> createState() => _SwayingPolaroidState();
}

class _SwayingPolaroidState extends State<SwayingPolaroid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sway;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _sway = Tween<double>(
      begin: -widget.swayAngle,
      end: widget.swayAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sway,
      builder: (context, child) {
        return Transform.rotate(
          angle: _sway.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}