import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/onboarding/controller/onboarding_controller.dart';

class OnboardingWriteScreen extends StatefulWidget {
  const OnboardingWriteScreen({super.key});

  @override
  State<OnboardingWriteScreen> createState() => _OnboardingWriteScreenState();
}

class _OnboardingWriteScreenState extends State<OnboardingWriteScreen>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focus = FocusNode();
  bool _saving = false;
  bool _hasText = false;

  late final AnimationController _staggerCtrl;
  late final Animation<double> _labelFade;
  late final Animation<Offset> _labelSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _paperFade;
  late final Animation<Offset> _paperSlide;

  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  late final AnimationController _saveCtrl;
  late final Animation<double> _saveFade;
  late final Animation<Offset> _saveSlide;

  @override
  void initState() {
    super.initState();

    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _labelFade = CurvedAnimation(
      parent: _staggerCtrl,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );
    _labelSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _staggerCtrl,
      curve: const Interval(0.2, 0.45, curve: Curves.easeOut),
    );
    _titleSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.2, 0.45, curve: Curves.easeOut),
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _staggerCtrl,
      curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
    );

    _paperFade = CurvedAnimation(
      parent: _staggerCtrl,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    );
    _paperSlide = Tween(begin: const Offset(0.35, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _saveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _saveFade = CurvedAnimation(parent: _saveCtrl, curve: Curves.easeOut);
    _saveSlide = Tween(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _saveCtrl, curve: Curves.easeOutCubic));

    _textController.addListener(_onTextChanged);
    _staggerCtrl.forward();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      if (hasText) {
        _saveCtrl.forward();
        _glowCtrl.stop();
      } else {
        _saveCtrl.reverse();
        _glowCtrl.repeat(reverse: true);
      }
    }
  }

  Future<void> _onSave() async {
    final text = _textController.text.trim();
    if (_saving) return;
    _focus.unfocus();
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _saving = false);
    final c = Get.find<OnboardingController>();
    c.savedMemory.value = text;
    c.nextPage();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _glowCtrl.dispose();
    _saveCtrl.dispose();
    _textController.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _labelFade,
              child: SlideTransition(
                position: _labelSlide,
                child: Text(
                  'Your first page',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w800,
                    color: AppColors.borderGold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FadeTransition(
              opacity: _titleFade,
              child: SlideTransition(
                position: _titleSlide,
                child: Text(
                  'What memory\nshould live here?',
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

            const SizedBox(height: 10),

            FadeTransition(
              opacity: _subtitleFade,
              child: Text(
                'Your story begins with a single page.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 13,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF796954),
                ),
              ),
            ),

            const SizedBox(height: 28),

            FadeTransition(
              opacity: _paperFade,
              child: SlideTransition(
                position: _paperSlide,
                child: AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (context, child) {
                    final glowOpacity = _hasText ? 0.0 : _glowAnim.value;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5E482D).withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: const Color(
                              0xFFB8904F,
                            ).withOpacity(0.55 * glowOpacity),
                            blurRadius: 40 + (20 * glowOpacity),
                            spreadRadius: 4 + (8 * glowOpacity),
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: _VintagePaperCard(
                    controller: _textController,
                    focusNode: _focus,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            FadeTransition(
              opacity: _saveFade,
              child: SlideTransition(
                position: _saveSlide,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5C2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFF2E8D0),
                            ),
                          )
                        : Text(
                            'Keep this memory',
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFF2E8D0),
                            ),
                          ),
                  ),
                ),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _hasText
                  ? const SizedBox(height: 8)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VINTAGE PAPER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _VintagePaperCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _VintagePaperCard({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final paperHeight = constraints.maxWidth < 350 ? 300.0 : 330.0;

        return ClipPath(
          clipper: _TornEdgeClipper(),
          child: Container(
            height: paperHeight,
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFFAF6EE)),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _VintagePaperPainter()),
                ),
                Positioned(
                  top: 16,
                  right: 20,
                  child: Opacity(
                    opacity: 0.28,
                    child: Text(
                      '❧',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xFF9B7740),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    minLines: 8,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    textAlignVertical: TextAlignVertical.top,
                    style: GoogleFonts.lora(
                      fontSize: 15,
                      height: 1.9,
                      color: const Color(0xFF3B3025),
                    ),
                    cursorColor: const Color(0xFF9B7740),
                    cursorWidth: 1.2,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Begin writing here...',
                      hintStyle: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF796954).withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TORN EDGE CLIPPER
// ─────────────────────────────────────────────────────────────────────────────

class _TornEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);
    double x = 0;
    const step = 12.0;
    bool up = true;
    while (x < size.width) {
      x += step;
      path.lineTo(x.clamp(0, size.width), up ? 5 : 0);
      up = !up;
    }

    path.lineTo(size.width, size.height);

    x = size.width;
    up = true;
    while (x > 0) {
      x -= step;
      path.lineTo(x.clamp(0, size.width), size.height + (up ? -4 : 0));
      up = !up;
    }

    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// VINTAGE PAPER PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _VintagePaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Ruled lines
    final linePaint = Paint()
      ..color = const Color(0xFFB8904F).withOpacity(0.08)
      ..strokeWidth = 0.65;

    const startY = 58.0;
    const spacing = 30.0;
    for (double y = startY; y < size.height - 10; y += spacing) {
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), linePaint);
    }

    // Aged paper vignette
    final vignetteRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final vignette = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [Colors.transparent, const Color(0xFF8B6914).withOpacity(0.07)],
    ).createShader(vignetteRect);

    canvas.drawRect(vignetteRect, Paint()..shader = vignette);

    // Torn edge border
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final borderPath = Path();

    borderPath.moveTo(0, 0);
    double x = 0;
    const step = 12.0;
    bool up = true;
    while (x < size.width) {
      x += step;
      borderPath.lineTo(x.clamp(0, size.width), up ? 5 : 0);
      up = !up;
    }

    borderPath.lineTo(size.width, size.height);

    x = size.width;
    up = true;
    while (x > 0) {
      x -= step;
      borderPath.lineTo(x.clamp(0, size.width), size.height + (up ? -4 : 0));
      up = !up;
    }

    borderPath.lineTo(0, 0);
    borderPath.close();

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
