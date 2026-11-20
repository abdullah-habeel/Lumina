import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_background.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/time_capsule/controller/time_capsule_list_controller.dart';
import 'package:lumina/features/time_capsule/model/time_capsule_model.dart';
import 'package:lumina/features/time_capsule/view/time_capsule_open_view.dart';
import 'package:lumina/features/time_capsule/widgets/sealed_capsule_card.dart';
import 'package:lumina/features/time_capsule/widgets/sealed_capsule_card_wrapper.dart';

class TimeCapsuleListView extends StatefulWidget {
  const TimeCapsuleListView({super.key});

  @override
  State<TimeCapsuleListView> createState() => _TimeCapsuleListViewState();
}

class _TimeCapsuleListViewState extends State<TimeCapsuleListView> {
  final TimeCapsuleListController controller =
      Get.find<TimeCapsuleListController>();
  bool _handledArg = false;

  void _showCapsuleOptions(BuildContext context, TimeCapsuleModel capsule) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Delete capsule',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, capsule);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, TimeCapsuleModel capsule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this capsule?'),
        content: const Text(
          'This can\'t be undone. The scheduled reminder will also be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteCapsule(capsule.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // If navigated here with an argument to open a capsule, try to open it
    final args = Get.arguments as Map<String, dynamic>?;
    final openId = args != null ? args['openCapsuleId'] as String? : null;
    if (openId != null) {
      // watch capsules and attempt to open once available and unlocked
      ever(controller.capsules, (_) {
        if (_handledArg) return;
        final capsule = controller.capsules.firstWhereOrNull(
          (c) => c.id == openId,
        );
        if (capsule != null && capsule.isUnlocked) {
          _handledArg = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.to(
              () => TimeCapsuleOpenView(capsule: capsule),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 350),
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TimeAwareBookBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: DaylightAppColors.headingText(DaylightTime.of(context)),
              ),
              onPressed: () => Get.back(),
            ),
          ),
          title: Builder(
            builder: (context) => Column(
              children: [
                Text(
                  'Time Capsules',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DaylightAppColors.headingText(
                      DaylightTime.of(context),
                    ),
                  ),
                ),
                Text(
                  'Your sealed letters to the future',
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: DaylightAppColors.headingSubtext(
                      DaylightTime.of(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.timeCapsuleCreate),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DaylightAppColors.borderGold(
                          DaylightTime.of(context),
                        ),
                        width: 2.5,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 20,
                      color: DaylightAppColors.headingText(
                        DaylightTime.of(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.capsules.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hero illustration
                            Image.asset(
                              'assets/images/timecapsule_book.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 16),

                            // Decorative divider with diamond
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  width: 48,
                                  child: Divider(
                                    color: Color(0xffC8B79D),
                                    thickness: 0.8,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '✦',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xffC8A84B),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 48,
                                  child: Divider(
                                    color: Color(0xffC8B79D),
                                    thickness: 0.8,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Heading
                            const Text(
                              'No letters yet',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff32402F),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Subtext
                            const Text(
                              'Write something today that your\nfuture self will treasure.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                height: 1.7,
                                color: Color(0xff8D7B69),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // CTA button — compact, not full width
                            GestureDetector(
                              onTap: () =>
                                  Get.toNamed(AppRoutes.timeCapsuleCreate),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xff3E5E4A),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: const Color(0xffC8A84B),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xff3E5E4A,
                                      ).withOpacity(0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.eco,
                                      size: 15,
                                      color: Color(0xffD4B896),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Seal your first capsule',
                                      style: TextStyle(
                                        fontFamily: 'PlayfairDisplay',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Subtle hint text below button
                            const Text(
                              'Unlocks on a date you choose',
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Color(0xffB2A280),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: controller.capsules.length,
                    itemBuilder: (context, index) {
                      final capsule = controller.capsules[index];
                      return SealedCapsuleCardWrapper(
                        capsule: capsule,
                        index: index,
                        onTap: () {
                          if (capsule.isUnlocked) {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration: const Duration(
                                  milliseconds: 750,
                                ),
                                reverseTransitionDuration: const Duration(
                                  milliseconds: 500,
                                ),
                                pageBuilder:
                                    (_, animation, secondaryAnimation) =>
                                        TimeCapsuleOpenView(capsule: capsule),
                                transitionsBuilder:
                                    (_, animation, secondaryAnimation, child) {
                                      final curved = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      );

                                      return FadeTransition(
                                        opacity: curved,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.12),
                                            end: Offset.zero,
                                          ).animate(curved),
                                          child: child,
                                        ),
                                      );
                                    },
                              ),
                            );
                          } else {
                            Get.snackbar(
                              'Still sealed',
                              'This capsule unlocks on ${DateFormatHelper.format(capsule.unlockDate)}.',
                            );
                          }
                        },
                        onMoreTap: () => _showCapsuleOptions(context, capsule),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DateFormatHelper {
  static String format(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}
