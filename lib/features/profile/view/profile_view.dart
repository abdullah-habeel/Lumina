import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/app_icons.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/demo/service/demo_seed_service.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/notification/controller/notification_controller.dart';
import 'package:lumina/features/pin/controller/pin_controller.dart';
import 'package:lumina/features/profile/widgets/animated_menu_tile.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/profile_controller.dart';
import '../widgets/profile_widgets.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  late final AnimationController _menuController;
  late final AnimationController _treePulseController;
  late final Animation<double> _treePulse;
  int _statsKey = 0;

  // ── Demo seed tap counter (hidden trigger) ──────────────────
  int _logoTapCount = 0;
  final DemoSeedService _demoSeedService = DemoSeedService();

  @override
  void initState() {
    super.initState();

    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _treePulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _treePulse = Tween<double>(begin: 0.15, end: 0.25).animate(
      CurvedAnimation(parent: _treePulseController, curve: Curves.easeInOut),
    );
    final controller = Get.find<ProfileController>();
    ever(controller.isLoading, (loading) {
      if (!loading && mounted) {
        _menuController.reset();
        _menuController.forward();
      }
    });
  }

  @override
  void dispose() {
    _menuController.dispose();
    _treePulseController.dispose();
    super.dispose();
  }

  void playAnimation() {
    _menuController.reset();
    _menuController.forward();
    setState(() => _statsKey++);
  }

  // ── Hidden demo trigger — tap avatar 7 times ────────────────
  void _onAvatarTap() {
    _logoTapCount++;
    if (_logoTapCount >= 7) {
      _logoTapCount = 0;
      _showDemoSheet();
    }
  }

  void _showDemoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFF4EBDD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFB7A58A),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Demo Mode',
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D4A3A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Seed 20 memories + 1 sealed capsule\nfor demo recording.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 14,
                color: Color(0xFF6F6658),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    Get.snackbar(
                      'Seeding data...',
                      'Please wait.',
                      duration: const Duration(seconds: 2),
                    );
                    await _demoSeedService.seedDemoData();
                    Get.snackbar(
                      'Done',
                      'Demo data loaded. Restart the app to see it.',
                    );
                  } catch (e) {
                    Get.snackbar('Error', 'Could not seed demo data: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D4A3A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Seed Demo Data',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _demoSeedService.clearDemoData();
                    Get.snackbar('Done', 'Demo data cleared.');
                  } catch (e) {
                    Get.snackbar('Error', 'Could not clear demo data: $e');
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D4A3A),
                  side: const BorderSide(color: Color(0xFF2D4A3A)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Clear Demo Data',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return TimeAwareBookBackground(
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: const Alignment(-11.5, -0.9),
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: .35,
                      child: Image.asset(AppImages.leaftwo, height: 220),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(11.5, -0.9),
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: .35,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..scale(-1.0, 1.0),
                        child: Image.asset(AppImages.leaftwo, height: 220),
                      ),
                    ),
                  ),
                ),
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      expandedHeight: 140,
                      iconTheme: const IconThemeData(
                        color: AppColors.primaryGreen,
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ── Avatar — tap 7x to unlock demo ──
                              GestureDetector(
                                onTap: _onAvatarTap,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.background,
                                        border: Border.all(
                                          color: AppColors.primaryGreen,
                                          width: 4.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 42,
                                        backgroundColor: AppColors.primaryGreen,
                                        backgroundImage:
                                            controller
                                                .profilePhotoUrl
                                                .value
                                                .isNotEmpty
                                            ? NetworkImage(
                                                controller
                                                    .profilePhotoUrl
                                                    .value,
                                              )
                                            : null,
                                        child:
                                            controller
                                                .profilePhotoUrl
                                                .value
                                                .isEmpty
                                            ? Text(
                                                controller
                                                        .displayName
                                                        .value
                                                        .isNotEmpty
                                                    ? controller
                                                          .displayName
                                                          .value[0]
                                                          .toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  fontSize: 30,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    if (controller.isUploadingPhoto.value)
                                      Positioned.fill(
                                        child: Container(
                                          margin: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black38,
                                          ),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 4.4,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: GestureDetector(
                                        onTap: controller.isUploadingPhoto.value
                                            ? null
                                            : controller.pickAndUploadPhoto,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryGreen,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.background,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '@${controller.username.value}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: DaylightAppColors.bookTitleSubtext(
                                    DaylightTime.of(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 150),
                        child: Column(
                          children: [
                            Obx(
                              () => ProfileBookStats(
                                key: ValueKey(_statsKey), // 👈 changed
                                entries: controller.journalEntriesCount.value,
                                trusted: controller.trustedPeopleCount.value,
                                shared: controller.sharedMemoriesCount.value,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          child: AnimatedBuilder(
                                            animation: _treePulse,
                                            builder: (context, child) {
                                              return Opacity(
                                                opacity: _treePulse.value,
                                                child: child,
                                              );
                                            },
                                            child: ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                DaylightAppColors.treeOverlay(
                                                  DaylightTime.of(context),
                                                ),
                                                BlendMode.modulate,
                                              ),
                                              child: Image.asset(
                                                AppImages.questiontree,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          const SizedBox(height: 4),
                                          AnimatedMenuTile(
                                            index: 0,
                                            controller: _menuController,
                                            child: ProfileMenuTile(
                                              icon: AppIcons.editProfile,
                                              title: 'Edit profile',
                                              onTap: () => Get.toNamed(
                                                AppRoutes.editProfile,
                                              ),
                                            ),
                                          ),
                                          AnimatedMenuTile(
                                            index: 1,
                                            controller: _menuController,
                                            child: Obx(() {
                                              final sharedController =
                                                  Get.find<SharedController>();
                                              return Stack(
                                                children: [
                                                  ProfileMenuTile(
                                                    icon: AppIcons.whomITrust,
                                                    title: 'People I trust',
                                                    onTap: () => Get.toNamed(
                                                      AppRoutes.peopleITrust,
                                                    ),
                                                  ),
                                                  if (sharedController
                                                      .incomingRequests
                                                      .isNotEmpty)
                                                    Positioned(
                                                      left: 30,
                                                      top: 8,
                                                      child: Container(
                                                        width: 9,
                                                        height: 9,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Colors.red,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            }),
                                          ),
                                          AnimatedMenuTile(
                                            index: 2,
                                            controller: _menuController,
                                            child: Obx(() {
                                              final pinController =
                                                  Get.find<PinController>();
                                              final isEnabled = pinController
                                                  .isPinEnabled
                                                  .value;
                                              return Column(
                                                children: [
                                                  ProfileMenuTile(
                                                    icon: AppIcons.lock,
                                                    title: isEnabled
                                                        ? 'Change PIN'
                                                        : 'Set Up PIN',
                                                    onTap: () {
                                                      if (isEnabled) {
                                                        Get.toNamed(
                                                          AppRoutes
                                                              .verifyCurrentPin,
                                                        );
                                                      } else {
                                                        Get.toNamed(
                                                          AppRoutes.choosePin,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  if (isEnabled)
                                                    ProfileMenuTile(
                                                      icon: AppIcons.lockOpen,
                                                      title:
                                                          'Turn Off PIN Protection',
                                                      iconColor: AppColors
                                                          .primaryGreen,
                                                      textColor: AppColors
                                                          .primaryGreen,
                                                      onTap: () {
                                                        Get.toNamed(
                                                          AppRoutes
                                                              .verifyCurrentPin,
                                                          arguments: {
                                                            'action': 'disable',
                                                          },
                                                        );
                                                      },
                                                    ),
                                                ],
                                              );
                                            }),
                                          ),
                                          AnimatedMenuTile(
                                            index: 3,
                                            controller: _menuController,
                                            child: ProfileMenuTile(
                                              icon: AppIcons.music,
                                              title: 'Music',
                                              onTap: () =>
                                                  Get.toNamed(AppRoutes.music),
                                            ),
                                          ),
                                          AnimatedMenuTile(
                                            index: 4,
                                            controller: _menuController,
                                            child: ProfileMenuTile(
                                              icon: AppIcons.sound,
                                              title: 'Sound',
                                              onTap: () =>
                                                  Get.toNamed(AppRoutes.sound),
                                            ),
                                          ),
                                          AnimatedMenuTile(
                                            index: 5,
                                            controller: _menuController,
                                            child: Obx(() {
                                              final notificationsController =
                                                  Get.find<
                                                    NotificationsController
                                                  >();
                                              final hasUnread =
                                                  notificationsController.items.any(
                                                    (item) =>
                                                        !notificationsController
                                                            .isRead(item.id),
                                                  );
                                              return ProfileMenuTile(
                                                icon: AppIcons.notifications,
                                                title: 'Notifications',
                                                showNotificationDot: hasUnread,
                                                onTap: () => Get.toNamed(
                                                  AppRoutes.notifications,
                                                ),
                                              );
                                            }),
                                          ),

                                          AnimatedMenuTile(
                                            index: 6,
                                            controller: _menuController,
                                            child: IconDataMenuTile(
                                              icon: Icons.memory_outlined,
                                              title: 'AI Inference Log',
                                              onTap: () =>
                                                  Get.toNamed(AppRoutes.aiLog),
                                            ),
                                          ),

                                          AnimatedMenuTile(
                                            index: 7,
                                            controller: _menuController,
                                            child: ProfileMenuTile(
                                              icon: AppIcons.logout,
                                              title: 'Log out',
                                              onTap: () => controller
                                                  .showLogoutConfirmation(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
