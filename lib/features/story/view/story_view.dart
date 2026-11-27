import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/story/controller/story_controller.dart';

class StoryView extends StatelessWidget {
  const StoryView({super.key});

  static const Color cream = Color(0xFFF5EBD5);
  static const Color green = Color(0xFF2F4F41);
  static const Color gold = Color(0xFFC79A4B);
  static const Color brown = Color(0xFF55402C);
  static const Color lightBrown = Color(0xFF7A6652);

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
        body: Column(
          children: [
            // ── Top level tab: On-Device / Cloud ─────────────
            _MainTabBar(controller: controller),

            // ── Content ──────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.showOnDevice.value) {
                  // ── On-Device Summary ─────────────────────
                  return _OnDeviceSummaryTab(
                    controller: controller,
                  );
                }

                // ── Cloud Story ───────────────────────────────
                if (controller.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                            color: AppColors.primaryGreen),
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
                          _CloudGenerateButton(
                              onPressed: controller.generateStory),
                        ],
                      ),
                    ),
                  );
                }

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
                            'Cloud AI will weave your memories into\na narrative that is uniquely yours.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 15,
                              color:
                                  AppColors.primaryGreen.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 36),
                          _CloudGenerateButton(
                              onPressed: controller.generateStory),
                        ],
                      ),
                    ),
                  );
                }

                // ── Story shown ───────────────────────────────
                return Column(
                  children: [
                    // Basic/Rich toggle
                    _ToggleBar(controller: controller),

                    // Pattern summary (rich mode only)
                    if (controller.showRich.value)
                      _PatternSummaryCard(
                        patternSummary: controller.patternSummary,
                      ),

                    // Narrative text
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(24, 16, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSwitcher(
                              duration:
                                  const Duration(milliseconds: 400),
                              child: Text(
                                controller.currentNarrative,
                                key: ValueKey(
                                    controller.showRich.value),
                                style:
                                    GoogleFonts.cormorantGaramond(
                                  fontSize: 17,
                                  height: 1.8,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Privacy reminder
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 12,
                                  color: AppColors.primaryGreen
                                      .withOpacity(0.4),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Names protected · Processed by cloud AI',
                                  style:
                                      GoogleFonts.cormorantGaramond(
                                    fontSize: 12,
                                    color: AppColors.primaryGreen
                                        .withOpacity(0.4),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Regenerate button
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: _CloudGenerateButton(
                        label: 'Regenerate',
                        onPressed: controller.generateStory,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main Tab Bar ────────────────────────────────────────────────

class _MainTabBar extends StatelessWidget {
  final StoryController controller;
  const _MainTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                _MainTabOption(
                  label: '🔒 On-Device',
                  isSelected: controller.showOnDevice.value,
                  onTap: controller.switchToOnDevice,
                ),
                _MainTabOption(
                  label: '☁️ Cloud Story',
                  isSelected: !controller.showOnDevice.value,
                  onTap: controller.switchToCloud,
                ),
              ],
            ),
          ),
        ));
  }
}

class _MainTabOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MainTabOption({
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}

// ── On-Device Summary Tab ───────────────────────────────────────

class _OnDeviceSummaryTab extends StatelessWidget {
  final StoryController controller;
  const _OnDeviceSummaryTab({required this.controller});

  static const Color green = Color(0xFF2F4F41);
  static const Color gold = Color(0xFFC79A4B);
  static const Color brown = Color(0xFF55402C);
  static const Color lightBrown = Color(0xFF7A6652);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pattern = controller.patternSummary;
      final totalMemories = pattern['totalMemories'] ?? 0;

      if (totalMemories == 0) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Write some memories first\nto see your on-device insights.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                color: AppColors.primaryGreen.withOpacity(0.7),
              ),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // On-device badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_android_rounded,
                      size: 14, color: green),
                  const SizedBox(width: 6),
                  Text(
                    'Processed on-device · Private · No cloud used',
                    style: TextStyle(
                      fontSize: 12,
                      color: green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: gold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your pattern',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: brown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _summaryRow('Total memories',
                      '${pattern['totalMemories'] ?? 0}'),
                  _divider(),
                  _summaryRow('Life-changing moments',
                      '${pattern['highSignificanceCount'] ?? 0}'),
                  _divider(),
                  _summaryRow('Dominant emotions',
                      '${pattern['topEmotions'] ?? 'none yet'}'),
                  _divider(),
                  _summaryRow('Recurring themes',
                      '${pattern['topThemes'] ?? 'none yet'}'),
                  _divider(),
                  _summaryRow('People in your life',
                      '${pattern['topPeople'] ?? 'none yet'}'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Upgrade prompt
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: gold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: gold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Switch to Cloud Story for a literary narrative written about who you are.',
                      style: TextStyle(
                        fontSize: 13,
                        color: lightBrown,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: lightBrown,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: brown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: const Color(0xFFC79A4B).withOpacity(0.2));
  }
}

// ── Toggle Bar (basic/rich within cloud tab) ────────────────────

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
                    if (controller.showRich.value)
                      controller.toggleMode();
                  },
                ),
                _ToggleOption(
                  label: 'With AI Patterns',
                  isSelected: controller.showRich.value,
                  onTap: () {
                    if (!controller.showRich.value)
                      controller.toggleMode();
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
            color: isSelected
                ? AppColors.primaryGreen
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : AppColors.primaryGreen,
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
                  value:
                      '${patternSummary['totalMemories'] ?? 0}',
                ),
                _PatternRow(
                  label: 'People',
                  value:
                      '${patternSummary['topPeople'] ?? 'none yet'}',
                ),
                _PatternRow(
                  label: 'Emotions',
                  value:
                      '${patternSummary['topEmotions'] ?? 'none yet'}',
                ),
                _PatternRow(
                  label: 'Themes',
                  value:
                      '${patternSummary['topThemes'] ?? 'none yet'}',
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

// ── Cloud Generate Button ───────────────────────────────────────

class _CloudGenerateButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  final String label;

  const _CloudGenerateButton({
    required this.onPressed,
    this.label = 'Generate with Cloud AI',
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}