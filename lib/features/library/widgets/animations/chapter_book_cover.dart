import 'dart:math';
import 'package:flutter/material.dart';

class ChapterBookCover extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Color leatherColor;
  final String? leafAsset;
  final String? illustrationAsset;

  const ChapterBookCover({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.leatherColor,
    this.leafAsset,
    this.illustrationAsset,
  });

  @override
  Widget build(BuildContext context) {
   return DefaultTextStyle(
  style: const TextStyle(
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  child: LayoutBuilder(
    builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final spineW = w * 0.07;
        final pageBlockW = w * 0.045;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.50),
                blurRadius: 35,
                spreadRadius: 2,
                offset: const Offset(8, 16),
              ),
              BoxShadow(
                color: _darken(leatherColor, 0.25).withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BookSpine(width: spineW, color: leatherColor),
                Expanded(
                  child: _FrontCover(
                    number: number,
                    title: title,
                    subtitle: subtitle,
                    leatherColor: leatherColor,
                    leafAsset: leafAsset,
                    height: h,
                  ),
                ),
                _PageBlock(width: pageBlockW),
              ],
            ),
          ),
        );
      },)
    );
  }
}

// ============================================================
// SPINE
// ============================================================
class _BookSpine extends StatelessWidget {
  final double width;
  final Color color;

  const _BookSpine({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _lighten(color, 0.20),
              _lighten(color, 0.06),
              color,
              _darken(color, 0.20),
            ],
            stops: const [0.0, 0.25, 0.60, 1.0],
          ),
        ),
        child: CustomPaint(
  isComplex: true,
  willChange: false,
  painter: _LeatherTexturePainter(seed: color.value),
),
      ),
    );
  }
}

// ============================================================
// FRONT COVER
// ============================================================
class _FrontCover extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Color leatherColor;
  final String? leafAsset;
  final double height;

  const _FrontCover({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.leatherColor,
    required this.height,
    this.leafAsset,
  });

  @override
  Widget build(BuildContext context) {
    final gold = _goldColor(leatherColor);

    return Stack(
      children: [
        // ── BASE LEATHER GRADIENT ──────────────────────────
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _lighten(leatherColor, 0.10),
                  leatherColor,
                  _darken(leatherColor, 0.10),
                  _darken(leatherColor, 0.20),
                ],
                stops: const [0.0, 0.40, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // ── LEATHER TEXTURE ────────────────────────────────
        Positioned.fill(
          child: CustomPaint(
  isComplex: true,
  willChange: false,
  painter: _LeatherTexturePainter(seed: leatherColor.value + 1),
),
        ),

        // ── TOP LIGHT SHEEN ────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: height * 0.30,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ── DOUBLE BORDER FRAME ────────────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CoverBorderPainter(color: gold.withOpacity(0.50)),
            ),
          ),
        ),

        // ── CONTENT ───────────────────────────────────────
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ── TOP ROW: icon + chapter ────────────────
                // ── TOP ROW: chapter only ──────────────────
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'CHAPTER',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 7,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w500,
            color: gold.withOpacity(0.75),
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          number,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 30,
            height: 1,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.92),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ),
  ],
),

                const Spacer(),

                // ── TOP ORNAMENTAL LINE ────────────────────
                _OrnamentalLine(color: gold),

                const SizedBox(height: 22),

                // ── TITLE ──────────────────────────────────
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 28,
                    height: 1.20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── BOTTOM ORNAMENTAL LINE ─────────────────
                _OrnamentalLine(color: gold),

                const SizedBox(height: 16),

                // ── SUBTITLE ───────────────────────────────
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'EBGaramond',
                    fontSize: 14,
                    height: 1.50,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.72),
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.30),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── BOTTOM: publisher line ─────────────────
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            gold.withOpacity(0.60),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'L I F E B O O K',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 7.5,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w500,
                        color: gold.withOpacity(0.60),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ORNAMENTAL LINE — replaces the wing painter, cleaner
// ============================================================
class _OrnamentalLine extends StatelessWidget {
  final Color color;
  const _OrnamentalLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _gradientLine(color),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.55),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.85),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
        _gradientLine(color),
      ],
    );
  }

  Widget _gradientLine(Color color) {
    return Container(
      width: 55,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color.withOpacity(0.80),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COVER BORDER PAINTER
// ============================================================
class _CoverBorderPainter extends CustomPainter {
  final Color color;
  const _CoverBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const outerPad = 9.0;
    canvas.drawRect(
      Rect.fromLTRB(
        outerPad, outerPad,
        size.width - outerPad, size.height - outerPad,
      ),
      outer,
    );

    final inner = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const innerPad = 13.5;
    canvas.drawRect(
      Rect.fromLTRB(
        innerPad, innerPad,
        size.width - innerPad, size.height - innerPad,
      ),
      inner,
    );
  }

  @override
  bool shouldRepaint(covariant _CoverBorderPainter old) =>
      old.color != color;
}

// ============================================================
// PAGE BLOCK
// ============================================================
class _PageBlock extends StatelessWidget {
  final double width;
  const _PageBlock({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(painter: _PageBlockPainter()),
    );
  }
}

class _PageBlockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
   canvas.drawRect(
  Offset.zero & size,
  Paint()..color = const Color(0xFFB8A882),
);
final line = Paint()
  ..color = const Color(0xFF8B7355)
  ..strokeWidth = 0.7;
    for (double x = 1.0; x < size.width; x += 1.3) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    // Top/bottom shadows
    canvas.drawLine(
      Offset.zero, Offset(size.width, 0),
      Paint()..color = Colors.black.withOpacity(0.10)..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(0, size.height), Offset(size.width, size.height),
      Paint()..color = Colors.black.withOpacity(0.10)..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ============================================================
// LEATHER TEXTURE
// ============================================================
class _LeatherTexturePainter extends CustomPainter {
  final int seed;
  const _LeatherTexturePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final dark = Paint()..color = Colors.black.withOpacity(0.05);
    final light = Paint()..color = Colors.white.withOpacity(0.03);
    final count = (size.width * size.height / 8).round();
    for (int i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 0.7 + 0.2,
        rng.nextBool() ? dark : light,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LeatherTexturePainter old) =>
      old.seed != seed;
}

// ============================================================
// COLOR HELPERS
// ============================================================
Color _lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

Color _goldColor(Color leather) {
  return Color.lerp(leather, const Color(0xFFD4A853), 0.72)!;
}