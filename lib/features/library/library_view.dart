import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_background.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/library/widgets/animations/chapter_book_cover.dart';
import 'package:lumina/features/library/widgets/animations/chapter_book_opener.dart';
import 'package:lumina/features/library/widgets/insight_card.dart';
import 'package:lumina/features/library/widgets/leather_chapter_card.dart';
import 'package:lumina/features/music/controller/sound_effects_controller.dart';
import 'package:lumina/features/music/widgets/music_screen_wrapper.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => LibraryViewState();
}

class LibraryViewState extends State<LibraryView>
    with SingleTickerProviderStateMixin {
  static const _timeCapsuleColor = Color(0xFF9A7B3E);
  static const _dailyJournalColor = Color(0xFF3E5E72);
  final GlobalKey _dailyJournalKey = GlobalKey();
  final GlobalKey _timeCapsuleKey = GlobalKey();

  late final AnimationController _controller;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _headerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  void playAnimation() {
    _controller.reset();
    _controller.forward();
  }

  void _playBookOpening() {
    if (Get.isRegistered<SoundEffectsController>()) {
      Get.find<SoundEffectsController>().playBookOpening();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MusicScreenWrapper(
      child: TimeAwareBookBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              SafeArea(
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).animate(_headerFade),
                        child: Builder(
                          builder: (context) => _buildHeader(context),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 130),
                        child: Column(
                          children: [
                            _AnimatedCard(
                              index: 0,
                              controller: _controller,
                              child: LeatherChapterCard(
                                key: _dailyJournalKey,
                                number: '01',
                                title: 'Daily Journal',
                                subtitle:
                                    'My thoughts, feelings, and reflections.',
                                leatherColor: _dailyJournalColor,
                                leafAsset: AppImages.dailyjournalbg,
                                illustrationAsset: AppImages.dailyjouornalright,

                                onTap: () async {
                                  _playBookOpening();
                                  HapticFeedback.lightImpact();

                                  await openChapterBook(
                                    context: context,
                                    cardKey: _dailyJournalKey,
                                    card: LeatherChapterCard(
                                      number: '01',
                                      title: 'Daily Journal',
                                      subtitle:
                                          'My thoughts, feelings, and reflections.',
                                      leatherColor: _dailyJournalColor,
                                      leafAsset: AppImages.dailyjournalbg,
                                      illustrationAsset:
                                          AppImages.dailyjouornalright,
                                      onTap: () {},
                                    ),
                                    cover: ChapterBookCover(
                                      number: '01',
                                      title: 'Daily Journal',
                                      subtitle:
                                          'My thoughts, feelings, and reflections.',
                                      leatherColor: _dailyJournalColor,
                                      leafAsset: AppImages.dailyjournalbg,
                                      illustrationAsset:
                                          AppImages.dailyjouornalright,
                                    ),
                                  );

                                  if (!mounted) return;
                                  Get.toNamed(
                                    AppRoutes.chapterdetail,
                                    arguments: {
                                      'chapterId': 'daily_journal',
                                      'chapterTitle': 'Daily Journal',
                                    },
                                  );
                                },
                              ),
                            ),
                            _AnimatedCard(
                              index: 1,
                              controller: _controller,
                              child: LeatherChapterCard(
                                key: _timeCapsuleKey,
                                number: '02',
                                title: 'Time Capsule',
                                subtitle: 'Memories for my future self.',
                                leatherColor: _timeCapsuleColor,
                                leafAsset: AppImages.timecapuleleft,
                                illustrationAsset: AppImages.timecapsulebook,
                                onTap: () async {
                                  _playBookOpening();
                                  HapticFeedback.lightImpact();

                                  await openChapterBook(
                                    context: context,
                                    cardKey: _timeCapsuleKey,
                                    card: LeatherChapterCard(
                                      number: '02',
                                      title: 'Time Capsule',
                                      subtitle: 'Memories for my future self.',
                                      leatherColor: _timeCapsuleColor,
                                      leafAsset: AppImages.timecapuleleft,
                                      illustrationAsset:
                                          AppImages.timecapsulebook,
                                      onTap: () {},
                                    ),
                                    cover: ChapterBookCover(
                                      number: '02',
                                      title: 'Time Capsule',
                                      subtitle: 'Memories for my future self.',
                                      leatherColor: _timeCapsuleColor,
                                      leafAsset: AppImages.timecapuleleft,
                                      illustrationAsset:
                                          AppImages.timecapsulebook,
                                    ),
                                  );

                                  if (!mounted) return;
                                  Get.toNamed(AppRoutes.timeCapsuleList);
                                },
                              ),
                            ),
                            _AnimatedCard(
  index: 2,
  controller: _controller,
  child: InsightsCard(),
),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Column(
        children: [
          Text(
            "My Book",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              letterSpacing: -.8,
              color: DaylightAppColors.bookTitleText(DaylightTime.of(context)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Your life. Beautifully written.",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.5,
              color: DaylightAppColors.bookTitleSubtext(
                DaylightTime.of(context),
              ),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 160,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xffC8B79D).withOpacity(0),
                  const Color(0xffC8B79D),
                  const Color(0xffC8B79D).withOpacity(0),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedCard({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = 0.1 + index * 0.15;
    final end = (start + 0.4).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 80 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}


