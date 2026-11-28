import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/ai_log/controller/ai_log_controller.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';

class AiLogView extends StatelessWidget {
  const AiLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiLogController());
    final hour = DaylightTime.of(context);
    final headingColor = DaylightAppColors.headingText(hour);
    final subtextColor = DaylightAppColors.headingSubtext(hour);

    return TimeAwareBookBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: headingColor,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'AI Inference Log',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: headingColor,
            ),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.logEntries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.memory_outlined,
                      size: 48,
                      color: subtextColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No AI operations yet.',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        color: headingColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save a memory and AI will\ntag it automatically.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 14,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: controller.logEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = controller.logEntries[index];
              return _AiLogTile(
                entry: entry,
                label: controller.labelFor(entry.inferenceSource),
              );
            },
          );
        }),
      ),
    );
  }
}

// ── Log Tile ────────────────────────────────────────────────────

class _AiLogTile extends StatelessWidget {
  final dynamic entry;
  final String label;

  const _AiLogTile({required this.entry, required this.label});

  String _normalizeSource(String source) {
    return source.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
  }

  Color _sourceColor(String source) {
    switch (_normalizeSource(source)) {
      case 'on_device':
        return const Color(0xFF2D7A4F);
      case 'in_cloud':
        return const Color(0xFF1565C0);
      case 'failed':
        return const Color(0xFFB71C1C);
      default:
        return Colors.grey;
    }
  }

  IconData _sourceIcon(String source) {
    switch (_normalizeSource(source)) {
      case 'on_device':
        return Icons.phone_android;
      case 'in_cloud':
        return Icons.cloud_outlined;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final cardBg = DaylightAppColors.cardBackground(hour);
    final border = DaylightAppColors.borderGold(hour);
    final textColor = DaylightAppColors.cardText(hour);
    final subtextColor = DaylightAppColors.cardSubtext(hour);

    final color = _sourceColor(entry.inferenceSource);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // ── Source icon ──────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _sourceIcon(entry.inferenceSource),
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),

          // ── Operation + question ─────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.operation,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.memoryQuestion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 13,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(entry.date),
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 12,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),

          // ── Source badge ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}