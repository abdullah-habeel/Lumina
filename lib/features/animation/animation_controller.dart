import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lumina/features/animation/widgets/celebration.dart';

/// Central place to trigger celebration overlays across the app.
/// Add more methods here later (e.g. showChapterCompleteCelebration)
/// without touching the screens that call them.
class CelebrationController {
  CelebrationController._();
  static final CelebrationController instance = CelebrationController._();

  Future<void> showMemorySaved(BuildContext context) {
    return showMemorySavedCelebration(context);
  }
}
