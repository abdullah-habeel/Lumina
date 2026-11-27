import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_images.dart';

class TellMyStoryCard extends StatefulWidget {
  final VoidCallback onTap;

  const TellMyStoryCard({
    super.key,
    required this.onTap,
  });

  @override
  State<TellMyStoryCard> createState() => _TellMyStoryCardState();
}

class _TellMyStoryCardState extends State<TellMyStoryCard> {
  bool _pressed = false;

  static const Color cream = Color(0xFFF5E0D8);
  static const Color green = Color(0xFF2F4F41);
  static const Color gold = Color(0xFFC79A4B);
  static const Color brown = Color(0xFF55402C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: PhysicalShape(
          clipper: _StoryCardClipper(),
          color: cream,
          elevation: _pressed ? 2 : 7,
          shadowColor: gold.withOpacity(0.35),
          child: SizedBox(
            width: double.infinity,
            height: 175,
            child: Stack(
              children: [
                // Decorative double border
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StoryBorderPainter(),
                  ),
                ),

                // Right-side flower asset
                Positioned(
                  right: 5,
                  top: 8,
                  bottom: 8,
                  width: 85,
                  child: IgnorePointer(
                    child: Image.asset(
                      AppImages.storycardright,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),

                // Left-side flower asset (mirrored from right)
                Positioned(
                  left: 5,
                  top: 8,
                  bottom: 8,
                  width: 85,
                  child: IgnorePointer(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                      child: Image.asset(
                        AppImages.storycardright,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),

                // Left decorative stars
                Positioned(
                  top: 35,
                  left: 35,
                  child: _star(15),
                ),
                Positioned(
                  top: 58,
                  left: 70,
                  child: _star(9),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 5),

                      // Heading
                      const Text(
                        'Tell My Story',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: brown,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'serif',
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Decorative divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dividerLine(),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.auto_awesome,
                            color: gold,
                            size: 17,
                          ),
                          const SizedBox(width: 12),
                          _dividerLine(),
                        ],
                      ),

                      const SizedBox(height: 13),

                      // Subtitle
                      Text(
                        'See who you are.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: brown.withOpacity(0.85),
                          fontSize: 14,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'serif',
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tap indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: green,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: gold,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tap to explore',
                              style: TextStyle(
                                color: cream,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: cream,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _star(double size) {
    return Icon(
      Icons.auto_awesome,
      size: size,
      color: gold.withOpacity(0.8),
    );
  }

  Widget _dividerLine() {
    return Container(
      width: 36,
      height: 1,
      color: gold.withOpacity(0.75),
    );
  }
}

class _StoryCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _createCardPath(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

Path _createCardPath(Rect rect) {
  final w = rect.width;
  final h = rect.height;
  final x = rect.left;
  final y = rect.top;

  const double r = 18.0;

  return Path()
    ..moveTo(x + r, y)
    ..lineTo(x + w - r, y)
    ..arcToPoint(
      Offset(x + w, y + r),
      radius: const Radius.circular(r),
      clockwise: false,
    )
    ..lineTo(x + w, y + h - r)
    ..arcToPoint(
      Offset(x + w - r, y + h),
      radius: const Radius.circular(r),
      clockwise: false,
    )
    ..lineTo(x + r, y + h)
    ..arcToPoint(
      Offset(x, y + h - r),
      radius: const Radius.circular(r),
      clockwise: false,
    )
    ..lineTo(x, y + r)
    ..arcToPoint(
      Offset(x + r, y),
      radius: const Radius.circular(r),
      clockwise: false,
    )
    ..close();
}

class _StoryBorderPainter extends CustomPainter {
  static const Color gold = Color(0xFFC79A4B);

  @override
  void paint(Canvas canvas, Size size) {
    final outerPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final innerPaint = Paint()
      ..color = gold.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final outerPath = _createCardPath(
      Rect.fromLTWH(
        1.5,
        1.5,
        size.width - 3,
        size.height - 3,
      ),
    );

    final innerPath = _createCardPath(
      Rect.fromLTWH(
        7,
        7,
        size.width - 14,
        size.height - 14,
      ),
    );

    canvas.drawPath(outerPath, outerPaint);
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}