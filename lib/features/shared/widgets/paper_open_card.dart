import 'package:flutter/material.dart';

class PaperOpenTransition {
  const PaperOpenTransition._();

  static Future<T?> open<T>(
    BuildContext context, {
    required Widget destination,
    Duration duration = const Duration(milliseconds: 620),
    Color backgroundColor = const Color(0xFFF7F1E7),
  }) {
    return Navigator.of(context).push<T>(
      _PaperOpenRoute(
        destination: destination,
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _PaperOpenRoute<T> extends PageRouteBuilder<T> {
  final Widget destination;
  final Duration duration;
  final Color backgroundColor;

  _PaperOpenRoute({
    required this.destination,
    required this.duration,
    required this.backgroundColor,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 420),
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) {
            return ColoredBox(
              color: backgroundColor,
              child: destination,
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final fade = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
            );

            final slide = Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curve);

            final scale = Tween<double>(
              begin: 0.97,
              end: 1.0,
            ).animate(curve);

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
            );
          },
        );
}