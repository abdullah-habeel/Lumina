import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/story/controller/story_controller.dart';
import 'package:lumina/features/story/controller/story_controller.dart';

class StoryView extends StatelessWidget {
  const StoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryController());

    return TimeAwareBookBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.primaryGreen,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Tell My Story',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          // ── Loading ──────────────────────────────────────────
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryGreen),
                  SizedBox(height: 20),
                  Text(
                    'Weaving your story...',
                    style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 16,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Error ────────────────────────────────────────────
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _GenerateButton(onPressed: controller.generateStory),
                  ],
                ),
              ),
            );
          }

          // ── Empty state ──────────────────────────────────────
          if (!controller.hasStory) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your story is waiting\nto be told.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We will weave your memories into\na narrative that is uniquely yours.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 15,
                        color: AppColors.primaryGreen.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 36),
                    _GenerateButton(onPressed: controller.generateStory),
                  ],
                ),
              ),
            );
          }

          // ── Story ────────────────────────────────────────────
          return Column(
            children: [
              // Toggle bar
              _ToggleBar(controller: controller),

              // Pattern summary (only visible in rich mode)
              if (controller.showRich.value)
                _PatternSummaryCard(
                  patternSummary: controller.patternSummary,
                ),

              // Narrative text
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      controller.currentNarrative,
                      key: ValueKey(controller.showRich.value),
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 17,
                        height: 1.8,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ),

              // Regenerate button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _GenerateButton(
                  label: 'Regenerate',
                  onPressed: controller.generateStory,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Toggle Bar ─────────────────────────────────────────────────

class _ToggleBar extends StatelessWidget {
  final StoryController controller;
  const _ToggleBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                _ToggleOption(
                  label: 'Without AI Patterns',
                  isSelected: !controller.showRich.value,
                  onTap: () {
                    if (controller.showRich.value) controller.toggleMode();
                  },
                ),
                _ToggleOption(
                  label: 'With AI Patterns',
                  isSelected: controller.showRich.value,
                  onTap: () {
                    if (!controller.showRich.value) controller.toggleMode();
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pattern Summary Card ────────────────────────────────────────

class _PatternSummaryCard extends StatelessWidget {
  final RxMap<String, dynamic> patternSummary;
  const _PatternSummaryCard({required this.patternSummary});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pattern Intelligence',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _PatternRow(
                  label: 'Memories',
                  value: '${patternSummary['totalMemories'] ?? 0}',
                ),
                _PatternRow(
                  label: 'People',
                  value: '${patternSummary['topPeople'] ?? 'none yet'}',
                ),
                _PatternRow(
                  label: 'Emotions',
                  value: '${patternSummary['topEmotions'] ?? 'none yet'}',
                ),
                _PatternRow(
                  label: 'Themes',
                  value: '${patternSummary['topThemes'] ?? 'none yet'}',
                ),
              ],
            ),
          ),
        ));
  }
}

class _PatternRow extends StatelessWidget {
  final String label;
  final String value;
  const _PatternRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 12,
                color: AppColors.primaryGreen.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Generate Button ─────────────────────────────────────────────

class _GenerateButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  final String label;

  const _GenerateButton({
    required this.onPressed,
    this.label = 'Tell My Story',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}