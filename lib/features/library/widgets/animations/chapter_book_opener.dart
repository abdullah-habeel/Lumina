import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';

Future<void> openChapterBook({
  required BuildContext context,
  required GlobalKey cardKey,
  required Widget card,
  required Widget cover,
}) {
  return Navigator.of(
    context,
  ).push(_BookOpenRoute(cardKey: cardKey, card: card, cover: cover));
}

class _BookOpenRoute extends PageRoute<void> {
  final GlobalKey cardKey;
  final Widget card;
  final Widget cover;

  _BookOpenRoute({
    required this.cardKey,
    required this.card,
    required this.cover,
  });

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  bool get maintainState => true;

  @override
  String? get barrierLabel => 'Open book';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 1400);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 700);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final box = cardKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(40, 200, 320, 126);

    return _BookOpenPlay(
      animation: animation,
      origin: origin,
      card: RepaintBoundary(child: card),
      cover: RepaintBoundary(child: cover),
      onComplete: () => Navigator.of(context).pop(),
    );
  }
}

class _BookOpenPlay extends StatefulWidget {
  final Animation<double> animation;
  final Rect origin;
  final Widget card;
  final Widget cover;
  final VoidCallback onComplete;

  const _BookOpenPlay({
    required this.animation,
    required this.origin,
    required this.card,
    required this.cover,
    required this.onComplete,
  });

  @override
  State<_BookOpenPlay> createState() => _BookOpenPlayState();
}

class _BookOpenPlayState extends State<_BookOpenPlay> {
  late final Widget _cachedCard;
  late final Widget _cachedCover;

  @override
  void initState() {
    super.initState();
    _cachedCard = Material(type: MaterialType.transparency, child: widget.card);
    _cachedCover = Material(
      type: MaterialType.transparency,
      child: widget.cover,
    );

    widget.animation.addStatusListener(_handleStatusChange);
  }

  void _handleStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_handleStatusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const bookW = 260.0;
    const bookH = 380.0;
    const pageStackW = 10.0;

    final bookRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: bookW,
      height: bookH,
    );

    final lift = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0.00, 0.20, curve: Curves.easeOut),
    );
    final tiltIn = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0.10, 0.55, curve: Curves.easeInOut),
    );
    final tiltOut = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0.55, 0.92, curve: Curves.easeInOut),
    );
    final settle = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0.92, 1.00, curve: Curves.elasticOut),
    );
    final blurAnim = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0.10, 0.50, curve: Curves.easeOut),
    );
    final switchAnim = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0.45, 0.65, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) {
        final t = widget.animation.value;
        final blurVal = blurAnim.value * 8.0;
        final isPhase1 = t < 0.55;

        final liftedOrigin = Rect.fromLTWH(
          widget.origin.left,
          widget.origin.top - lift.value * 20,
          widget.origin.width,
          widget.origin.height,
        );

        final currentRect = Rect.lerp(
          liftedOrigin,
          bookRect,
          Curves.easeInOut.transform(tiltIn.value),
        )!;

        final settleScale = 1.0 + settle.value * 0.012;

        // tilt angles
        double yAngle;
        double xAngle;

        if (isPhase1) {
          yAngle = -tiltIn.value * 0.55;
          xAngle = tiltIn.value * 0.10;
        } else {
          yAngle = -(1.0 - tiltOut.value) * 0.55;
          xAngle = (1.0 - tiltOut.value) * 0.10;
        }

        final edgeVisibility = isPhase1 ? tiltIn.value : (1.0 - tiltOut.value);

        // Both visible during crossfade — no hard cut
        final cardOpacity = (1.0 - switchAnim.value).clamp(0.0, 1.0);
        final coverOpacity = switchAnim.value.clamp(0.0, 1.0);

        // Render BOTH layers always, opacity handles visibility
        final faceShadow = (edgeVisibility * 0.35).clamp(0.0, 1.0);

        final Matrix4 matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateX(xAngle)
          ..rotateY(yAngle);

        return Stack(
          children: [
            // ── BLURRED BACKGROUND ──────────────────────────
            Positioned.fill(
              child: RepaintBoundary(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurVal, sigmaY: blurVal),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      color: Colors.black.withOpacity(
                        (0.22 * blurAnim.value).clamp(0.0, 1.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── FLOOR SHADOW ────────────────────────────────
            Positioned(
              left: currentRect.left + currentRect.width * 0.08,
              top: currentRect.bottom - 6,
              width: currentRect.width * 0.84,
              height: 30,
              child: IgnorePointer(
                child: Opacity(
                  opacity: (lift.value * 0.7).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 28,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 3D BOOK OBJECT ───────────────────────────────
            Positioned(
              left: currentRect.left,
              top: currentRect.top,
              width: currentRect.width,
              height: currentRect.height,
              child: Transform.scale(
                scale: settleScale,
                child: Transform(
                  alignment: Alignment.center,
                  transform: matrix,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── PAGE STACK (right edge) ───────────
                      Positioned(
                        right: -pageStackW * edgeVisibility,
                        top: 2,
                        bottom: 2,
                        width: pageStackW,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: edgeVisibility.clamp(0.0, 1.0),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(3),
                              ),
                              child: CustomPaint(painter: _PageStackPainter()),
                            ),
                          ),
                        ),
                      ),

                      // ── CARD (phase 1) ────────────────────
                      Positioned.fill(
                        child: Opacity(
                          opacity: cardOpacity,
                          child: RepaintBoundary(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Positioned.fill(child: _cachedCard),
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Container(
                                        color: Colors.black.withOpacity(
                                          faceShadow,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── COVER (phase 2) ───────────────────
                      Positioned.fill(
                        child: Opacity(
                          opacity: coverOpacity,
                          child: RepaintBoundary(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Positioned.fill(child: _cachedCover),
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Container(
                                        color: Colors.black.withOpacity(
                                          faceShadow,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // rim light on left edge
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: const DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.center,
                                            colors: [
                                              Color(0x22FFFFFF),
                                              Colors.transparent,
                                            ],
                                            stops: [0.0, 0.10],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // top sheen
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    right: 0,
                                    height: bookH * 0.25,
                                    child: IgnorePointer(
                                      child: const DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0x18FFFFFF),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // right edge shadow
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    width: 10,
                                    bottom: 0,
                                    child: IgnorePointer(
                                      child: const DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.transparent,
                                              Color(0x40000000),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── PAGE STACK PAINTER ───────────────────────────────────────────
class _PageStackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // base cream
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFD4C4A0),
    );

    // horizontal page lines
    final linePaint = Paint()
      ..color = const Color(0xFFCFB899)
      ..strokeWidth = 0.8;

    for (double y = 0; y < size.height; y += 1.4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // left shadow (where pages meet cover)
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.black.withOpacity(0.25), Colors.transparent],
        ).createShader(Offset.zero & size),
    );

    // right edge shadow
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Colors.black.withOpacity(0.15), Colors.transparent],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
