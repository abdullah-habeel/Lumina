import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/features/music/controller/sound_effects_controller.dart';
import 'tree_leaf_anchor.dart';

class GrowingMemoryTree extends StatefulWidget {
  const GrowingMemoryTree({
    super.key,
    required this.entryCount,
    this.maxLeaves = 30,
    this.fallTriggerIndex = -1,
    this.height,
    this.onTreeTap,
    this.onLeafTap,
    this.enableLeafTap = false,
    this.deletedAnchorIndices = const {},
    this.skippedAnchorIndices = const {},
    this.onDeadLeafFallComplete,
    this.animateNewLeaves = true,
  });

  final int entryCount;
  final VoidCallback? onTreeTap;
  final void Function(int leafIndex)? onLeafTap;
  final bool enableLeafTap;
  final int maxLeaves;
  final int fallTriggerIndex;
  final double? height;
  final Set<int> deletedAnchorIndices;
  final Set<int> skippedAnchorIndices;
  final void Function(int anchorIndex)? onDeadLeafFallComplete;
  final bool animateNewLeaves;

  static const double treeAspectRatio = 1278 / 1230;

  @override
  State<GrowingMemoryTree> createState() => _GrowingMemoryTreeState();
}

class _GrowingMemoryTreeState extends State<GrowingMemoryTree>
    with TickerProviderStateMixin {
  // ── Leaf growth animation ─────────────────────────────────────
  late final AnimationController _leafController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  // ── Float-up path animation ───────────────────────────────────
  // The newest leaf floats up from below and drifts into position.
  late final AnimationController _floatController;
  late final Animation<double> _floatY; // vertical travel (px offset)
  late final Animation<double> _floatX; // gentle horizontal drift
  late final Animation<double> _floatRotate; // slight spin while floating
  late final Animation<double> _floatOpacity; // fade in during float

  // ── Wind animation ────────────────────────────────────────────
  late final AnimationController _windController;

  int _visibleLeafCount = 0;
  int _previousLeafCount = 0;

  @override
  void initState() {
    super.initState();

    // ── Growth (scale + opacity at landing) ──────────────────────
    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _leafController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _leafController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // ── Float-up path ────────────────────────────────────────────
    // Total duration: 1.4 s
    //   0.0 → 0.7  leaf rises up from +80px below anchor
    //   0.7 → 1.0  leaf settles with the growth bounce
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Vertical: starts 80px BELOW the anchor, ends at 0 (on anchor)
    _floatY = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.0, 0.72, curve: Curves.easeOut),
      ),
    );

    // Horizontal: gentle S-curve drift left then right
    _floatX =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0, end: -10),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -10, end: 6),
            weight: 35,
          ),
          TweenSequenceItem(tween: Tween<double>(begin: 6, end: 0), weight: 25),
        ]).animate(
          CurvedAnimation(
            parent: _floatController,
            curve: const Interval(0.0, 0.72, curve: Curves.easeInOut),
          ),
        );

    // Slight rotation while floating: drifts from -0.3 to 0 rad
    _floatRotate = Tween<double>(begin: -0.35, end: 0.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.0, 0.72, curve: Curves.easeOut),
      ),
    );

    // Fade in quickly at start of float
    _floatOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
      ),
    );

    // When float reaches anchor (72%), fire the growth bounce
    _floatController.addListener(() {
      if (_floatController.value >= 0.72 &&
          _leafController.status == AnimationStatus.dismissed) {
        _leafController.forward(from: 0);
      }
    });

    _floatController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          // Animation done — newest leaf now behaves like all others
          _previousLeafCount = _visibleLeafCount;
        });
      }
    });

    // ── Wind ─────────────────────────────────────────────────────
    _windController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // ── Initial state ─────────────────────────────────────────────
    // ── Initial state ─────────────────────────────────────
    _visibleLeafCount = _getLeafCount(widget.entryCount);
    _previousLeafCount = _visibleLeafCount;
    _leafController.value = 1.0;
    _floatController.value = 1.0; // ← add this
  }

  @override
  void didUpdateWidget(covariant GrowingMemoryTree oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newCount = _getLeafCount(widget.entryCount);
    debugPrint(
      'TREE UPDATE: newCount=$newCount _previousLeafCount=$_previousLeafCount _visibleLeafCount=$_visibleLeafCount',
    );

    if (newCount > _previousLeafCount) {
      // Only animate if this is a single new leaf being added live
      // not a bulk load from stream
      final isLiveAdd = newCount == _previousLeafCount + 1;
      setState(() => _visibleLeafCount = newCount);
      if (!isLiveAdd || !widget.animateNewLeaves) {
        _leafController.value = 1.0;
        _floatController.value = 1.0;
        _previousLeafCount = newCount;
        return;
      }

      final isHomeRoute =
          Get.currentRoute == AppRoutes.home ||
          Get.currentRoute == AppRoutes.main;

      if (isHomeRoute && Get.isRegistered<SoundEffectsController>()) {
        Get.find<SoundEffectsController>().playLeafAppear();
      }

      // Reset both controllers and start the float sequence
      _leafController.reset();
      _floatController.forward(from: 0);
    } else if (newCount != _previousLeafCount) {
      setState(() => _visibleLeafCount = newCount);
    }

    _previousLeafCount = newCount;
  }

  int _getLeafCount(int entryCount) {
    final maximum = widget.maxLeaves.clamp(0, treeLeafAnchors.length);
    return entryCount.clamp(0, maximum);
  }

  @override
  void dispose() {
    _leafController.dispose();
    _floatController.dispose();
    _windController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double treeAspectRatio = 1278 / 1230;
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.height! * treeAspectRatio;

        double treeWidth;
        double treeHeight;

        if (widget.height != null) {
          treeHeight = widget.height!;
          treeWidth = treeHeight * treeAspectRatio;
          if (treeWidth > availableWidth) {
            treeWidth = availableWidth;
            treeHeight = treeWidth / treeAspectRatio;
          }
        } else {
          treeWidth = availableWidth;
          treeHeight = treeWidth / treeAspectRatio;
        }

        return Center(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.enableLeafTap ? null : widget.onTreeTap,
            child: SizedBox(
              width: treeWidth,
              height: treeHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/tree.png',
                      width: treeWidth,
                      height: treeHeight,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  ..._buildLiveLeaves(
                    treeWidth: treeWidth,
                    treeHeight: treeHeight,
                  ),

                  // Dead/yellow leaves at deleted anchor positions
                  ...widget.deletedAnchorIndices.map(
                    (anchorIndex) => _buildDeadLeaf(
                      anchorIndex: anchorIndex,
                      treeWidth: treeWidth,
                      treeHeight: treeHeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaf({
    required int index,
    required int memoryIndex,
    required double treeWidth,
    required double treeHeight,
  }) {
    final anchor = treeLeafAnchors[index];

    final leafWidth = treeWidth * 0.042;
    final leafHeight = leafWidth * 1.5;

    final anchorX = anchor.x * treeWidth;
    final anchorY = anchor.y * treeHeight;

    final left = anchorX - leafWidth * 0.5;
    final top = anchorY - leafHeight * 0.90;

    final isNewest =
        memoryIndex == _visibleLeafCount - 1 &&
        _floatController.status != AnimationStatus.completed;

    // ── Base leaf image with tight gesture detector ───────────────
    Widget leaf = GestureDetector(
      behavior: widget.enableLeafTap
          ? HitTestBehavior.translucent
          : HitTestBehavior.deferToChild,
      onTap: widget.enableLeafTap
          ? () {
              debugPrint(
                'LEAF $index  x=${anchor.x}  y=${anchor.y}  r=${anchor.rotation}',
              );
              debugPrint(
                'enableLeafTap=${widget.enableLeafTap} onLeafTap=${widget.onLeafTap}',
              );
              widget.onLeafTap?.call(memoryIndex);
            }
          : null,
      child: Image.asset(
        'assets/images/leaf1.png',
        width: leafWidth,
        height: leafHeight,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );

    if (isNewest) {
      // ── Newest leaf: float up → bounce settle ─────────────────
      leaf = AnimatedBuilder(
        animation: Listenable.merge([_floatController, _leafController]),
        child: leaf,
        builder: (context, child) {
          final isFloating = _floatController.value < 0.72;

          if (isFloating) {
            return Opacity(
              opacity: _floatOpacity.value,
              child: Transform.translate(
                offset: Offset(_floatX.value, _floatY.value),
                child: Transform.rotate(
                  angle: anchor.rotation + _floatRotate.value,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            );
          } else {
            final time = _windController.value * math.pi * 2;
            final phase = index * 0.55;
            final primarySway = math.sin(time + phase) * 0.095;
            final secondarySway =
                math.sin((time * 1.7) + (phase * 0.7)) * 0.018;
            final sway = primarySway + secondarySway;

            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                alignment: Alignment.bottomCenter,
                child: Transform.rotate(
                  angle: anchor.rotation + sway,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            );
          }
        },
      );
    } else {
      // ── All other leaves: just wind sway ─────────────────────
      leaf = AnimatedBuilder(
        animation: _windController,
        child: leaf,
        builder: (context, child) {
          final time = _windController.value * math.pi * 2;
          final phase = index * 0.55;
          final primarySway = math.sin(time + phase) * 0.095;
          final secondarySway = math.sin((time * 1.7) + (phase * 0.7)) * 0.018;
          final sway = primarySway + secondarySway;

          return Transform.rotate(
            angle: anchor.rotation + sway,
            alignment: Alignment.bottomCenter,
            child: child,
          );
        },
      );
    }

    return Positioned(
      left: left,
      top: top,
      width: leafWidth,
      height: leafHeight,
      child: leaf,
    );
  }

  Widget _buildDeadLeaf({
    required int anchorIndex,
    required double treeWidth,
    required double treeHeight,
  }) {
    if (anchorIndex >= treeLeafAnchors.length) return const SizedBox.shrink();
    print('BUILDING DEAD LEAF at anchor $anchorIndex');
    final anchor = treeLeafAnchors[anchorIndex];

    final leafWidth = treeWidth * 0.042;
    final leafHeight = leafWidth * 1.5;

    final anchorX = anchor.x * treeWidth;
    final anchorY = anchor.y * treeHeight;

    final left = anchorX - leafWidth * 0.5;
    final top = anchorY - leafHeight * 0.90;

    return Positioned(
      left: left,
      top: top,
      width: leafWidth,
      height: leafHeight,
      child: _DeadLeafWidget(
        key: ValueKey('dead_leaf_$anchorIndex'),
        anchor: anchor,
        leafWidth: leafWidth,
        leafHeight: leafHeight,
        shouldFall: widget.fallTriggerIndex == anchorIndex,
        onFallComplete: () => widget.onDeadLeafFallComplete?.call(anchorIndex),
      ),
    );
  }

  List<Widget> _buildLiveLeaves({
    required double treeWidth,
    required double treeHeight,
  }) {
    final widgets = <Widget>[];
    int liveCount = 0;
    int anchorIndex = 0;

    while (liveCount < _visibleLeafCount &&
        anchorIndex < treeLeafAnchors.length) {
      if (widget.skippedAnchorIndices.contains(anchorIndex)) {
        anchorIndex++;
        continue;
      }

      final memoryIndex = liveCount; // ← actual position in treeMemories
      widgets.add(
        _buildLeaf(
          index: anchorIndex,
          memoryIndex: memoryIndex,
          treeWidth: treeWidth,
          treeHeight: treeHeight,
        ),
      );

      liveCount++;
      anchorIndex++;
    }

    return widgets;
  }
}

class _DeadLeafWidget extends StatefulWidget {
  const _DeadLeafWidget({
    super.key,
    required this.anchor,
    required this.leafWidth,
    required this.leafHeight,
    required this.shouldFall,
    required this.onFallComplete,
  });

  final TreeLeafAnchor anchor;
  final bool shouldFall;
  final double leafWidth;
  final double leafHeight;
  final VoidCallback onFallComplete;

  @override
  State<_DeadLeafWidget> createState() => _DeadLeafWidgetState();
}

class _DeadLeafWidgetState extends State<_DeadLeafWidget>
    with TickerProviderStateMixin {
  late final AnimationController _fallController;
  late final Animation<double> _fallY;
  late final Animation<double> _fallOpacity;
  late final Animation<double> _fallRotation;
  late final AnimationController _windController;

  bool _falling = false;
  @override
  void didUpdateWidget(covariant _DeadLeafWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldFall && !oldWidget.shouldFall) {
      _startFall();
    }
  }

  @override
  void initState() {
    super.initState();

    _fallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fallY = Tween<double>(
      begin: 0,
      end: 300,
    ).animate(CurvedAnimation(parent: _fallController, curve: Curves.easeIn));

    _fallOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _fallController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _fallRotation = Tween<double>(begin: 0, end: 1.5).animate(
      CurvedAnimation(parent: _fallController, curve: Curves.easeInOut),
    );

    _fallController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFallComplete();
      }
    });

    _windController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _fallController.dispose();
    _windController.dispose();
    super.dispose();
  }

  void _startFall() {
    if (_falling || _fallController.status == AnimationStatus.completed) return;
    setState(() => _falling = true);
    _fallController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        _startFall();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_fallController, _windController]),
        builder: (context, child) {
          final time = _windController.value * math.pi * 2;
          final phase = widget.anchor.rotation * 10;
          final primarySway = math.sin(time + phase) * 0.095;
          final secondarySway = math.sin((time * 1.7) + (phase * 0.7)) * 0.018;
          final sway = primarySway + secondarySway;

          if (_falling) {
            return Opacity(
              opacity: _fallOpacity.value,
              child: Transform.translate(
                offset: Offset(0, _fallY.value),
                child: Transform.rotate(
                  angle: widget.anchor.rotation + _fallRotation.value,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            );
          }

          return Transform.rotate(
            angle: widget.anchor.rotation + sway,
            alignment: Alignment.bottomCenter,
            child: child,
          );
        },
        child: Image.asset(
          'assets/images/dead_leaf.png',
          width: widget.leafWidth,
          height: widget.leafHeight,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
