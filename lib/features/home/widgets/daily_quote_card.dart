import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';

class DailyQuoteCard extends StatelessWidget {
  const DailyQuoteCard({super.key});

  static const List<String> _quotes = [
    "The smallest moments carry the heaviest meaning.",
    "You are not what happened to you. You are what you chose to remember.",
    "A life unexamined is a life half lived.",
    "Every memory you write is a letter to your future self.",
    "The story of who you are is written in the quiet moments.",
    "You don't need to understand your life to live it beautifully.",
    "What you notice says everything about who you are.",
    "Some days deserve to be remembered. Write them down.",
  ];

  String get _todaysQuote {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final accent = DaylightAppColors.accentGold(hour);
    final shadowColor = DaylightAppColors.shadow(hour);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: BoxDecoration(
        color: DaylightAppColors.cardBackground(hour),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DaylightAppColors.borderGold(hour),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Large decorative opening quote mark — top left
          Positioned(
            top: -8,
            left: -4,
            child: Text(
              '\u201C',
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 72,
                height: 1,
                color: accent.withOpacity(0.25),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Large decorative closing quote mark — bottom right
          Positioned(
            bottom: -18,
            right: -2,
            child: Text(
              '\u201D',
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 72,
                height: 1,
                color: accent.withOpacity(0.25),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Quote content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Quote text — centered, italic, different font
                Text(
                  _todaysQuote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5C4A2A),
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 10),

                // Decorative divider line
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 1,
                      color: accent.withOpacity(0.4),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 24,
                      height: 1,
                      color: accent.withOpacity(0.4),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Label
                Text(
                  'Daily Reflection',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent.withOpacity(0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}