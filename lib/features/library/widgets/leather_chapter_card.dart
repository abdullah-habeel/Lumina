import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';

class LeatherChapterCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Color leatherColor;
  final String leafAsset;
  final String illustrationAsset;
  final VoidCallback onTap;

  const LeatherChapterCard({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.leatherColor,
    required this.leafAsset,
    required this.illustrationAsset,
    required this.onTap,
  });

  // ==============================================================
  // CARD SETTINGS
  // ==============================================================

  static const double _cardHeight = 126;
  static const double _radius = 22;

  // Reverse-C / outward tab size.
  static const double _tabRadius = 11;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final spineWidth = width * 0.205;

        final illustrationWidth = width * 0.40;

        final numberSize = width < 340 ? 25.0 : 30.0;

        return _PressScaleWrapper(
          onTap: onTap,
          child: Container(
            height: _cardHeight,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),

              // --------------------------------------------------
              // CARD SHADOW
              // --------------------------------------------------
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  spreadRadius: -4,
                  offset: const Offset(0, 9),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(_radius),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // =================================================
                  // 1. PAPER
                  // =================================================
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFFBF1),
                            Color(0xFFFAF1DF),
                            Color(0xFFF6EBD6),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFE1CFB1),
                          width: 1,
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // 2. SOFT PAPER LIGHT
                  // =================================================
                  Positioned(
                    left: spineWidth,
                    top: 0,
                    right: 0,
                    height: 45,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFFFFFFF).withOpacity(0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // 3. RIGHT ILLUSTRATION
                  //
                  // BACKGROUND
                  // =================================================
                  Positioned(
                    right: -10,
                    top: -5,
                    bottom: -5,
                    width: illustrationWidth,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.25,
                        child: Image.asset(
                          illustrationAsset,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // 4. PAPER TEXTURE
                  // =================================================

                  // Positioned.fill(
                  //   child: IgnorePointer(
                  //     child: CustomPaint(
                  //       painter: _PaperTexturePainter(),
                  //     ),
                  //   ),
                  // ),

                  // =================================================
                  // 5. LEATHER SPINE
                  // =================================================
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: spineWidth + _tabRadius,
                    child: ClipPath(
                      clipper: _SpineClipper(
                        spineWidth: spineWidth,
                        tabRadius: _tabRadius,
                      ),
                      child: _LeatherSpine(
                        color: leatherColor,
                        leafAsset: leafAsset,
                      ),
                    ),
                  ),

                  // =================================================
                  // 6. CURVED SPINE EDGE
                  //
                  // Follows the same reverse-C path as the leather
                  // clip itself, so the highlight bulges outward
                  // with the tab instead of cutting straight
                  // through it.
                  // =================================================
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _SpineEdgeHighlightPainter(
                          spineWidth: spineWidth,
                          tabRadius: _tabRadius,
                          color: _darken(leatherColor, 0.16).withOpacity(0.55),
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // 7. NUMBER
                  // =================================================
                  Positioned(
                    left: spineWidth + 15,
                    top: 0,
                    bottom: 0,
                    width: 35,
                    child: Center(
                      child: Text(
                        number,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: numberSize,
                          height: 1,
                          fontWeight: FontWeight.w500,
                          color: _darken(leatherColor, 0.06),
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // 8. GOLDEN DIVIDER
                  // =================================================
                  Positioned(
                    left: spineWidth + 60,
                    top: 27,
                    bottom: 27,
                    child: Container(
                      width: 1,
                      decoration: BoxDecoration(
                        color: _goldForLeather(leatherColor).withOpacity(0.58),
                      ),
                    ),
                  ),

                  // =================================================
                  // 9. CHAPTER LABEL + TITLE + SUBTITLE
                  // =================================================
                  Positioned(
                    left: spineWidth + 85,
                    top: 25,
                    right: 46,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // -----------------------------------------
                        // CHAPTER LABEL
                        // -----------------------------------------
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 1,
                              color: _goldForLeather(
                                leatherColor,
                              ).withOpacity(0.55),
                            ),

                            const SizedBox(width: 7),

                            Text(
                              'CHAPTER',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.7,
                                color: _darken(
                                  leatherColor,
                                  0.05,
                                ).withOpacity(0.78),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // -----------------------------------------
                        // TITLE
                        // -----------------------------------------
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 18,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF28241D),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // -----------------------------------------
                        // SUBTITLE
                        // -----------------------------------------
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            height: 1.12,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF6C604F),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // 10. ARROW
                  // =================================================
                  Positioned(
                    right: 11,
                    top: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 25,

                      color: AppColors.textPrimary.withOpacity(0.4),
                    ),
                  ),

                  // =================================================
                  // 11. PAPER TOP EDGE
                  // =================================================
                  Positioned(
                    left: spineWidth,
                    right: 0,
                    top: 0,
                    height: 1,
                    child: Container(
                      color: const Color(0xFFFFFEF8).withOpacity(0.75),
                    ),
                  ),

                  // =================================================
                  // 12. PAPER BOTTOM EDGE
                  // =================================================
                  Positioned(
                    left: spineWidth,
                    right: 0,
                    bottom: 0,
                    height: 1,
                    child: Container(
                      color: const Color(0xFFD5C19F).withOpacity(0.55),
                    ),
                  ),

                  // =================================================
                  // 13. PAPER INNER BORDER
                  // =================================================
                  Positioned(
                    left: spineWidth + 1,
                    right: 2,
                    top: 2,
                    bottom: 2,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(_radius - 2),
                            bottomRight: Radius.circular(_radius - 2),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFFE8DCC6).withOpacity(0.70),
                              width: 1,
                            ),
                            right: BorderSide(
                              color: const Color(0xFFE8DCC6).withOpacity(0.70),
                              width: 1,
                            ),
                            bottom: BorderSide(
                              color: const Color(0xFFE8DCC6).withOpacity(0.70),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
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
}

// ============================================================================
// LEATHER SPINE
// ============================================================================

class _LeatherSpine extends StatelessWidget {
  final Color color;
  final String leafAsset;

  const _LeatherSpine({required this.color, required this.leafAsset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ==========================================================
        // LEATHER GRADIENT
        // ==========================================================
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_lighten(color, 0.10), color, _darken(color, 0.10)],
              ),
            ),
          ),
        ),

        // ==========================================================
        // LEATHER TEXTURE
        // ==========================================================
        Positioned.fill(
          child: CustomPaint(
            painter: _LeatherTexturePainter(seed: color.value),
          ),
        ),

        // ==========================================================
        // SUBTLE INNER FRAME
        //
        // IMPORTANT:
        // This is now drawn using a custom painter that follows
        // the reverse-C shape.
        //
        // No straight line crosses the tab.
        // ==========================================================
        Positioned.fill(
          child: CustomPaint(
            painter: _SpineBorderPainter(
              color: _lighten(color, 0.16).withOpacity(0.30),
              tabRadius: 11,
            ),
          ),
        ),

        // ==========================================================
        // DECORATIVE LEAF
        // ==========================================================
        Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: Image.asset(leafAsset, fit: BoxFit.contain),
          ),
        ),

        // ==========================================================
        // SUBTLE LEFT EDGE
        // ==========================================================
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 1,
          child: Container(color: _lighten(color, 0.18).withOpacity(0.25)),
        ),
      ],
    );
  }
}

// ============================================================================
// REVERSE-C / OUTWARD TAB
// ============================================================================

class _SpineClipper extends CustomClipper<Path> {
  final double spineWidth;
  final double tabRadius;

  const _SpineClipper({required this.spineWidth, required this.tabRadius});

  @override
  Path getClip(Size size) {
    final path = Path();

    final centerY = size.height / 2;

    final topOfTab = centerY - tabRadius;

    final bottomOfTab = centerY + tabRadius;

    // ------------------------------------------------------------
    // TOP
    // ------------------------------------------------------------

    path.moveTo(0, 0);

    path.lineTo(spineWidth, 0);

    // ------------------------------------------------------------
    // DOWN TO TAB
    // ------------------------------------------------------------

    path.lineTo(spineWidth, topOfTab);

    // ------------------------------------------------------------
    // OUTWARD CURVE
    //
    // The leather comes INTO the paper.
    // ------------------------------------------------------------

    path.cubicTo(
      spineWidth + tabRadius,
      topOfTab,

      spineWidth + tabRadius,
      bottomOfTab,

      spineWidth,
      bottomOfTab,
    );

    // ------------------------------------------------------------
    // DOWN
    // ------------------------------------------------------------

    path.lineTo(spineWidth, size.height);

    // ------------------------------------------------------------
    // BOTTOM
    // ------------------------------------------------------------

    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _SpineClipper oldClipper) {
    return oldClipper.spineWidth != spineWidth ||
        oldClipper.tabRadius != tabRadius;
  }
}

// ============================================================================
// CURVED SPINE BORDER
//
// This replaces the old rectangular Border.all.
//
// Therefore it follows the shape of the leather and does NOT create
// the unwanted straight white line through the reverse-C.
// ============================================================================

class _SpineBorderPainter extends CustomPainter {
  final Color color;
  final double tabRadius;

  const _SpineBorderPainter({required this.color, required this.tabRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const padding = 7.0;

    final right = size.width - padding;

    final centerY = size.height / 2;

    final topOfTab = centerY - tabRadius;

    final bottomOfTab = centerY + tabRadius;

    final path = Path();

    // ------------------------------------------------------------
    // TOP
    // ---------------------------------------F---------------------

    path.moveTo(padding, padding);

    path.lineTo(right, padding);

    // ------------------------------------------------------------
    // DOWN TO TAB
    // ------------------------------------------------------------

    path.lineTo(right, topOfTab);

    // ------------------------------------------------------------
    // CURVED TAB
    // ------------------------------------------------------------

    path.cubicTo(
      right + tabRadius,
      topOfTab,

      right + tabRadius,
      bottomOfTab,

      right,
      bottomOfTab,
    );

    // ------------------------------------------------------------
    // CONTINUE DOWN
    // ------------------------------------------------------------

    path.lineTo(right, size.height - padding);

    // ------------------------------------------------------------
    // BOTTOM
    // ------------------------------------------------------------

    path.lineTo(padding, size.height - padding);

    // ------------------------------------------------------------
    // LEFT SIDE
    // ------------------------------------------------------------

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SpineBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.tabRadius != tabRadius;
  }
}

// ============================================================================
// CURVED SPINE EDGE HIGHLIGHT
//
// Traces the SAME reverse-C path as _SpineClipper (not a straight
// vertical rectangle), so the highlight bulges outward with the
// leather's tab instead of cutting a straight line through the curve.
// ============================================================================

class _SpineEdgeHighlightPainter extends CustomPainter {
  final double spineWidth;
  final double tabRadius;
  final Color color;

  const _SpineEdgeHighlightPainter({
    required this.spineWidth,
    required this.tabRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    final topOfTab = centerY - tabRadius;
    final bottomOfTab = centerY + tabRadius;

    final path = Path()
      ..moveTo(spineWidth, 0)
      ..lineTo(spineWidth, topOfTab)
      ..cubicTo(
        spineWidth + tabRadius,
        topOfTab,
        spineWidth + tabRadius,
        bottomOfTab,
        spineWidth,
        bottomOfTab,
      )
      ..lineTo(spineWidth, size.height);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SpineEdgeHighlightPainter oldDelegate) {
    return oldDelegate.spineWidth != spineWidth ||
        oldDelegate.tabRadius != tabRadius ||
        oldDelegate.color != color;
  }
}

// ============================================================================
// LEATHER TEXTURE
// ============================================================================

class _LeatherTexturePainter extends CustomPainter {
  final int seed;

  const _LeatherTexturePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);

    final darkPaint = Paint()..color = Colors.black.withOpacity(0.045);

    final lightPaint = Paint()..color = Colors.white.withOpacity(0.025);

    final count = (size.width * size.height / 7).round();

    for (int i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;

      final dy = random.nextDouble() * size.height;

      final radius = random.nextDouble() * 0.65 + 0.2;

      canvas.drawCircle(
        Offset(dx, dy),
        radius,
        random.nextBool() ? darkPaint : lightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LeatherTexturePainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

// ============================================================================
// PAPER TEXTURE
// ============================================================================

class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(9182);

    final paint = Paint()..color = const Color(0xFF8D806B).withOpacity(0.022);

    final count = (size.width * size.height / 32).round();

    for (int i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;

      final dy = random.nextDouble() * size.height;

      canvas.drawCircle(Offset(dx, dy), random.nextDouble() * 0.55, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperTexturePainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// COLOR HELPERS
// ============================================================================

Color _lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);

  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);

  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

// ============================================================================
// GOLD ACCENT BASED ON LEATHER COLOR
// ============================================================================

Color _goldForLeather(Color leather) {
  return Color.lerp(leather, const Color(0xFFC49A55), 0.65)!;
}

class _PressScaleWrapper extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _PressScaleWrapper({required this.onTap, required this.child});

  @override
  State<_PressScaleWrapper> createState() => _PressScaleWrapperState();
}

class _PressScaleWrapperState extends State<_PressScaleWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.965,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
