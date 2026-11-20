import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/write_answer/controller/voice_input_controller.dart';

class AnswerInputField extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;
  final double minHeight;
  final double fontSize;
  final double lineHeightMultiplier;
  final void Function(String text)? onVoiceText;

  const AnswerInputField({
    super.key,
    required this.controller,
    this.maxLength = 1000,
    this.minHeight = 380,
    this.fontSize = 15,
    this.lineHeightMultiplier = 1.9,
    this.onVoiceText,
  });

  @override
  State<AnswerInputField> createState() => _AnswerInputFieldState();
}

class _AnswerInputFieldState extends State<AnswerInputField>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _count = widget.controller.text.length;
    widget.controller.addListener(_onChanged);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  void _onChanged() => setState(() => _count = widget.controller.text.length);

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double lineHeight = widget.fontSize * widget.lineHeightMultiplier;
    final hour = DaylightTime.of(context);
    final cardBg = DaylightAppColors.cardBackground(hour);
    final border = DaylightAppColors.borderGold(hour);
    final accent = DaylightAppColors.accentGold(hour);
    final textColor = DaylightAppColors.cardText(hour);
    final subtextColor = DaylightAppColors.cardSubtext(hour);
    const micColor = Color(0xFFE07B6A);

    final voiceCtrl = Get.isRegistered<VoiceInputController>()
        ? Get.find<VoiceInputController>()
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            right: 2,
            top: 10,
            bottom: -4,
            child: _pageLayer(
              cardBg: cardBg,
              border: border,
              opacity: 0.35,
              radius: 10,
            ),
          ),
          Positioned(
            left: 6,
            right: 1,
            top: 6,
            bottom: -2,
            child: _pageLayer(
              cardBg: cardBg,
              border: border,
              opacity: 0.55,
              radius: 12,
            ),
          ),

          ConstrainedBox(
            constraints: BoxConstraints(minHeight: widget.minHeight),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -6,
                    bottom: -6,
                    child: Image.asset(
                      AppImages.questionflower,
                      width: 90,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.local_florist_outlined,
                        size: 60,
                        color: border.withOpacity(0.5),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 24, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header row with mic button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Begin your story...',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 16,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Image.asset(
                                  'assets/images/leaf_sprig.png',
                                  width: 16,
                                  height: 16,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.eco_outlined,
                                    size: 16,
                                    color: border,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Mic button in header
                                if (voiceCtrl != null)
                                  Obx(() {
                                    final isListening =
                                        voiceCtrl.isListening.value;
                                    return GestureDetector(
                                      onTap: voiceCtrl.toggleListening,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isListening
                                              ? micColor.withOpacity(0.15)
                                              : Colors.transparent,
                                        ),
                                        child: Icon(
                                          isListening
                                              ? Icons.mic
                                              : Icons.mic_none_outlined,
                                          size: 20,
                                          color: isListening
                                              ? micColor
                                              : border,
                                        ),
                                      ),
                                    );
                                  }),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/images/feather.png',
                                  width: 28,
                                  height: 28,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.mode_edit_outline,
                                    size: 24,
                                    color: border,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Text field
                        Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _LinedPaperPainter(
                                  color: border.withOpacity(0.22),
                                  lineHeight: lineHeight,
                                ),
                              ),
                            ),
                            TextField(
                              controller: widget.controller,
                              maxLength: widget.maxLength,
                              maxLines: null,
                              style: TextStyle(
                                fontSize: widget.fontSize,
                                height: widget.lineHeightMultiplier,
                                color: textColor,
                              ),
                              cursorColor: accent,
                              buildCounter:
                                  (
                                    _, {
                                    required currentLength,
                                    required isFocused,
                                    maxLength,
                                  }) => null,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText:
                                    'Life offers no edit button. Neither does this page. Write what truly matters.',
                                hintStyle: TextStyle(
                                  fontSize: widget.fontSize,
                                  height: widget.lineHeightMultiplier,
                                  color: subtextColor.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Waveform + mic shown when listening
                        if (voiceCtrl != null)
                          Obx(() {
                            if (!voiceCtrl.isListening.value) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Left waveform
                                      AnimatedBuilder(
                                        animation: _waveController,
                                        builder: (_, __) => _Waveform(
                                          progress: _waveController.value,
                                          color: micColor,
                                          mirrored: true,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Center mic circle
                                      GestureDetector(
                                        onTap: voiceCtrl.toggleListening,
                                        child: Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: micColor.withOpacity(0.15),
                                            border: Border.all(
                                              color: micColor.withOpacity(0.5),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.mic,
                                            color: micColor,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Right waveform
                                      AnimatedBuilder(
                                        animation: _waveController,
                                        builder: (_, __) => _Waveform(
                                          progress: _waveController.value,
                                          color: micColor,
                                          mirrored: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Listening...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: micColor.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  Positioned(
                    right: 20,
                    bottom: 12,
                    child: Text(
                      '$_count / ${widget.maxLength}',
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageLayer({
    required Color cardBg,
    required Color border,
    required double opacity,
    required double radius,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg.withOpacity(opacity),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border.withOpacity(0.25)),
      ),
    );
  }
}

// Animated waveform bars
class _Waveform extends StatelessWidget {
  final double progress;
  final Color color;
  final bool mirrored;

  const _Waveform({
    required this.progress,
    required this.color,
    required this.mirrored,
  });

  @override
  Widget build(BuildContext context) {
    const barCount = 6;
    const barWidth = 3.0;
    const spacing = 3.0;
    const maxHeight = 36.0;
    const minHeight = 6.0;

    final bars = List.generate(barCount, (i) {
      final phase = (progress + i / barCount) % 1.0;
      final height =
          minHeight + (maxHeight - minHeight) * sin(phase * pi).abs();
      return height;
    });

    if (mirrored) bars.reversed.toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(barCount, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i < barCount - 1 ? spacing : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: barWidth,
            height: bars[i],
            decoration: BoxDecoration(
              color: color.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _LinedPaperPainter extends CustomPainter {
  final Color color;
  final double lineHeight;

  const _LinedPaperPainter({required this.color, required this.lineHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    double y = lineHeight * 0.82;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += lineHeight;
    }
  }

  @override
  bool shouldRepaint(covariant _LinedPaperPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.lineHeight != lineHeight;
}
