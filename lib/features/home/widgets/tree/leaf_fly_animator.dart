import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/features/home/widgets/tree/tree_leaf_anchor.dart';

class LeafFlyAnimator {
  static void fly({
    required BuildContext context,
    required int nextLeafIndex,
    required Rect treeRect,
    required VoidCallback onComplete,
  }) {
    final overlay = Overlay.of(context);

    final overlayRenderObject = overlay.context.findRenderObject();

    if (overlayRenderObject is! RenderBox || !overlayRenderObject.hasSize) {
      onComplete();
      return;
    }

    final overlayBox = overlayRenderObject;

    final anchor = treeLeafAnchors[nextLeafIndex];

    final leafWidth = treeRect.width * 0.042;
    final leafHeight = leafWidth * 1.5;
    final anchorX = treeRect.left + (anchor.x * treeRect.width);
    final anchorY = treeRect.top + (anchor.y * treeRect.height);

    final anchorPosition = Offset(anchorX, anchorY - (leafHeight * 0.40));

    final overlaySize = overlayBox.size;

    // Start from below the tree.
    // This makes the leaf visibly travel upward toward the tree.
    final startPosition = Offset(
      overlaySize.width * 0.50,
      treeRect.bottom + 55,
    );

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        return _FlyingLeaf(
          startPosition: startPosition,
          endPosition: anchorPosition,
          endRotation: anchor.rotation,
          leafWidth: leafWidth,
          leafHeight: leafHeight,
          onComplete: () {
            onComplete();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (entry.mounted) {
                entry.remove();
              }
            });
          },
        );
      },
    );

    overlay.insert(entry);
  }
}

class _FlyingLeaf extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final double endRotation;
  final double leafWidth;
  final double leafHeight;
  final VoidCallback onComplete;

  const _FlyingLeaf({
    required this.startPosition,
    required this.endPosition,
    required this.endRotation,
    required this.leafWidth,
    required this.leafHeight,
    required this.onComplete,
  });

  @override
  State<_FlyingLeaf> createState() => _FlyingLeafState();
}

class _FlyingLeafState extends State<_FlyingLeaf>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    // Start AFTER initState has completed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _calculatePosition(double t) {
    final start = widget.startPosition;
    final end = widget.endPosition;

    /*
     * Cubic Bezier path.
     *
     * The leaf first moves slightly sideways,
     * then curves upward toward the tree,
     * giving it a natural flying motion.
     */

    final control1 = Offset(start.dx - 35, start.dy - 110);

    final control2 = Offset(end.dx + 45, end.dy + 90);

    final oneMinusT = 1.0 - t;

    final x =
        (oneMinusT * oneMinusT * oneMinusT * start.dx) +
        (3 * oneMinusT * oneMinusT * t * control1.dx) +
        (3 * oneMinusT * t * t * control2.dx) +
        (t * t * t * end.dx);

    final y =
        (oneMinusT * oneMinusT * oneMinusT * start.dy) +
        (3 * oneMinusT * oneMinusT * t * control1.dy) +
        (3 * oneMinusT * t * t * control2.dy) +
        (t * t * t * end.dy);

    return Offset(x, y);
  }

  double _calculateRotation(double t) {
    /*
     * Small natural rotation while flying.
     * Eventually settles into the exact anchor rotation.
     */

    final naturalRotation = math.sin(t * math.pi * 3.0) * 0.18;

    return naturalRotation + (widget.endRotation - naturalRotation) * t;
  }

  double _calculateScale(double t) {
    /*
     * Start slightly smaller.
     * Grow to normal leaf size.
     * Slightly compress when attaching.
     */

    if (t < 0.12) {
      return 0.75 + (t / 0.12) * 0.25;
    }

    if (t > 0.88) {
      final attachProgress = (t - 0.88) / 0.12;

      return 1.0 - (math.sin(attachProgress * math.pi) * 0.06);
    }

    return 1.0;
  }

  double _calculateOpacity(double t) {
    // Keep the leaf visible.
    // Do NOT fade it out before reaching the tree.
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        final t = _progress.value;

        final position = _calculatePosition(t);

        final rotation = _calculateRotation(t);

        final scale = _calculateScale(t);

        final opacity = _calculateOpacity(t);

        return Positioned(
          left: position.dx - (widget.leafWidth / 2),
          top: position.dy - (widget.leafHeight / 2),
          width: widget.leafWidth,
          height: widget.leafHeight,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: rotation,
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: Image.asset(AppImages.leaf1, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
