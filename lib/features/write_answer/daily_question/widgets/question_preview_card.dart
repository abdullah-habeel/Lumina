import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/music/controller/sound_effects_controller.dart';

class QuestionPreviewCard extends StatefulWidget {
  final String question;
  final VoidCallback? onAnimationDone;

  const QuestionPreviewCard({
    super.key,
    required this.question,
    this.onAnimationDone,
  });

  @override
  State<QuestionPreviewCard> createState() => _QuestionPreviewCardState();
}

class _QuestionPreviewCardState extends State<QuestionPreviewCard> {
  late final List<String> _words;
  int _visibleCount = 0;

  @override
  void initState() {
    super.initState();
    _words = widget.question.split(' ');
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Start sound
    if (Get.isRegistered<SoundEffectsController>()) {
      Get.find<SoundEffectsController>().startPencilWriting();
    }

    for (int i = 0; i < _words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() => _visibleCount = i + 1);
    }

    // Stop sound when last word appears
    if (Get.isRegistered<SoundEffectsController>()) {
      Get.find<SoundEffectsController>().stopPencilWriting();
    }

    widget.onAnimationDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final cardBg = DaylightAppColors.cardBackground(hour);
    final border = DaylightAppColors.borderGold(hour);
    final accent = DaylightAppColors.accentGold(hour);
    final textColor = DaylightAppColors.cardText(hour);
    final shadowColor = DaylightAppColors.shadow(hour);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 2),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 4,
            children: List.generate(_words.length, (i) {
              final visible = i < _visibleCount;
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: visible ? 1.0 : 0.0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 200),
                  offset: visible ? Offset.zero : const Offset(0, 0.3),
                  child: Text(
                    _words[i],
                    style: GoogleFonts.kalam(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: textColor,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Icon(Icons.spa_outlined, size: 16, color: accent),
        ],
      ),
    );
  }
}
