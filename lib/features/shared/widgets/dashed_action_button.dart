import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';

class DoubleBorderActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color outerBorderColor;
  final Color innerBorderColor;
  final Color contentColor;
  final double borderRadius;
  final double gap;
  final EdgeInsetsGeometry padding;
  final bool animate;

  const DoubleBorderActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
    this.outerBorderColor = AppColors.borderGold,
    this.innerBorderColor = AppColors.borderGold,
    this.contentColor = AppColors.primaryGreen,
    this.borderRadius = 30,
    this.gap = 4,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.animate = true,
  });

  @override
  State<DoubleBorderActionButton> createState() =>
      _DoubleBorderActionButtonState();
}

class _DoubleBorderActionButtonState extends State<DoubleBorderActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant DoubleBorderActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.gap),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EED8),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.outerBorderColor.withOpacity(0.7),
          width: 2.5,
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _MarchingAntsPainter(
              color: widget.innerBorderColor,
              radius: widget.borderRadius - widget.gap,
              dashWidth: 4,
              dashGap: 3,
              phase: widget.animate ? _controller.value * 7 : 0,
              solid: !widget.animate,
            ),
            child: child,
          );
        },
        child: SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(
                widget.borderRadius - widget.gap,
              ),
              child: Padding(
                padding: widget.padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: widget.contentColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.contentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarchingAntsPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashGap;
  final double phase;
  final bool solid;

  _MarchingAntsPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashGap,
    required this.phase,
    this.solid = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    if (solid) {
      canvas.drawRRect(rrect, paint);
      return;
    }

    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final cycle = dashWidth + dashGap;
    final dashedPath = Path();

    double distance = -(phase % cycle);
    while (distance < metric.length) {
      final start = math.max(0, distance).toDouble();
      final end = (distance + dashWidth).clamp(0, metric.length).toDouble();
      if (end > start) {
        dashedPath.addPath(metric.extractPath(start, end), Offset.zero);
      }
      distance += cycle;
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _MarchingAntsPainter old) =>
      old.phase != phase || old.solid != solid || old.color != color;
}
