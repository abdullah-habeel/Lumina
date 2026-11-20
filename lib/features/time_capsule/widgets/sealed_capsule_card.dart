import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/time_capsule/model/time_capsule_model.dart';
import 'package:lumina/features/time_capsule/widgets/lock_interaction.dart';
import 'package:lumina/features/time_capsule/widgets/open_button_interaction.dart';

class SealedCapsuleCard extends StatefulWidget {
  final TimeCapsuleModel capsule;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;
  final VoidCallback onPressDown;
  final VoidCallback onPressUp;

  const SealedCapsuleCard({
    super.key,
    required this.capsule,
    required this.onTap,
    required this.onMoreTap,
    required this.onPressDown,
    required this.onPressUp,
  });

  @override
  State<SealedCapsuleCard> createState() => _SealedCapsuleCardState();
}

class _SealedCapsuleCardState extends State<SealedCapsuleCard>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // SHIMMER ONLY
  // ============================================================

  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  Timer? _shimmerTimer;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Occasional subtle shimmer.
    _shimmerTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;

      _shimmerController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _shimmerTimer?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlockDate = DateFormat(
      'd MMM yyyy',
    ).format(widget.capsule.unlockDate);

    // ============================================================
    // TIME-BASED COLORS
    // ============================================================

    final hour = DaylightTime.of(context);
    final cardBg = DaylightAppColors.cardBackground(hour);
    final border = DaylightAppColors.borderGold(hour);
    final accent = DaylightAppColors.accentGold(hour);
    final textColor = DaylightAppColors.cardText(hour);
    final subtext = DaylightAppColors.cardSubtext(hour);
    final shadowColor = DaylightAppColors.shadow(hour);

    final spineColor = Color.lerp(const Color(0xFF30432E), textColor, 0.25)!;
    final tileBg = Color.lerp(cardBg, accent, 0.12)!;
    final tileBorder = accent.withOpacity(0.35);
    final divider = border.withOpacity(0.6);
    const statusGreen = Color(0xFF617552);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => widget.onPressDown(),
      onTapUp: (_) => widget.onPressUp(),
      onTapCancel: () => widget.onPressUp(),
      child: Padding(
        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 20),
        child: Container(
          // No color and no border here: they caused the white line
          // around the green spine.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==========================================================
                // BOOK SPINE
                // ==========================================================
                SizedBox(
                  width: 92,
                  child: CustomPaint(
                    painter: BookSpinePainter(
                      spineColor: spineColor,
                      edgeColor: border,
                      paperColor: cardBg,
                    ),
                    child: SizedBox(
                      width: 82,
                      child: Column(
                        children: [
                          const SizedBox(height: 28),

                          // ==================================================
                          // LOCK
                          // ==================================================
                          LockInteraction(
                            isUnlocked: widget.capsule.isUnlocked,
                            borderColor: border,
                            glowColor: accent,
                          ),

                          const Spacer(),

                          // ==================================================
                          // LEAF
                          // ==================================================
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Image.asset(
                              AppImages.questionflower,
                              height: 100,
                              color: Color.lerp(border, Colors.white, 0.15),
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ),

                          // ==================================================
                          // SEALED LABEL
                          // ==================================================
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              'SEALED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.2,
                                color: Color.lerp(accent, Colors.white, 0.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ==========================================================
                // PAPER CONTENT
                // ==========================================================
                Expanded(
                  child: Container(
                    color: cardBg,
                    padding: const EdgeInsets.fromLTRB(22, 20, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // HEADER
                        // ==================================================
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // =================================================
                            // SHIMMER
                            // =================================================
                            AnimatedBuilder(
                              animation: _shimmerAnimation,
                              builder: (context, child) {
                                return ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    final shimmer = _shimmerAnimation.value;

                                    final shimmerCenter = 0.5 + (shimmer * 0.5);

                                    final highlight = Color.lerp(
                                      accent,
                                      Colors.white,
                                      0.45,
                                    )!;

                                    return LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        accent,
                                        accent,
                                        highlight,
                                        accent,
                                        accent,
                                      ],
                                      stops: [
                                        0.0,
                                        (shimmerCenter - 0.25).clamp(0.0, 1.0),
                                        shimmerCenter.clamp(0.0, 1.0),
                                        (shimmerCenter + 0.25).clamp(0.0, 1.0),
                                        1.0,
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: const Text(
                                    '✦  TIME CAPSULE  ✦',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.6,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const Spacer(),

                            // ==================================================
                            // MORE
                            // ==================================================
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: widget.onMoreTap,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.more_vert,
                                  size: 20,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 13),

                        // ==================================================
                        // TITLE
                        // ==================================================
                        Text(
                          widget.capsule.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            height: 1.18,
                            letterSpacing: -0.2,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // DECORATIVE DIVIDER
                        // ==================================================
                        Row(
                          children: [
                            Expanded(
                              child: Container(height: 1, color: divider),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Icon(
                                Icons.eco_outlined,
                                size: 17,
                                color: accent,
                              ),
                            ),
                            Expanded(
                              child: Container(height: 1, color: divider),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // UNLOCK DATE
                        // ==================================================
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: tileBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: tileBorder),
                              ),
                              child: Icon(
                                Icons.calendar_month_outlined,
                                size: 23,
                                color: subtext,
                              ),
                            ),

                            const SizedBox(width: 13),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unlocks on',
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 13,
                                    color: subtext,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  unlockDate,
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // STATUS
                        // ==================================================
                        OpenButtonInteraction(
                          isUnlocked: widget.capsule.isUnlocked,
                          label: widget.capsule.isUnlocked
                              ? 'Ready to open'
                              : '${widget.capsule.daysLeft} days left',
                          tileBg: tileBg,
                          tileBorder: tileBorder,
                          textColor: textColor,
                          accentColor: accent,
                          statusGreen: statusGreen,
                          onTap: widget.onTap,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BOOK SPINE PAINTER
// ============================================================================

class BookSpinePainter extends CustomPainter {
  final Color spineColor;
  final Color edgeColor;
  final Color paperColor;

  const BookSpinePainter({
    required this.spineColor,
    required this.edgeColor,
    required this.paperColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = spineColor
      ..style = PaintingStyle.fill;

    final goldPaint = Paint()
      ..color = edgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final paperPaint = Paint()
      ..color = paperColor
      ..style = PaintingStyle.fill;

    const double spineWidth = 82;

    final double curveCenter = size.height * 0.45;

    const double curveHeight = 28;
    const double curveDepth = 9;

    // ============================================================
    // PAPER BEHIND THE NOTCH
    // Overlaps 1px under the spine so no gap can show.
    // ============================================================

    canvas.drawRect(
      Rect.fromLTRB(spineWidth - 1, 0, size.width, size.height),
      paperPaint,
    );

    // ============================================================
    // GREEN SPINE
    // ============================================================

    final spinePath = Path();

    spinePath.moveTo(0, 0);

    spinePath.lineTo(spineWidth, 0);

    spinePath.lineTo(spineWidth, curveCenter - curveHeight / 2);

    // Top side of notch.
    spinePath.cubicTo(
      spineWidth + curveDepth * 0.25,
      curveCenter - curveHeight / 2,
      spineWidth + curveDepth,
      curveCenter - curveHeight * 0.30,
      spineWidth + curveDepth,
      curveCenter,
    );

    // Bottom side of notch.
    spinePath.cubicTo(
      spineWidth + curveDepth,
      curveCenter + curveHeight * 0.30,
      spineWidth + curveDepth * 0.25,
      curveCenter + curveHeight / 2,
      spineWidth,
      curveCenter + curveHeight / 2,
    );

    spinePath.lineTo(spineWidth, size.height);

    spinePath.lineTo(0, size.height);

    spinePath.close();

    canvas.drawPath(spinePath, greenPaint);

    // ============================================================
    // GOLD EDGE
    // ============================================================

    final edgePath = Path();

    edgePath.moveTo(spineWidth, 0);

    edgePath.lineTo(spineWidth, curveCenter - curveHeight / 2);

    edgePath.cubicTo(
      spineWidth + curveDepth * 0.25,
      curveCenter - curveHeight / 2,
      spineWidth + curveDepth,
      curveCenter - curveHeight * 0.30,
      spineWidth + curveDepth,
      curveCenter,
    );

    edgePath.cubicTo(
      spineWidth + curveDepth,
      curveCenter + curveHeight * 0.30,
      spineWidth + curveDepth * 0.25,
      curveCenter + curveHeight / 2,
      spineWidth,
      curveCenter + curveHeight / 2,
    );

    edgePath.lineTo(spineWidth, size.height);

    canvas.drawPath(edgePath, goldPaint);
  }

  @override
  bool shouldRepaint(covariant BookSpinePainter oldDelegate) {
    return oldDelegate.spineColor != spineColor ||
        oldDelegate.edgeColor != edgeColor ||
        oldDelegate.paperColor != paperColor;
  }
}
