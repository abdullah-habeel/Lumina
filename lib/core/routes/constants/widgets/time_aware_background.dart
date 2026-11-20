import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_background.dart'; // DaylightPlainBackground
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/shared/widgets/starts_animation.dart'; // your night file

class TimeAwareBookBackground extends StatefulWidget {
  final Widget? child;

  /// true  = sun, clouds and birds during the day (home screen only)
  /// false = plain time-based gradient during the day (all other screens)
  final bool animatedDay;

  const TimeAwareBookBackground({
    super.key,
    this.child,
    this.animatedDay = false,
  });

  @override
  State<TimeAwareBookBackground> createState() =>
      _TimeAwareBookBackgroundState();
}

class _TimeAwareBookBackgroundState extends State<TimeAwareBookBackground> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final night = DayNight.isNight(DayNight.currentHour());

    Widget scene;
    if (night) {
      scene = DaylightTime(
        key: const ValueKey('night'),
        hour: 19.0,
        child: StarryBookBackground(child: widget.child),
      );
    } else if (widget.animatedDay) {
      scene = DaylightBookBackground(
        key: const ValueKey('day-animated'),
        child: widget.child,
      );
    } else {
      scene = DaylightPlainBackground(
        key: const ValueKey('day-plain'),
        child: widget.child,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: scene,
    );
  }
}
