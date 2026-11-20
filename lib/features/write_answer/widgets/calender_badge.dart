import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';

class CalendarBadge extends StatelessWidget {
  final String month;
  final String day;
  final double width;

  const CalendarBadge({
    super.key,
    required this.month,
    required this.day,
    this.width = 50,
  });

  @override
  Widget build(BuildContext context) {
    final double height = width * 1.35;

    // Hour comes from the parent screen's background
    final hour = DaylightTime.of(context);
    final cardBg = DaylightAppColors.cardBackground(hour);
    final border = DaylightAppColors.borderGold(hour);
    final accent = DaylightAppColors.accentGold(hour);
    final monthColor = DaylightAppColors.cardSubtext(hour);
    final dayColor = DaylightAppColors.cardText(hour);
    final shadowColor = DaylightAppColors.shadow(hour);

    final stripLight = Color.lerp(border, Colors.white, 0.25)!;
    final stripDark = accent;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // CARD
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // TOP STRIP
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [stripLight, stripDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
          ),

          // PAGE FOLD
          Positioned(
            right: 0,
            top: 0,
            child: CustomPaint(
              size: const Size(14, 14),
              painter: _FoldPainter(
                light: Color.lerp(cardBg, Colors.white, 0.4)!,
                dark: Color.lerp(border, cardBg, 0.3)!,
              ),
            ),
          ),

          // RINGS
          Positioned(left: width * .22, top: -7, child: const _Ring()),
          Positioned(right: width * .22, top: -7, child: const _Ring()),

          // TEXT
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 21),
              child: Column(
                children: [
                  Text(
                    month,
                    style: TextStyle(
                      color: monthColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    day,
                    style: TextStyle(
                      color: dayColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // INNER HIGHLIGHT
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(.20), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 18,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xff6C6C6C),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 8,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xff565656),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoldPainter extends CustomPainter {
  final Color light;
  final Color dark;

  const _FoldPainter({required this.light, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [light, dark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FoldPainter old) =>
      old.light != light || old.dark != dark;
}
