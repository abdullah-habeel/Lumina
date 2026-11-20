import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/features/book_display/widgets/moving_photos_animation.dart';

import 'single_page.dart';

class PageContent extends StatelessWidget {
  final String date;
  final String title;
  final String? body;
  final List<String> imagePaths;
  final bool showHeader;
  final double pageWidth;
  final double pageHeight;
  final double? bodyHeight;

  const PageContent({
    super.key,
    required this.date,
    required this.title,
    this.body,
    this.imagePaths = const [],
    this.showHeader = true,
    required this.pageWidth,
    required this.pageHeight,
    this.bodyHeight,
  });

  static const Color _gold = Color(0xFFB8935F);
  static const Color _headingColor = Color(0xFF33473B);

  // ==========================================================================
  // IMAGE
  // ==========================================================================

  Widget _buildImage(String imagePath, {BoxFit fit = BoxFit.cover}) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
              color: _gold,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.grey),
        ),
      );
    }
    return Image.file(File(imagePath), fit: fit);
  }

  void _showFullImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'full_$imagePath',
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _buildImage(imagePath, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BODY TEXT
  // ==========================================================================

  Widget _buildBodyText(BookPageMetrics metrics) {
    final text = body!;
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final paragraphs = text
        .trim()
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    final style = metrics.bodyTextStyle;
    final strutStyle = metrics.bodyStrutStyle;

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < paragraphs.length; i++) ...[
          Text(
            paragraphs[i].trim(),
            style: style,
            textAlign: TextAlign.left,
            strutStyle: strutStyle,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          ),
          if (i != paragraphs.length - 1)
            SizedBox(height: metrics.paragraphSpacing),
        ],
      ],
    );
  }

  // ==========================================================================
  // SINGLE IMAGE
  // ==========================================================================

  Widget _buildSingleImage(BuildContext context, String imagePath) {
    return FractionallySizedBox(
      widthFactor: 1.0,
      child: GestureDetector(
        onTap: () => _showFullImage(context, imagePath),
        child: Hero(
          tag: 'full_$imagePath',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  border: Border.all(color: AppColors.accentGold, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.82),
                      blurRadius: 14,
                      offset: const Offset(2, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: _buildImage(imagePath),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
              ),
              Positioned(
                top: -7,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 52,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A0A0).withOpacity(0.75),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // POLAROID
  // ==========================================================================

  Widget _buildPolaroid(
    BuildContext context,
    String imagePath,
    Color tapeColor,
    double rotation,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            border: Border.all(color: AppColors.accentGold, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.82),
                blurRadius: 10,
                offset: const Offset(2, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 0.85,
                child: GestureDetector(
                  onTap: () => _showFullImage(context, imagePath),
                  child: Hero(
                    tag: 'full_$imagePath',
                    child: _buildImage(imagePath, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 3),
            ],
          ),
        ),
        Positioned(
          top: -7,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.rotate(
              angle: rotation * 0.3 * (3.14159 / 180),
              child: Container(
                width: 52,
                height: 16,
                decoration: BoxDecoration(color: tapeColor.withOpacity(0.75)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // MULTIPLE IMAGES
  // ==========================================================================

  Widget _buildMultipleImages(BuildContext context) {
    final photos = imagePaths.take(3).toList();
    if (photos.length == 2) return _buildTwoImages(context, photos);

    const rotations = [-6.0, 6.0, -2.0];
    const tapeColors = [
      Color(0xFFE8A0A0),
      Color(0xFF9ECFB0),
      Color(0xFFCDB4DB),
    ];
    const positions = [
      {'left': -0.03, 'top': 0.05, 'width': 0.52},
      {'left': 0.52, 'top': 0.05, 'width': 0.52},
      {'left': 0.21, 'top': 0.48, 'width': 0.52},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final containerHeight = containerWidth * 1.35;
        return SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < photos.length; i++)
                Positioned(
                  left: positions[i]['left']! * containerWidth,
                  top: positions[i]['top']! * containerHeight,
                  width: positions[i]['width']! * containerWidth,
                  child: SwayingPolaroid(
                    duration: Duration(milliseconds: [2800, 3200, 2900][i]),
                    child: Transform.rotate(
                      angle: rotations[i] * (3.14159 / 180),
                      child: _buildPolaroid(
                        context,
                        photos[i],
                        tapeColors[i],
                        rotations[i],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // TWO IMAGES
  // ==========================================================================

  Widget _buildTwoImages(BuildContext context, List<String> photos) {
    const rotations = [-6.0, 6.0];
    const tapeColors = [Color(0xFFE8A0A0), Color(0xFF9ECFB0)];
    const positions = [
      {'left': -0.03, 'top': 0.05, 'width': 0.52},
      {'left': 0.52, 'top': 0.05, 'width': 0.52},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final containerHeight = containerWidth * 0.70;
        return SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < photos.length; i++)
                Positioned(
                  left: positions[i]['left']! * containerWidth,
                  top: positions[i]['top']! * containerHeight,
                  width: positions[i]['width']! * containerWidth,
                  child: SwayingPolaroid(
                    duration: Duration(milliseconds: [2500, 2600][i]),
                    child: Transform.rotate(
                      angle: rotations[i] * (3.14159 / 180),
                      child: _buildPolaroid(
                        context,
                        photos[i],
                        tapeColors[i],
                        rotations[i],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // DIVIDER
  // ==========================================================================

  Widget _buildDivider() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 0.7,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_gold.withOpacity(0), _gold.withOpacity(0.6)],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                border: Border.all(color: _gold.withOpacity(0.7), width: 0.8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 0.7,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_gold.withOpacity(0.6), _gold.withOpacity(0)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final metrics = BookPageMetrics(
      pageWidth: pageWidth,
      pageHeight: pageHeight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ====================================================================
        // HEADER
        // ====================================================================
        if (showHeader) ...[
          Center(
            child: Text(
              date.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: metrics.dateFontSize,
                fontWeight: FontWeight.w400,
                letterSpacing: 2.8,
                color: Colors.brown.shade500,
              ),
            ),
          ),
          SizedBox(height: metrics.dateTitleSpacing),
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                fontSize: metrics.titleFontSize,
                fontWeight: FontWeight.w600,
                height: 1.25,
                letterSpacing: 0.2,
                color: _headingColor,
              ),
            ),
          ),
          SizedBox(height: metrics.titleDividerSpacing),
          _buildDivider(),
          SizedBox(height: metrics.dividerBodySpacing),
          if (imagePaths.isNotEmpty) ...[
            if (imagePaths.length == 1)
              _buildSingleImage(context, imagePaths.first)
            else
              _buildMultipleImages(context),
            SizedBox(height: metrics.imageBodySpacing),
          ],
        ],

        // ====================================================================
        // BODY
        // ====================================================================
        if (body != null && body!.trim().isNotEmpty)
          bodyHeight != null
              ? ClipRect(
                  child: SizedBox(
                    height: bodyHeight,
                    width: metrics.contentWidth,
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxHeight: double.infinity,
                      maxWidth: metrics.contentWidth,
                      child: ClipRect(child: _buildBodyText(metrics)),
                    ),
                  ),
                )
              : _buildBodyText(metrics),
      ],
    );
  }
}
