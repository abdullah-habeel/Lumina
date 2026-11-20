import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────
// ONBOARDING AI SCREEN 1 — "It Reads Between the Lines"
// Hero: a deckled paper card with raw text that animates into tagged chips
// Matches the existing onboarding visual language exactly.
// ─────────────────────────────────────────────────────────────────────────

class OnboardingAiTagsScreen extends StatefulWidget {
  const OnboardingAiTagsScreen({super.key});

  @override
  State<OnboardingAiTagsScreen> createState() =>
      _OnboardingAiTagsScreenState();
}

class _OnboardingAiTagsScreenState extends State<OnboardingAiTagsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..forward();

  // Card fades/scales in
  late final Animation<double> _cardIn = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.0, 0.14, curve: Curves.easeOut),
  );

  // Raw memory text writes in
  static const List<_LineSpec> _lines = [
    _LineSpec(text: 'Had coffee with Sara.', start: 0.14, end: 0.30),
    _LineSpec(text: 'She seemed distant.', start: 0.32, end: 0.46),
    _LineSpec(text: 'First rain of winter.', start: 0.48, end: 0.62),
  ];

  late final List<Animation<double>> _lineWrites = _lines
      .map(
        (l) => CurvedAnimation(
          parent: _ac,
          curve: Interval(l.start, l.end, curve: Curves.easeOut),
        ),
      )
      .toList();

  // Tags appear after text is written
  static const List<_TagSpec> _tags = [
    _TagSpec(label: 'friendship', start: 0.65, end: 0.74),
    _TagSpec(label: 'emotion', start: 0.72, end: 0.80),
    _TagSpec(label: 'season', start: 0.79, end: 0.86),
  ];

  late final List<Animation<double>> _tagFades = _tags
      .map(
        (t) => CurvedAnimation(
          parent: _ac,
          curve: Interval(t.start, t.end, curve: Curves.easeOutBack),
        ),
      )
      .toList();

  // Title and body
  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.87, 0.94, curve: Curves.easeOut),
  );
  late final Animation<double> _bodyFade = CurvedAnimation(
    parent: _ac,
    curve: const Interval(0.93, 1.0, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFFF5ECD3);
    const border = Color(0xFFB49A6A);
    const textColor = Color(0xFF3D2B20);
    const subtextColor = Color(0xFF827057);
    const tagBg = Color(0xFF2B4A3A);
    const tagText = Color(0xFFF0E8D5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Hero card ──────────────────────────────────────────
          AnimatedBuilder(
            animation: _ac,
            builder: (context, _) {
              final cardScale =
                  0.94 + _cardIn.value.clamp(0.0, 1.0) * 0.06;

              return Opacity(
                opacity: _cardIn.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: cardScale,
                  child: Transform.rotate(
                    angle: -0.014,
                    child: _DeckledPaper(
                      fillColor: cardBg,
                      borderColor: border,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formattedDate(),
                              style: const TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 10,
                                color: subtextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Raw text lines writing in
                            for (var i = 0; i < _lines.length; i++)
                              Padding(
                                padding:
                                    EdgeInsets.only(top: i == 0 ? 0 : 6),
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _lineWrites[i]
                                        .value
                                        .clamp(0.0, 1.0),
                                    child: Text(
                                      _lines[i].text,
                                      style: GoogleFonts.lora(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                        height: 1.35,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // AI-generated tag chips appearing
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (var i = 0; i < _tags.length; i++)
                                  Transform.scale(
                                    scale: _tagFades[i]
                                        .value
                                        .clamp(0.0, 1.0),
                                    child: Opacity(
                                      opacity: _tagFades[i]
                                          .value
                                          .clamp(0.0, 1.0),
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: tagBg,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.auto_awesome_rounded,
                                              size: 10,
                                              color: Color(0xFFB8D4C0),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _tags[i].label,
                                              style: GoogleFonts.lora(
                                                fontSize: 11,
                                                color: tagText,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // ── Title ───────────────────────────────────────────────
          FadeTransition(
            opacity: _titleFade,
            child: Text(
              'It Reads Between\nthe Lines',
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B1A14),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Description ─────────────────────────────────────────
          FadeTransition(
            opacity: _bodyFade,
            child: const Text(
              'Write freely. The app quietly finds\n'
              'the meaning you didn\'t spell out.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 14,
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: subtextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class _LineSpec {
  final String text;
  final double start;
  final double end;
  const _LineSpec({required this.text, required this.start, required this.end});
}

class _TagSpec {
  final String label;
  final double start;
  final double end;
  const _TagSpec({required this.label, required this.start, required this.end});
}

// ─────────────────────────────────────────────────────────────────────────
// Shared widgets — copy these from onboarding_edit_screen.dart or extract
// to a shared file. Duplicated here for self-containment.
// ─────────────────────────────────────────────────────────────────────────

class _DeckledPaper extends StatelessWidget {
  final Widget child;
  final Color fillColor;
  final Color borderColor;

  const _DeckledPaper({
    required this.child,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DeckledEdgePainter(
        fillColor: fillColor,
        borderColor: borderColor,
      ),
      child: ClipPath(
        clipper: _DeckledEdgeClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.1,
              colors: [
                fillColor,
                Color.lerp(fillColor, const Color(0xFF6B5032), 0.06)!,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _LinedPaperPainter(
                    color: const Color(0xFF9F835B).withOpacity(0.08),
                    lineHeight: 26,
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _DeckledEdgeClipper extends CustomClipper<Path> {
  const _DeckledEdgeClipper();

  @override
  Path getClip(Size size) {
    const jag = 3.0;
    const step = 14.0;
    Path path = Path();

    void wobbleLine(Offset from, Offset to, double seedOffset) {
      final dx = to.dx - from.dx;
      final dy = to.dy - from.dy;
      final length = (dx.abs() > dy.abs()) ? dx.abs() : dy.abs();
      final steps = (length / step).clamp(2, 60).round();
      for (var i = 1; i <= steps; i++) {
        final t = i / steps;
        final baseX = from.dx + dx * t;
        final baseY = from.dy + dy * t;
        final wobble =
            jag * ((((i + seedOffset) * 12.9898).abs() % 1.0) * 2 - 1);
        final perpX = dy.abs() > dx.abs() ? wobble : 0.0;
        final perpY = dx.abs() > dy.abs() ? wobble : 0.0;
        path.lineTo(baseX + perpX, baseY + perpY);
      }
    }

    final tl = const Offset(0, 0);
    final tr = Offset(size.width, 0);
    final br = Offset(size.width, size.height);
    final bl = Offset(0, size.height);

    path.moveTo(tl.dx, tl.dy);
    wobbleLine(tl, tr, 0);
    wobbleLine(tr, br, 7);
    wobbleLine(br, bl, 13);
    wobbleLine(bl, tl, 21);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> _) => false;
}

class _DeckledEdgePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  const _DeckledEdgePainter(
      {required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = const _DeckledEdgeClipper().getClip(size);
    canvas.drawShadow(
        path.shift(const Offset(0, 5)), const Color(0xFF6B5032), 10, false);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _DeckledEdgePainter old) => false;
}

class _LinedPaperPainter extends CustomPainter {
  final Color color;
  final double lineHeight;
  const _LinedPaperPainter({required this.color, required this.lineHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.7;
    double y = lineHeight * 0.82;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += lineHeight;
    }
  }

  @override
  bool shouldRepaint(covariant _LinedPaperPainter old) =>
      old.color != color || old.lineHeight != lineHeight;
}