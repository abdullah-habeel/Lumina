import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';

class PatternSummaryCard extends StatelessWidget {
  final RxMap<String, dynamic> patternSummary;
  const PatternSummaryCard({super.key, required this.patternSummary});

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
                PatternRow(
                  label: 'Memories',
                  value: '${patternSummary['totalMemories'] ?? 0}',
                ),
                PatternRow(
                  label: 'People',
                  value: '${patternSummary['topPeople'] ?? 'none yet'}',
                ),
                PatternRow(
                  label: 'Emotions',
                  value:
                      '${patternSummary['topEmotions'] ?? 'none yet'}',
                ),
                PatternRow(
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

class PatternRow extends StatelessWidget {
  final String label;
  final String value;
  const PatternRow({super.key, required this.label, required this.value});

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