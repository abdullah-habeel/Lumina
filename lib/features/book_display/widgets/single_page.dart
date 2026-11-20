import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'page_content.dart';

// ============================================================================
// BOOK COLORS
// ============================================================================

class BookColors {
  static const parchment = Color(0xFFE8D3A7);
  static const parchmentLight = Color(0xFFF2E4C3);
  static const parchmentDark = Color(0xFFC9AA72);

  static const leather = Color(0xFF593A2A);
  static const leatherDark = Color(0xFF3B251B);
  static const leatherDeep = Color(0xFF2B1A14);

  static const gold = Color(0xFFB8904F);
  static const goldLight = Color(0xFFD2B36D);
  static const goldDark = Color(0xFF806131);

  static const ink = Color(0xFF3B3025);
  static const border = Color(0xFF95764A);
}

// ============================================================================
// BOOK PAGE METRICS
// ============================================================================

class BookPageMetrics {
  final double pageWidth;
  final double pageHeight;

  const BookPageMetrics({required this.pageWidth, required this.pageHeight});

  double get horizontalPadding => pageWidth * 0.08;
  double get verticalPadding => pageHeight * 0.04;
  double get contentWidth => math.max(1, pageWidth - horizontalPadding * 2);

  double get dateFontSize => (pageWidth * 0.029).clamp(10.0, 12.0);
  double get titleFontSize => (pageWidth * 0.068).clamp(24.0, 30.0);
  double get bodyFontSize => (pageWidth * 0.041).clamp(15.0, 18.0);
  double get pageNumberFontSize => (pageWidth * 0.031).clamp(11.0, 14.0);

  double get dateTitleSpacing => (pageHeight * 0.018).clamp(10.0, 16.0);
  double get titleDividerSpacing => (pageHeight * 0.022).clamp(14.0, 20.0);
  double get dividerBodySpacing => (pageHeight * 0.027).clamp(18.0, 25.0);
  double get imageBodySpacing => (pageHeight * 0.027).clamp(18.0, 25.0);
  double get paragraphSpacing => 18.0;
  double get dividerHeight => 6.0;

  double get pageNumberHeight {
    final painter = TextPainter(
      text: TextSpan(
        text: '99',
        style: GoogleFonts.ebGaramond(
          fontSize: pageNumberFontSize,
          color: Colors.brown.shade600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.height;
  }

  double imageHeight(int imageCount) {
    if (imageCount <= 0) return 0;
    if (imageCount == 1) return contentWidth * 0.75 + 3;
    if (imageCount == 2) return contentWidth * 0.70;
    return contentWidth * 1.35;
  }

  double getDateHeight(String date) {
    if (date.trim().isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(
        text: date.toUpperCase(),
        style: GoogleFonts.cinzel(
          fontSize: dateFontSize,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.8,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: contentWidth);
    return painter.height;
  }

  double getTitleHeight(String title) {
    if (title.trim().isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(
        text: title,
        style: GoogleFonts.fraunces(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: contentWidth);
    return painter.height;
  }

  double firstPageBodyHeight({
    required String date,
    required String title,
    required int imageCount,
  }) {
    final available = pageHeight - (verticalPadding * 2);
    final pageNumArea = 6.0 + pageNumberHeight;

    double header = 0;
    header += getDateHeight(date);
    header += dateTitleSpacing;
    header += getTitleHeight(title);
    header += titleDividerSpacing;
    header += dividerHeight;
    header += dividerBodySpacing;
    if (imageCount > 0) {
      header += imageHeight(imageCount);
      header += imageBodySpacing;
    }

    return math.max(0, available - pageNumArea - header);
  }

  double continuationBodyHeight() {
    final available = pageHeight - (verticalPadding * 2);
    final pageNumArea = 6.0 + pageNumberHeight;
    return math.max(0, available - pageNumArea);
  }

  TextStyle get bodyTextStyle => GoogleFonts.lora(
        fontSize: bodyFontSize,
        height: 1.75,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF4A4037),
      );

  StrutStyle get bodyStrutStyle => StrutStyle(
        fontSize: bodyFontSize,
        height: 1.75,
        forceStrutHeight: true,
      );
}

// ============================================================================
// BOOK PAGINATOR
// ============================================================================

class BookPaginator {
  static List<PageChunk> split({
    required String body,
    required double pageHeight,
    required double pageWidth,
    required String date,
    required String title,
    required int imageCount,
  }) {
    final metrics = BookPageMetrics(
      pageWidth: pageWidth,
      pageHeight: pageHeight,
    );

    final paragraphs = body
        .replaceAll('\r\n', '\n')
        .trim()
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) {
      return [PageChunk(text: '', isLastPage: true)];
    }

    final fullText = paragraphs.join('\n\n');
    final chunks = <PageChunk>[];
    int charOffset = 0;
    bool firstPage = true;

    while (charOffset < fullText.length) {
      final remaining = fullText.substring(charOffset);

      final bodyHeight = firstPage
          ? metrics.firstPageBodyHeight(
              date: date,
              title: title,
              imageCount: imageCount,
            )
          : metrics.continuationBodyHeight();

      final fitCount = _fitCharsByLineMetrics(
        text: remaining,
        maxHeight: bodyHeight,
        metrics: metrics,
      );

      final isLast = fitCount >= remaining.length;
      final chunk = remaining.substring(0, fitCount).trimRight();

      chunks.add(PageChunk(text: chunk, isLastPage: isLast));
      charOffset += fitCount;

      if (!isLast) {
        while (charOffset < fullText.length &&
            (fullText[charOffset] == ' ' ||
                fullText[charOffset] == '\n' ||
                fullText[charOffset] == '\r')) {
          charOffset++;
        }
      }

      firstPage = false;
    }

    if (chunks.isEmpty) {
      return [PageChunk(text: '', isLastPage: true)];
    }

    return chunks;
  }

 static int _fitCharsByLineMetrics({
  required String text,
  required double maxHeight,
  required BookPageMetrics metrics,
}) {
  // ADD THESE 4 LINES
  debugPrint('=== maxHeight: $maxHeight');
  debugPrint('=== pageHeight: ${metrics.pageHeight}');
  debugPrint('=== verticalPadding: ${metrics.verticalPadding}');
  debugPrint('=== pageNumberHeight: ${metrics.pageNumberHeight}');
  if (text.isEmpty || maxHeight <= 0) return 0;

  final paragraphs = text
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  double heightUsed = 0;
  int charsConsumed = 0;
  int originalIndex = 0;

  for (int pi = 0; pi < paragraphs.length; pi++) {
    final para = paragraphs[pi];

    if (pi > 0) {
      final gap = metrics.paragraphSpacing;
      if (heightUsed + gap > maxHeight) {
        return charsConsumed;
      }
      heightUsed += gap;
    }

    final painter = TextPainter(
      text: TextSpan(text: para, style: metrics.bodyTextStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
      strutStyle: metrics.bodyStrutStyle,
    )..layout(maxWidth: metrics.contentWidth);

    // If the whole paragraph fits, take it all
    if (heightUsed + painter.height <=  maxHeight - 8.0) {
      heightUsed += painter.height;
      originalIndex = _advancePast(text, originalIndex, para);
      charsConsumed = originalIndex;
      continue;
    }

    // Paragraph is too tall — find how many lines fit using line metrics
    final lineMetrics = painter.computeLineMetrics();
    if (lineMetrics.isEmpty) {
      originalIndex = _advancePast(text, originalIndex, para);
      charsConsumed = originalIndex;
      continue;
    }

    double lineTop = 0;
    int fittingLineCount = 0;

    for (final line in lineMetrics) {
      if (heightUsed + lineTop + line.height > maxHeight - 8.0) break;
      lineTop += line.height;
      fittingLineCount++;
    }

    if (fittingLineCount == 0) {
      return charsConsumed;
    }

    // Get char position at end of last fitting line
    // Sample point: middle of last fitting line, near right edge
    double sampleY = 0;
    for (int li = 0; li < fittingLineCount; li++) {
      sampleY += lineMetrics[li].height;
    }
    // Move sample point to middle of the last fitting line
    sampleY -= lineMetrics[fittingLineCount - 1].height / 2;

    final position = painter.getPositionForOffset(
      Offset(metrics.contentWidth - 1, sampleY),
    );

    // Walk forward to end of word
    int charOffset = position.offset;
    while (charOffset < para.length &&
        para[charOffset] != ' ' &&
        para[charOffset] != '\n') {
      charOffset++;
    }

    final splitAt = _snapToWordBoundary(para, charOffset);
    final paraStartInText = _findParaStart(text, originalIndex, para);
    return paraStartInText + splitAt;
  }

  return math.min(charsConsumed, text.length);
}

  static int _advancePast(String text, int cursor, String para) {
    final start = text.indexOf(para, cursor);
    if (start == -1) return cursor;
    int end = start + para.length;
    while (end < text.length &&
        (text[end] == ' ' || text[end] == '\n' || text[end] == '\r')) {
      end++;
    }
    return end;
  }

  static int _findParaStart(String text, int cursor, String para) {
    final idx = text.indexOf(para, cursor);
    return idx == -1 ? cursor : idx;
  }

  static int _snapToWordBoundary(String text, int offset) {
    if (offset >= text.length) return text.length;
    int i = offset;
    while (i > 0 && text[i - 1] != ' ' && text[i - 1] != '\n') {
      i--;
    }
    return i == 0 ? offset : i;
  }
}

// ============================================================================
// INTERNAL TYPES
// ============================================================================

class PageChunk {
  final String text;
  final bool isLastPage;
  const PageChunk({required this.text, required this.isLastPage});
}

// ============================================================================
// SINGLE PAGE
// ============================================================================

class SinglePage extends StatelessWidget {
  final String date;
  final String title;
  final String? body;
  final List<String> imagePaths;
  final int? pageNumber;
  final bool isFirstPage;
  final bool isLastPage;
  final double pageWidth;
  final double pageHeight;

  const SinglePage({
    super.key,
    required this.date,
    required this.title,
    this.body,
    this.imagePaths = const [],
    this.pageNumber,
    this.isFirstPage = true,
    this.isLastPage = false,
    required this.pageWidth,
    required this.pageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = BookPageMetrics(
      pageWidth: pageWidth,
      pageHeight: pageHeight,
    );

    final double bodyHeight = isFirstPage
        ? metrics.firstPageBodyHeight(
            date: date,
            title: title,
            imageCount: imagePaths.length,
          )
        : metrics.continuationBodyHeight();

    return Container(
      width: pageWidth,
      height: pageHeight,
      decoration: const BoxDecoration(color: BookColors.parchment),
      child: CustomPaint(
        painter: PageBackgroundPainter(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            pageWidth * 0.08,
            pageHeight * 0.04,
            pageWidth * 0.08,
            pageHeight * 0.04,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                   clipBehavior: Clip.hardEdge,
                  child: PageContent(
                    pageWidth: pageWidth,
                    pageHeight: pageHeight,
                    date: date,
                    title: title,
                    body: body,
                    imagePaths: isFirstPage ? imagePaths : const [],
                    showHeader: isFirstPage,
                    bodyHeight: bodyHeight,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: metrics.pageNumberHeight,
                child: Center(
                  child: pageNumber != null
                      ? Text(
                          '$pageNumber',
                          style: GoogleFonts.ebGaramond(
                            fontSize: metrics.pageNumberFontSize,
                            color: Colors.brown.shade600,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PAGE BACKGROUND
// ============================================================================

class PageBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.1,
      colors: [
        BookColors.parchmentLight.withOpacity(0.72),
        BookColors.parchment.withOpacity(0.94),
        BookColors.parchmentDark.withOpacity(0.42),
      ],
    );
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    canvas.drawRect(
      Rect.fromLTWH(14, 14, size.width - 28, size.height - 28),
      Paint()
        ..color = BookColors.border.withOpacity(0.68)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    canvas.drawRect(
      Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
      Paint()
        ..color = BookColors.gold.withOpacity(0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    _drawCorner(canvas, const Offset(14, 14), false, false);
    _drawCorner(canvas, Offset(size.width - 14, 14), true, false);
    _drawCorner(canvas, Offset(14, size.height - 14), false, true);
    _drawCorner(canvas, Offset(size.width - 14, size.height - 14), true, true);
  }

  void _drawCorner(Canvas canvas, Offset center, bool flipX, bool flipY) {
    final paint = Paint()
      ..color = BookColors.border.withOpacity(0.68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (flipX) canvas.scale(-1, 1);
    if (flipY) canvas.scale(1, -1);

    final path = Path();
    path.moveTo(0, 0);
    path.cubicTo(8, 1, 11, 7, 12, 14);
    path.cubicTo(15, 8, 19, 7, 23, 10);
    path.cubicTo(20, 3, 15, 0, 10, 0);
    canvas.drawPath(path, paint);

    for (int i = 0; i < 4; i++) {
      final p = Path();
      p.moveTo(5 + i * 4.0, 4 + i * 3.0);
      p.quadraticBezierTo(8 + i * 4.0, i * 2.0, 12 + i * 4.0, 4 + i * 3.0);
      canvas.drawPath(p, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// ORNAMENT DIVIDER
// ============================================================================

class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: BookColors.gold.withOpacity(0.48)),
        ),
        const SizedBox(width: 10),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              border: Border.all(
                color: BookColors.gold.withOpacity(0.78),
                width: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1, color: BookColors.gold.withOpacity(0.48)),
        ),
      ],
    );
  }
}