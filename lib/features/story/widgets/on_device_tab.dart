import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/story/controller/story_controller.dart';

class OnDeviceTab extends StatelessWidget {
  final StoryController controller;
  const OnDeviceTab({super.key, required this.controller});

  static const Color cream = Color(0xFFF5EBD5);
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

      final topEmotions = pattern['topEmotions'] ?? 'none yet';
      final topThemes = pattern['topThemes'] ?? 'none yet';
      final topPeople = pattern['topPeople'] ?? 'none yet';
       final highCount = pattern['highSignificanceCount'] ?? 0;
            final isOnDevice = pattern['dominantInferenceSource'] == 'ON_DEVICE';
             debugPrint('BADGE_DEBUG: source=${pattern['dominantInferenceSource']} isOnDevice=$isOnDevice');
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // On-device badge
                        Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOnDevice ? green.withOpacity(0.1) : gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOnDevice ? green.withOpacity(0.3) : gold.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOnDevice ? Icons.phone_android_rounded : Icons.cloud_rounded,
                    size: 14,
                    color: isOnDevice ? green : gold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnDevice ? 'Processed on-device · Private' : 'Processed in cloud',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnDevice ? green : gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Stat cards row ──
            Row(
              children: [
                _statCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Memories',
                  value: '$totalMemories',
                ),
                const SizedBox(width: 12),
                _statCard(
                  icon: Icons.stars_rounded,
                  label: 'Key moments',
                  value: '$highCount',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Emotions ──
            _sectionCard(
              icon: Icons.favorite_outline_rounded,
              iconColor: Colors.pinkAccent,
              title: 'Dominant Emotions',
              child: _chipWrap(
                topEmotions,
                Colors.pink.withOpacity(0.08),
                Colors.pink.withOpacity(0.25),
                Colors.pink.shade700,
              ),
            ),

            const SizedBox(height: 12),

            // ── Themes ──
            _sectionCard(
              icon: Icons.auto_awesome_mosaic_outlined,
              iconColor: gold,
              title: 'Recurring Themes',
              child: _chipWrap(
                topThemes,
                gold.withOpacity(0.08),
                gold.withOpacity(0.3),
                brown,
              ),
            ),

            const SizedBox(height: 12),

            // ── People ──
            _sectionCard(
              icon: Icons.people_outline_rounded,
              iconColor: green,
              title: 'People in Your Life',
              child: _chipWrap(
                topPeople,
                green.withOpacity(0.07),
                green.withOpacity(0.25),
                green,
              ),
            ),

            const SizedBox(height: 24),

            // ── Upgrade prompt ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: gold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: gold, size: 20),
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

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: green),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: brown,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                  Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: lightBrown,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: brown,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _chipWrap(
    String raw,
    Color bgColor,
    Color borderColor,
    Color textColor,
  ) {
    final items = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e != 'none yet')
        .toList();

    if (items.isEmpty) {
      return Text(
        'none yet',
        style: TextStyle(fontSize: 13, color: lightBrown),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            item,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}