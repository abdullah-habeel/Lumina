import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/delete_leaf/controller/delete_leaf_controller.dart';
import 'package:lumina/features/home/models/controller/home_controller.dart';
import 'package:lumina/features/home/widgets/echo_card.dart';
import 'package:lumina/features/home/widgets/home_header.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/home/widgets/tell_my_story_card.dart';
import 'package:lumina/features/home/widgets/tree/growing_memory_tree.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late final HomeController controller;

  bool _animationStarted = false;
  late final AnimationController _cardAnimController;
  @override
  void initState() {
    super.initState();

    controller = Get.find<HomeController>();
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // ------------------------------------------------------------
    // WAIT FOR THE FIRST FRAME.
    //
    // The tree needs to exist and have a real size before we
    // calculate its global position.
    // ------------------------------------------------------------

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardAnimController.forward();
      _startPendingAnimation();
    });
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    super.dispose();
  }

  void replayCardAnimation() {
    _cardAnimController.reset();
    _cardAnimController.forward();
  }

  Future<void> triggerLeafAnimation(dynamic pendingEntry) async {
    _animationStarted = false;
    await _startPendingAnimationWithEntry(pendingEntry);
  }

  Future<void> _startPendingAnimationWithEntry(dynamic pendingEntry) async {
    if (_animationStarted) return;
    _animationStarted = true;

    debugPrint('HOME VIEW: triggerLeafAnimation called with $pendingEntry');

    for (int i = 0; i < 30; i++) {
      if (!mounted) return;

      final BuildContext? treeContext = controller.treeKey.currentContext;

      if (treeContext != null) {
        final RenderObject? renderObject = treeContext.findRenderObject();

        if (renderObject is RenderBox &&
            renderObject.hasSize &&
            renderObject.size.width > 0 &&
            renderObject.size.height > 0) {
          debugPrint('HOME VIEW: Tree ready for leaf animation');
          await Future.delayed(const Duration(milliseconds: 250));
          if (!mounted) return;
          await controller.playPendingLeafAnimation(context, pendingEntry);
          return;
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    debugPrint('HOME VIEW: Tree never ready — forcing animation');
    await controller.playPendingLeafAnimation(context, pendingEntry);
  }

  // ============================================================
  // PENDING LEAF
  // ============================================================

  Future<void> _startPendingAnimation() async {
    if (_animationStarted) {
      return;
    }

    // ------------------------------------------------------------
    // Read navigation arguments.
    // ------------------------------------------------------------

    final arguments = Get.arguments;

    if (arguments is! Map) {
      debugPrint('HOME VIEW: No navigation arguments.');
      return;
    }

    final pendingEntry = arguments['pendingLeafEntry'];

    if (pendingEntry == null) {
      debugPrint('HOME VIEW: No pending leaf.');
      return;
    }

    debugPrint('HOME VIEW: Pending leaf found.');

    // ------------------------------------------------------------
    // Prevent duplicate animation.
    // ------------------------------------------------------------

    _animationStarted = true;

    // ------------------------------------------------------------
    // Wait until GrowingMemoryTree has a real RenderBox.
    // ------------------------------------------------------------

    for (int i = 0; i < 30; i++) {
      if (!mounted) return;

      final BuildContext? treeContext = controller.treeKey.currentContext;

      if (treeContext != null) {
        final RenderObject? renderObject = treeContext.findRenderObject();

        if (renderObject is RenderBox &&
            renderObject.hasSize &&
            renderObject.size.width > 0 &&
            renderObject.size.height > 0) {
          debugPrint(
            'HOME VIEW: Tree ready. '
            'size=${renderObject.size}',
          );

          // ------------------------------------------------------
          // Small delay makes the transition from WriteAnswer
          // screen to Home feel intentional and gives the user
          // time to see the tree before the leaf starts moving.
          // ------------------------------------------------------

          await Future.delayed(const Duration(milliseconds: 250));

          if (!mounted) return;

          // ------------------------------------------------------
          // Tell controller to perform the animation.
          // ------------------------------------------------------

          await controller.playPendingLeafAnimation(context, pendingEntry);

          return;
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    // ------------------------------------------------------------
    // If tree never becomes ready, do NOT silently lose memory.
    // ------------------------------------------------------------

    debugPrint('HOME VIEW: Tree was never ready.');

    if (pendingEntry != null) {
      await controller.playPendingLeafAnimation(context, pendingEntry);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: TimeAwareBookBackground(
        animatedDay: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ------------------------------------------------------
            // DECORATIVE LEAF
            // ------------------------------------------------------

            // ------------------------------------------------------
            // MAIN CONTENT
            // ------------------------------------------------------
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // HEADER
                    // ------------------------------------------------
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: const HomeHeader(),
                    ),

                    // ------------------------------------------------
                    // TREE AREA
                    // ------------------------------------------------
                    SizedBox(
                      height: 214,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 260,
                            child: Stack(
                              children: [
                                // const IgnorePointer(child: GoldenStarParticles()),

                                // ----------------------------------
                                // GOLDEN DUST PARTICLES
                                // ----------------------------------
                              ],
                            ),
                          ),

                          // ------------------------------------------
                          // START WRITING CARD
                          // ------------------------------------------
                          SizedBox(
                            height: 324,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 260,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.deferToChild,
                                    onTapUp: (details) {
                                      // If a cloud is under the finger, make it rain
                                      if (CloudRain.hit(
                                        details.globalPosition,
                                      )) {
                                        CloudRain.start();
                                        return;
                                      }
                                      debugPrint('TREE TAP');
                                      controller.openMemoryTree();
                                    },
                                    child: Stack(
                                      children: [
                                        Hero(
                                          tag: 'memory_tree',
                                          child: Obx(() {
                                            final count =
                                                controller.entries.length;
                                            final deletedLeafController =
                                                Get.find<
                                                  DeletedLeafController
                                                >();
                                            final deleted =
                                                deletedLeafController
                                                    .deletedAnchorIndices;
                                            final fallen = deletedLeafController
                                                .fallenAnchorIndices
                                                .toSet();
                                            final skipped = {
                                              ...deleted,
                                              ...fallen,
                                            };
                                            return GrowingMemoryTree(
                                              key: controller.treeKey,
                                              entryCount: count,
                                              maxLeaves: 96,
                                              height: 240,
                                              deletedAnchorIndices: deleted,
                                              skippedAnchorIndices: skipped,
                                              animateNewLeaves: false,
                                              onDeadLeafFallComplete:
                                                  (anchorIndex) =>
                                                      deletedLeafController
                                                          .onLeafFallComplete(
                                                            anchorIndex,
                                                          ),
                                            );
                                          }),
                                        ),
                                        // const IgnorePointer(
                                        //   child: GoldenStarParticles(),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 46),
                    Padding(
  padding: EdgeInsets.symmetric(
    horizontal: horizontalPadding,
  ),
  child: TellMyStoryCard(
    onTap: () => Get.toNamed(AppRoutes.tellMyStory),
  ),
),
                    const SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: const  EchoCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
