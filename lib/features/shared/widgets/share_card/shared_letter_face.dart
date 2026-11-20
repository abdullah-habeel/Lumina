import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/shared/widgets/share_card/shared_card_paint.dart';

import 'shared_status_stamp.dart';

class SharedLetterFace extends StatelessWidget {
  const SharedLetterFace({
    super.key,
    required this.seed,
    required this.isReceived,
    required this.personName,
    required this.question,
    required this.dateText,
    required this.isNew,
    required this.isSeen,
    required this.onTap,
    required this.onLongPress,
    this.press = 0,
    this.breath = 0,
  });

  final double seed;
  final bool isReceived;
  final String personName;
  final String question;
  final String dateText;
  final bool isNew;
  final bool isSeen;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final double press;
  final double breath;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TornPaperClipper(seed: seed),
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFFFFFBF2)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/sharecard.png',
                  fit: BoxFit.cover,
                  alignment: Alignment(0.8, 0.6 + breath * 0.08),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.16)),
            ),
            Positioned.fill(
              child: CustomPaint(painter: PaperGrainPainter(seed: seed)),
            ),
            Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isReceived ? 'From $personName' : 'To $personName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.2,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        if (isReceived && isNew)
                          const SharedStatusStamp(
                            text: 'New',
                            color: Color(0xFFB8860B),
                          ),
                        if (!isReceived)
                          SharedStatusStamp(
                            text: isSeen ? 'Seen' : 'Not seen',
                            color: isSeen
                                ? const Color(0xFF2E5E2E)
                                : const Color(0xFF5C4A2A),
                            showCheck: isSeen,
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      question,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentGold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 11.5,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ShareOuterBorderPainter(seed: seed),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ShareInnerBorderPainter(seed: seed),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ShareHighlightPainter(seed: seed, t: breath),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
