import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/features/write_answer/controller/voice_input_controller.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';

class VoiceInputButton extends StatefulWidget {
  final void Function(String text) onTextReceived;

  const VoiceInputButton({super.key, required this.onTextReceived});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  late final VoiceInputController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<VoiceInputController>();

    // register once only
    ever(_controller.isListening, (listening) {
      if (!listening && _controller.transcribedText.value.isNotEmpty) {
        widget.onTextReceived(_controller.transcribedText.value);
        _controller.transcribedText('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final accent = DaylightAppColors.accentGold(hour);
    final cardBg = DaylightAppColors.cardBackground(hour);
    final textColor = DaylightAppColors.cardText(hour);
    final border = DaylightAppColors.borderGold(hour);

    return Obx(() {
      final isListening = _controller.isListening.value;
      final isAvailable = _controller.isAvailable.value;

      return Column(
        children: [
          GestureDetector(
            onTap: isAvailable ? _controller.toggleListening : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening ? accent.withOpacity(0.15) : cardBg,
                border: Border.all(
                  color: isListening ? accent : border.withOpacity(0.4),
                  width: isListening ? 2 : 1,
                ),
                boxShadow: isListening
                    ? [
                        BoxShadow(
                          color: accent.withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none_outlined,
                color: isListening ? accent : textColor.withOpacity(0.6),
                size: 28,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isListening
                ? 'Listening...'
                : isAvailable
                ? 'Tap to speak'
                : 'Voice unavailable',
            style: GoogleFonts.lora(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isListening ? accent : textColor.withOpacity(0.45),
            ),
          ),

          if (isListening && _controller.transcribedText.value.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
              child: Text(
                _controller.transcribedText.value,
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 13,
                  color: textColor.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
