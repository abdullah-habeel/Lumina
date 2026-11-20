import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/features/book_display/view/book_display_view.dart';
import 'package:lumina/features/book_display/widgets/single_page.dart';
import 'package:lumina/core/routes/services/notification_services.dart';
import 'package:lumina/features/onboarding/controller/onboarding_controller.dart';
import 'package:page_flip/page_flip.dart';

class OnboardingBookScreen extends StatefulWidget {
  const OnboardingBookScreen({super.key});

  @override
  State<OnboardingBookScreen> createState() => _OnboardingBookScreenState();
}

class _OnboardingBookScreenState extends State<OnboardingBookScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _labelFade;
  late final Animation<Offset> _labelSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _bookFade;
  late final Animation<Offset> _bookSlide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _labelFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );
    _labelSlide = Tween(begin: const Offset(0.35, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
    );
    _titleSlide = Tween(begin: const Offset(0.35, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.15, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
    );

    _bookFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );
    _bookSlide = Tween(begin: const Offset(0.35, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        unawaited(NotificationService().requestPermission());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Obx(() {
      final text = controller.savedMemory.value;
      final mq = MediaQuery.of(context);

      const labelArea = 105.0;
      const bottomArea = 15.0;
      const horizontalPadding = 24.0;

      final availableHeight =
          mq.size.height -
          mq.padding.top -
          mq.padding.bottom -
          labelArea -
          bottomArea;

      final availableWidth = mq.size.width - horizontalPadding * 2;

      final shellW =
          math.min(availableWidth, availableHeight * BookShell.aspectRatio) *
          0.87;
      final shellH = shellW / BookShell.aspectRatio;
      final pageW = math.max(1.0, shellW - 12);
      final pageH = math.max(1.0, shellH);

      final List<SinglePage> pages;
      if (text.isEmpty) {
        pages = [
          SinglePage(
            date: '',
            title: '',
            body: '',
            pageNumber: 1,
            isFirstPage: true,
            isLastPage: true,
            pageWidth: pageW,
            pageHeight: pageH,
          ),
        ];
      } else {
        final chunks = BookPaginator.split(
          body: text,
          pageHeight: pageH,
          pageWidth: pageW,
          date: '',
          title: '',
          imageCount: 0,
        );
        pages = [
          for (int i = 0; i < chunks.length; i++)
            SinglePage(
              date: '',
              title: '',
              body: chunks[i].text,
              pageNumber: i + 1,
              isFirstPage: i == 0,
              isLastPage: chunks[i].isLastPage,
              pageWidth: pageW,
              pageHeight: pageH,
            ),
        ];
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 7),

            FadeTransition(
              opacity: _labelFade,
              child: SlideTransition(
                position: _labelSlide,
                child: Text(
                  text.isEmpty ? 'YOUR LIFEBOOK' : 'YOUR MEMORY, KEPT',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB8904F),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 13),

            FadeTransition(
              opacity: _titleFade,
              child: SlideTransition(
                position: _titleSlide,
                child: Text(
                  text.isEmpty
                      ? 'Your book is ready for its first memory.'
                      : 'Your memory now has a place.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fraunces(
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2B1A14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),

            FadeTransition(
              opacity: _subtitleFade,
              child: Text(
                text.isEmpty
                    ? 'Pages await your story'
                    : 'Swipe to turn the page',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF796954),
                ),
              ),
            ),

            const SizedBox(height: 15),

            FadeTransition(
              opacity: _bookFade,
              child: SlideTransition(
                position: _bookSlide,
                child: SizedBox(
                  width: shellW,
                  height: shellH,
                  child: BookShell(
                    child: PageFlipWidget(
                      key: ValueKey('onboarding_flip_${text.isEmpty}'),
                      backgroundColor: const Color(0xFFE8D3A7),
                      lastPage: pages.last,
                      children: pages,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
