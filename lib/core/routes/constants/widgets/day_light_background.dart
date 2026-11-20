import 'package:flutter/material.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';

/// ===============================================================
/// DAYLIGHT PLAIN BACKGROUND
///
/// Same time-of-day color logic as DaylightBookBackground, but
/// WITHOUT the sun, clouds, or falling leaves — just a smooth
/// gradient background that shifts with the hour. Use this on
/// screens that don't need the full animated scene (settings,
/// profile, chapter detail, etc.) but should still feel like
/// part of the same time-aware app.
/// ===============================================================

class DaylightPlainBackground extends StatelessWidget {
  final Widget? child;

  /// TESTING ONLY. Same behavior as DaylightBookBackground's
  /// debugOverrideHour — set null for real device time.
  final double? debugOverrideHour;

  const DaylightPlainBackground({
    super.key,
    this.child,
    this.debugOverrideHour,
  });

  @override
  Widget build(BuildContext context) {
    final double currentHour;

    final override = debugOverrideHour ?? DaylightDebug.hour;
    if (override != null) {
      currentHour = override;
    } else {
      final now = DateTime.now();
      currentHour = now.hour + now.minute / 60.0;
    }

    final clampedHour = currentHour.clamp(
      DayStages.stages.first.hour,
      DayStages.stages.last.hour,
    );

    final stage = DayStages.resolve(clampedHour);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [stage.skyTop, stage.skyMid, stage.skyBottom],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: DaylightTime(
        hour: clampedHour,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
