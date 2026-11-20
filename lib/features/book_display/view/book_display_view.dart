import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/bottom_navigation_bar.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/music/controller/sound_effects_controller.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';
import 'package:lumina/features/shared/controller/shared_memory_controller.dart';
import 'package:lumina/features/shared/model/shared_model.dart';
import 'package:lumina/features/write_answer/widgets/save_memory_button.dart';
import 'package:page_flip/page_flip.dart';

import '../widgets/single_page.dart';

class BookScreen extends StatefulWidget {
  final List<JournalEntry> entries;
  final int initialIndex;
  final bool isReadOnly;
  final bool saveOnButtonTap;

  const BookScreen({
    super.key,
    required this.entries,
    this.initialIndex = 0,
    this.isReadOnly = false,
    this.saveOnButtonTap = false,
  });

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final GlobalKey<PageFlipWidgetState> _controller =
      GlobalKey<PageFlipWidgetState>();
  final List<int> _memoryStartPageIndexes = [];

  bool _didPlayFlipSoundForDrag = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  // ==========================================================================
  // BUILD PAGES
  // ==========================================================================
  // ==========================================================================
  // BUILD PAGES
  // ==========================================================================

  List<SinglePage> _buildPages({
    required double pageHeight,
    required double pageWidth,
  }) {
    final List<SinglePage> pages = [];
    _memoryStartPageIndexes.clear();

    for (final entry in widget.entries) {
      // Remember the first physical page belonging to this memory.
      _memoryStartPageIndexes.add(pages.length);

      final String body = entry.body ?? '';

      if (body.trim().isEmpty) {
        pages.add(
          SinglePage(
            date: entry.formattedDate,
            title: entry.question,
            body: null,
            imagePaths: entry.imagePaths,
            pageNumber: pages.length + 1,
            isFirstPage: true,
            isLastPage: true,
            pageWidth: pageWidth,
            pageHeight: pageHeight,
          ),
        );
        continue;
      }

      final List<PageChunk> chunks = BookPaginator.split(
        body: body,
        pageHeight: pageHeight,
        pageWidth: pageWidth,
        date: entry.formattedDate,
        title: entry.question,
        imageCount: entry.imagePaths.length.clamp(0, 3),
      );

      for (int i = 0; i < chunks.length; i++) {
        pages.add(
          SinglePage(
            date: entry.formattedDate,
            title: entry.question,
            body: chunks[i].text,
            imagePaths: i == 0 ? entry.imagePaths : const [],
            pageNumber: pages.length + 1,
            isFirstPage: i == 0,
            isLastPage: chunks[i].isLastPage,
            pageWidth: pageWidth,
            pageHeight: pageHeight,
          ),
        );
      }
    }

    if (pages.isEmpty) {
      pages.add(
        SinglePage(
          date: '',
          title: '',
          body: null,
          imagePaths: const [],
          pageNumber: 1,
          isFirstPage: true,
          isLastPage: true,
          pageWidth: pageWidth,
          pageHeight: pageHeight,
        ),
      );
    }

    return pages;
  }

  Future<void> _saveAndGoHome() async {
    if (_isSaving || widget.entries.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final entry = widget.entries.first;

      if (!mounted) return;

      if (widget.saveOnButtonTap) {
        Get.offAllNamed(AppRoutes.main);
        await _triggerHomeLeafAnimation(entry);
        return;
      }

      Get.offAllNamed(AppRoutes.main);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your entry. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _triggerHomeLeafAnimation(JournalEntry entry) async {
    for (int i = 0; i < 20; i++) {
      final homeState = BottomNavScreen.homeKey.currentState;
      if (homeState != null) {
        await homeState.triggerLeafAnimation(entry);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    throw Exception('Home screen was not ready to save the memory.');
  }

  // ==========================================================================
  // SHARE
  // ==========================================================================

  Future<void> _openSharePicker() async {
    if (widget.entries.isEmpty) return;

    final entry = widget.entries.first;
    final trustedController = Get.find<SharedController>();
    final memoryController = Get.find<SharedMemoryController>();

    if (trustedController.trustedPeople.isEmpty) {
      Get.snackbar('No one to share with yet', 'Add someone you trust first.');
      return;
    }

    final TrustedPerson? chosen = await showModalBottomSheet<TrustedPerson>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EBDD),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              children: [
                // ─────────────────────────────
                // Drag handle
                // ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB7A58A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // ─────────────────────────────
                // Header
                // ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
                  child: Column(
                    children: [
                      const Text(
                        'Share a Memory',
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                          color: Color(0xFF2D4A3A),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Choose someone you trust',
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF6F6658),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Gold divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 0.7,
                              color: const Color(0xFFC5A46D),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 13,
                              color: Color(0xFFC5A46D),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 0.7,
                              color: const Color(0xFFC5A46D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─────────────────────────────
                // People
                // ─────────────────────────────
                Expanded(
                  child: Obx(
                    () => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: trustedController.trustedPeople.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final person = trustedController.trustedPeople[index];

                        return _VintagePersonTile(
                          person: person,
                          index: index,
                          onTap: () {
                            Navigator.pop(context, person);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (chosen == null) return;

    await memoryController.shareEntryDirectly(entry, chosen);

    if (!mounted) return;

    Get.snackbar(
      'Memory shared',
      'Your page has been shared with ${chosen.name}.',
    );
  }

  // ==========================================================================
  // COMPUTE FIXED PAGE DIMENSIONS
  //
  // Always uses the same dimensions regardless of whether the save
  // button is visible — so pagination is identical in both cases.
  // ==========================================================================

  // In _BookScreenState

  PageDimensions _computeDimensions(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final topPadding = mq.padding.top;
    final bottomPadding = mq.padding.bottom;
    final isLandscape = mq.orientation == Orientation.landscape;

    // Chrome heights shrink in landscape
    final double topBarHeight = isLandscape ? 48.0 : 64.0;
    final double swipeHintHeight = isLandscape ? 0.0 : 35.0;
    final double saveButtonHeight = 68.0; // keep consistent for pagination

    final double availableHeight =
        screenHeight -
        topPadding -
        bottomPadding -
        topBarHeight -
        swipeHintHeight -
        saveButtonHeight;

    // In landscape, allow the book to be wider relative to height
    final double aspectRatio = isLandscape
        ? BookShell.aspectRatio *
              1.35 // wider book in landscape
        : BookShell.aspectRatio;

    final double availableWidth = math.max(0.0, screenWidth - 40.0);
    final double widthFromHeight = availableHeight * aspectRatio;

    final double shellWidth = math.min(availableWidth, widthFromHeight);
    final double shellHeight = shellWidth / aspectRatio;

    return PageDimensions(
      shellWidth: shellWidth,
      shellHeight: shellHeight,
      pageWidth: math.max(1.0, shellWidth - 12.0),
      pageHeight: math.max(1.0, shellHeight),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final bool canShare =
        !widget.isReadOnly &&
        !widget.saveOnButtonTap &&
        widget.entries.length == 1;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: TimeAwareBookBackground(
        animatedDay: true,
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
                  color: DaylightAppColors.headingText(
                    DaylightTime.of(context),
                  ),
                ),
                onPressed: () => Get.back(),
              ),
            ),
            title: Builder(
              builder: (context) => Text(
                'My Book',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: DaylightAppColors.headingText(
                    DaylightTime.of(context),
                  ),
                ),
              ),
            ),
            centerTitle: true,
            actions: [
              if (canShare)
                Builder(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: BookColors.leatherDark.withOpacity(0.55),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: BookColors.goldDark.withOpacity(0.45),
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.share_outlined,
                          color: BookColors.goldLight,
                          size: 21,
                        ),
                        onPressed: _openSharePicker,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: OrientationBuilder(
            builder: (context, orientation) {
              final dims = _computeDimensions(context);

              final List<SinglePage> pages = _buildPages(
                pageHeight: dims.pageHeight,
                pageWidth: dims.pageWidth,
              );

              final int initialPageIndex =
                  widget.initialIndex >= 0 &&
                      widget.initialIndex < _memoryStartPageIndexes.length
                  ? _memoryStartPageIndexes[widget.initialIndex]
                  : 0;

              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: dims.shellWidth,
                          height: dims.shellHeight,
                          child: BookShell(
                            child: Listener(
                              onPointerMove: (event) {
                                if (_didPlayFlipSoundForDrag ||
                                    event.delta.dx.abs() <
                                        event.delta.dy.abs()) {
                                  return;
                                }
                                _didPlayFlipSoundForDrag = true;
                                Get.find<SoundEffectsController>()
                                    .playPageFlip();
                              },
                              onPointerUp: (_) {
                                _didPlayFlipSoundForDrag = false;
                              },
                              onPointerCancel: (_) {
                                _didPlayFlipSoundForDrag = false;
                              },
                              child: PageFlipWidget(
                                key: _controller,
                                backgroundColor: BookColors.parchment,
                                initialIndex: initialPageIndex,
                                lastPage: pages.last,
                                children: pages,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: currentPageIndex,
                      builder: (context, currentIndex, _) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 2),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${currentIndex + 1} / ${pages.length}',
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: DaylightAppColors.headingSubtext(
                                      DaylightTime.of(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (!widget.isReadOnly)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        child: SaveMemoryButton(
                          isLoading: _isSaving,
                          backgroundColor: AppColors.primaryGreen,
                          textColor: AppColors.borderGold,
                          onPressed: _isSaving ? null : _saveAndGoHome,
                        ),
                      ),
                    if (widget.isReadOnly) const SizedBox(height: 68),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// PAGE DIMENSIONS
// ==========================================================================

class PageDimensions {
  final double shellWidth;
  final double shellHeight;
  final double pageWidth;
  final double pageHeight;

  const PageDimensions({
    required this.shellWidth,
    required this.shellHeight,
    required this.pageWidth,
    required this.pageHeight,
  });
}

// ============================================================================
// BOOK SHELL
// ============================================================================

class BookShell extends StatelessWidget {
  static const double aspectRatio = 0.62;

  final Widget child;

  const BookShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ==================================================================
          // LEATHER BACK COVER
          // ==================================================================
          Positioned(
            left: -2,
            right: -12,
            top: -6,
            bottom: -6,
            child: Container(
              decoration: BoxDecoration(
                color: BookColors.leatherDeep,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.65),
                    blurRadius: 20,
                    offset: const Offset(6, 10),
                  ),
                ],
              ),
            ),
          ),

          // ==================================================================
          // PAGE THICKNESS
          // ==================================================================
          const Positioned(
            right: -1,
            top: -3,
            bottom: -3,
            width: 13,
            child: BookPageThickness(),
          ),

          // ==================================================================
          // PAGE UNDERNEATH
          // ==================================================================
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: const BoxDecoration(
                color: BookColors.parchment,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: const Center(
                child: Text(
                  'Lumina',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    color: BookColors.leather,
                  ),
                ),
              ),
            ),
          ),

          // ==================================================================
          // FLIPPING PAGE
          // ==================================================================
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PAGE THICKNESS
// ============================================================================

class BookPageThickness extends StatelessWidget {
  const BookPageThickness();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: PageThicknessPainter());
  }
}

class PageThicknessPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 9; i++) {
      final double x = i * size.width / 9.0;
      final Paint paint = Paint()
        ..color = i.isEven ? const Color(0xFF86613A) : const Color(0xFFC9A66C)
        ..strokeWidth = 0.7;
      canvas.drawLine(Offset(x, 2), Offset(x + 1, size.height - 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VintagePersonTile extends StatelessWidget {
  final TrustedPerson person;
  final int index;
  final VoidCallback onTap;

  const _VintagePersonTile({
    required this.person,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = person.name.isNotEmpty
        ? person.name[0].toUpperCase()
        : '?';

    final hasPhoto = person.photoUrl != null && person.photoUrl!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGold, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // ─────────────────────────────
              // Profile photo / vintage initial
              // ─────────────────────────────
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2D4A3A),
                  border: Border.all(
                    color: const Color(0xFFC5A46D),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: hasPhoto
                      ? Image.network(
                          person.photoUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontFamily: 'Cormorant Garamond',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF4EBDD),
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Color(0xFFC5A46D),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF4EBDD),
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 14),

              // ─────────────────────────────
              // Name + username
              // ─────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D4A3A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${person.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 12,
                        color: Color(0xFF827665),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFFC5A46D),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
