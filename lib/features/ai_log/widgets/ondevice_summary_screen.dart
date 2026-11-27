import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/service/privacy_gate_service.dart';

class OnDeviceSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> patternSummary;

  const OnDeviceSummaryScreen({
    super.key,
    required this.patternSummary,
  });

  static const Color cream = Color(0xFFF5EBD5);
  static const Color green = Color(0xFF2F4F41);
  static const Color gold = Color(0xFFC79A4B);
  static const Color brown = Color(0xFF55402C);
  static const Color lightBrown = Color(0xFF7A6652);

  @override
  Widget build(BuildContext context) {
    final totalMemories = patternSummary['totalMemories'] ?? 0;
    final topEmotions = patternSummary['topEmotions'] ?? 'none yet';
    final topThemes = patternSummary['topThemes'] ?? 'none yet';
    final topPeople = patternSummary['topPeople'] ?? 'none yet';
    final highCount = patternSummary['highSignificanceCount'] ?? 0;

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: brown,
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Your Story',
          style: TextStyle(
            color: brown,
            fontFamily: 'serif',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // On-device badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_android_rounded, size: 14, color: green),
                  const SizedBox(width: 6),
                  Text(
                    'Processed on-device · Private',
                    style: TextStyle(
                      fontSize: 12,
                      color: green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Stats row ──
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

            const SizedBox(height: 20),

            // ── Emotions ──
            _sectionCard(
              icon: Icons.favorite_outline_rounded,
              iconColor: Colors.pinkAccent,
              title: 'Dominant Emotions',
              child: _chipWrap(topEmotions, Colors.pink.withOpacity(0.08),
                  Colors.pink.withOpacity(0.25), Colors.pink.shade700),
            ),

            const SizedBox(height: 14),

            // ── Themes ──
            _sectionCard(
              icon: Icons.auto_awesome_mosaic_outlined,
              iconColor: gold,
              title: 'Recurring Themes',
              child: _chipWrap(topThemes, gold.withOpacity(0.08),
                  gold.withOpacity(0.3), brown),
            ),

            const SizedBox(height: 14),

            // ── People ──
            _sectionCard(
              icon: Icons.people_outline_rounded,
              iconColor: green,
              title: 'People in Your Life',
              child: _chipWrap(topPeople, green.withOpacity(0.07),
                  green.withOpacity(0.25), green),
            ),

            const SizedBox(height: 28),

            // ── Unlock prompt ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome, color: gold, size: 28),
                  const SizedBox(height: 12),
                  const Text(
                    'Unlock your full story',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: brown,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cloud AI can turn these patterns into a literary paragraph about who you are. Person names are always protected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: lightBrown,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await PrivacyGateService()
                            .saveChoice(PrivacyChoice.cloudEnabled);
                        Get.back(result: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: cream,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Generate my full story',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Stat card (memories / key moments) ──
    Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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

  // ── Section card wrapper ──
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

  // ── Chip wrap from comma-separated string ──
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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