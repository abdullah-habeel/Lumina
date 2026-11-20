import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';

class MemoryDetailView extends StatelessWidget {
  const MemoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final entry = Get.arguments as JournalEntry?;

    if (entry == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Memory not found',
            style: TextStyle(
              color: DaylightAppColors.headingText(DaylightTime.of(context)),
            ),
          ),
        ),
      );
    }

    final time = DaylightTime.of(context);

    return TimeAwareBookBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: DaylightAppColors.bookTitleText(time),
          title: Text(
            entry.formattedDate,
            style: TextStyle(
              color: DaylightAppColors.bookTitleText(time),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              entry.question,
              style: TextStyle(
                color: DaylightAppColors.bookTitleText(time),
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              entry.body?.trim().isNotEmpty == true
                  ? entry.body!
                  : 'This memory has no written words yet.',
              style: TextStyle(
                color: entry.body?.trim().isNotEmpty == true
                    ? DaylightAppColors.bookTitleText(time)
                    : DaylightAppColors.bookTitleSubtext(time),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
