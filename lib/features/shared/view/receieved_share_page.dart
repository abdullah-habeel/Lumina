import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';
import 'package:lumina/features/shared/controller/shared_memory_controller.dart';
import 'package:lumina/features/shared/model/shared_model.dart';

class _P {
  static const bg = Color(0xFF1F3A2E);
  static const forestSoft = Color(0xFF3B5847);
  static const ink = Color(0xFF3A2E22);
  static const inkMuted = Color(0xFF8A7A65);
  static const gold = Color(0xFFB69B70);
  static const line = Color(0xFFD9CBB2);
}

class ReceivedSharedPageView extends StatefulWidget {
  final SharedPage? initialPage;

  const ReceivedSharedPageView({super.key, this.initialPage});

  @override
  State<ReceivedSharedPageView> createState() => _ReceivedSharedPageViewState();
}

class _ReceivedSharedPageViewState extends State<ReceivedSharedPageView>
    with SingleTickerProviderStateMixin {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late final AnimationController _scene;

  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _scene = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final page = _getPage();

      if (page != null) {
        Get.find<SharedMemoryController>().markAsSeen(page);
      }
    });
  }

  @override
  void dispose() {
    _scene.dispose();
    _pageController.dispose();
    super.dispose();
  }

  SharedPage? _getPage() {
    return widget.initialPage ??
        (Get.arguments is SharedPage ? Get.arguments as SharedPage : null);
  }

  List<String> _splitBody(String text) {
    const charsPerPage = 420;

    final t = text.trim();

    if (t.length <= charsPerPage) {
      return [t];
    }

    final pages = <String>[];

    var start = 0;

    while (start < t.length) {
      var end = math.min(start + charsPerPage, t.length);

      if (end < t.length) {
        final b = t.lastIndexOf(' ', end);

        if (b > start + 80) {
          end = b;
        }
      }

      pages.add(t.substring(start, end).trim());

      start = end;
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final SharedPage? page = _getPage();

    final dateText = page != null
        ? '${_months[page.date.month - 1]} '
              '${page.date.day}, '
              '${page.date.year}'
        : '';

    final bodyPages = _splitBody(page?.body ?? '');

    final currentUserName = Get.isRegistered<SharedController>()
        ? (() {
            final sharedController = Get.find<SharedController>();
            final displayName = sharedController.currentDisplayName.value
                .trim();
            if (displayName.isNotEmpty) return displayName;
            return sharedController.currentUsername.value.trim();
          })()
        : '';

    final senderName = page?.direction == SharedDirection.sent
        ? currentUserName
        : page?.personName ?? '';

    return Scaffold(
      backgroundColor: _P.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─────────────────────────────────────────────────────────────
          // ANIMATED BACKGROUND
          // ─────────────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _scene,
            builder: (context, _) {
              final wave = math.sin(_scene.value * math.pi * 2);

              return Transform.translate(
                offset: Offset(wave * 8, wave * 3),
                child: Transform.scale(
                  scale: 1.08,
                  child: Opacity(
                    opacity: 0.40 + wave * 0.05,
                    child: Image.asset(
                      AppImages.sharebg,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),

          // ─────────────────────────────────────────────────────────────
          // FOREGROUND
          // ─────────────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ───────────────────────────────────────────────────────
                // TOP NAVIGATION
                // ───────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 10, 20, 6),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: _P.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ───────────────────────────────────────────────────────
                // PAGED LETTER SHEETS
                // ───────────────────────────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: bodyPages.length,
                    onPageChanged: (i) {
                      setState(() {
                        _currentPage = i;
                      });
                    },
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                        child: _TornLetter(
                          prompt: page?.question ?? '',
                          body: bodyPages[index],
                          date: dateText,
                          senderName: senderName,
                          pageIndex: index,
                          pageCount: bodyPages.length,
                          showHeader: index == 0,
                          showFooter: index == bodyPages.length - 1,
                          imagePaths: index == 0
                              ? (page?.imagePaths ?? [])
                              : [],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TORN LETTER
// ─────────────────────────────────────────────────────────────────────────────

class _TornLetter extends StatelessWidget {
  const _TornLetter({
    required this.prompt,
    required this.body,
    required this.date,
    required this.senderName,
    required this.pageIndex,
    required this.pageCount,
    required this.showHeader,
    required this.showFooter,
    required this.imagePaths,
  });

  final String prompt;
  final String body;
  final String date;
  final String senderName;

  final int pageIndex;
  final int pageCount;

  final bool showHeader;
  final bool showFooter;

  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TornPaperPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 36, 32, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────────────────────────────────────────────────────────
            // LETTER OPENING
            //
            // The date has intentionally been removed from the top.
            // A personal letter now starts directly with the prompt.
            // ───────────────────────────────────────────────────────────
            if (showHeader) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: _P.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        prompt,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontSize: 19,
                          height: 1.5,
                          color: _P.forestSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(height: 0.8, color: _P.line),

              const SizedBox(height: 28),
            ] else ...[
              // ─────────────────────────────────────────────────────────
              // CONTINUATION PAGE
              // ─────────────────────────────────────────────────────────
              Text(
                '— continued —',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 12.5,
                  color: _P.inkMuted,
                ),
              ),

              const SizedBox(height: 24),
            ],

            // ───────────────────────────────────────────────────────────
            // IMAGES
            //
            // Images are shown only on the first page.
            // ───────────────────────────────────────────────────────────
            if (showHeader && imagePaths.isNotEmpty) ...[
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imagePaths.length,
                  separatorBuilder: (_, __) {
                    return const SizedBox(width: 10);
                  },
                  itemBuilder: (_, i) {
                    final imagePath = imagePaths[i];
                    final isRemoteImage =
                        imagePath.startsWith('http://') ||
                        imagePath.startsWith('https://');
                    if (!isRemoteImage) {
                      return const SizedBox(
                        height: 130,
                        width: 130,
                        child: Center(child: Icon(Icons.broken_image_outlined)),
                      );
                    }

                    return GestureDetector(
                      onTap: () => showDialog<void>(
                        context: context,
                        barrierColor: Colors.black,
                        builder: (dialogContext) => Scaffold(
                          backgroundColor: Colors.black,
                          body: Stack(
                            children: [
                              Center(
                                child: InteractiveViewer(
                                  minScale: 0.8,
                                  maxScale: 4,
                                  child: Image.network(
                                    imagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image_outlined,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                  ),
                                ),
                              ),
                              SafeArea(
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imagePath,
                          height: 130,
                          width: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                height: 130,
                                width: 130,
                                child: Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],

            // ───────────────────────────────────────────────────────────
            // BODY
            // ───────────────────────────────────────────────────────────
            //written text
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                body,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 17,
                  height: 1.85,
                  color: _P.ink,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            // ───────────────────────────────────────────────────────────
            // FINAL LETTER SIGNATURE
            //
            // This appears ONLY on the last page.
            //
            // Order:
            //     With warmth,
            //     Sender name
            //     Date
            //
            // This gives the bottom of the page the feeling of a
            // handwritten/personal letter ending.
            // ───────────────────────────────────────────────────────────
            if (showFooter) ...[
              const SizedBox(height: 22),

              // Container(height: 0.6, color: _P.line),
              const SizedBox(height: 12),

              Text(
                'With warmth,',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                  color: _P.inkMuted,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                senderName.isNotEmpty ? senderName : 'Anonymous',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: _P.forestSoft,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                date,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 12.5,
                  color: _P.inkMuted,
                  letterSpacing: 0.2,
                ),
              ),
            ],

            // ───────────────────────────────────────────────────────────
            // PAGINATION
            // ───────────────────────────────────────────────────────────
            if (pageCount > 1) ...[
              const SizedBox(height: 20),

              Center(
                child: Text(
                  '${pageIndex + 1} / $pageCount',
                  style: TextStyle(
                    // fontFamily: 'Georgia',
                    fontSize: 11,

                    color: _P.inkMuted,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TORN PAPER PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _TornPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _tornPath(size);

    // Shadow
    canvas.drawPath(
      path.shift(const Offset(2, 6)),
      Paint()
        ..color = const Color(0x50000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Paper
    canvas.drawPath(path, Paint()..color = const Color(0xFFF7EFE0));

    // Soft paper highlight
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.topLeft,
          radius: 1.4,
          colors: [Colors.white.withOpacity(0.18), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Paper border
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFD9CBB2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    _grain(canvas, size);
  }

  void _grain(Canvas canvas, Size size) {
    final rng = math.Random(42);

    final p = Paint()
      ..color = const Color(0x0D000000)
      ..strokeWidth = 0.4;

    for (int i = 0; i < 220; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + 0.5 + rng.nextDouble() * 1.5, y + rng.nextDouble() * 0.5),
        p,
      );
    }
  }

  Path _tornPath(Size size) {
    final rng = math.Random(17);

    final path = Path();

    const l = 10.0;
    const r = 10.0;
    const t = 10.0;
    const b = 10.0;
    const step = 10.0;

    // Top
    path.moveTo(l, t + rng.nextDouble() * 2);

    for (double x = l + step; x <= size.width - r; x += step) {
      path.lineTo(x, t + rng.nextDouble() * 3 - 1.5);
    }

    // Right
    for (double y = t + step; y <= size.height - b; y += step) {
      path.lineTo(size.width - r + rng.nextDouble() * 2 - 1, y);
    }

    // Bottom
    for (double x = size.width - r - step; x >= l; x -= step) {
      path.lineTo(x, size.height - b + rng.nextDouble() * 3 - 1.5);
    }

    // Left
    for (double y = size.height - b - step; y >= t; y -= step) {
      path.lineTo(l + rng.nextDouble() * 2 - 1, y);
    }

    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) {
    return false;
  }
}
