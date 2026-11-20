import 'package:flutter/material.dart';

class ChapterBook extends StatefulWidget {
  final String image;
  final VoidCallback onTap;
  final double? width;

  final int delay;

  /// Floating animation duration
  final int floatDuration;

  /// Floating distance
  final double floatOffset;

  /// Horizontal shift
  final double horizontalOffset;

  /// Shadow blur
  final double shadowBlur;

  const ChapterBook({
    super.key,
    required this.image,
    required this.onTap,
    this.width,
    this.delay = 0,
    this.floatDuration = 4000,
    this.floatOffset = 3,
    this.horizontalOffset = 0,
    this.shadowBlur = 18,
  });

  @override
  State<ChapterBook> createState() => _ChapterBookState();
}

class _ChapterBookState extends State<ChapterBook>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatingController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _floatingAnimation;

  double _scale = 1.0;

  @override
  void initState() {
    super.initState();

    //-------------------------
    // Entrance Animation
    //-------------------------

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, .15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    //-------------------------
    // Floating Animation
    //-------------------------

    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.floatDuration),
    );

    _floatingAnimation =
        Tween<double>(
          begin: -widget.floatOffset,
          end: widget.floatOffset,
        ).animate(
          CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
        );

    //-------------------------
    // Start Animations
    //-------------------------

    Future.delayed(Duration(milliseconds: widget.delay), () async {
      if (!mounted) return;

      await _entranceController.forward();

      if (!mounted) return;

      // Same starting phase for every book so they float together
      // as one unit — spacing between books stays constant.
      _floatingController.value = 0;

      _floatingController.repeat(reverse: true);
    });
  }

  Future<void> _onPressed() async {
    setState(() => _scale = .96);

    await Future.delayed(const Duration(milliseconds: 90));

    if (!mounted) return;

    setState(() => _scale = 1);

    await Future.delayed(const Duration(milliseconds: 70));

    widget.onTap();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use 92% of available width, capped so it doesn't get huge on tablets
        final effectiveWidth =
            widget.width ?? (constraints.maxWidth * 0.92).clamp(0.0, 380.0);
        return AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatingAnimation.value),
              child: child,
            );
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                scale: _scale,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _onPressed,
                  child: Transform.translate(
                    offset: Offset(widget.horizontalOffset, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.10),
                            blurRadius: widget.shadowBlur,
                            spreadRadius: 1,
                            offset: Offset(
                              0,
                              8 + (_floatingAnimation.value.abs() * 0.6),
                            ),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        widget.image,
                        width: effectiveWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
