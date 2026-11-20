import 'package:flutter/material.dart';
import 'package:lumina/features/auth/widgets/auth_constants.dart';

class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(color: AuthColors.divider, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: const TextStyle(
                  color: AuthColors.textMuted,
                  fontSize: 13,
                  fontFamily: 'Lora',
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AuthColors.divider, thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(icon: _googleIcon(), onTap: () {}),
            const SizedBox(width: 16),
            _SocialButton(
              icon: const Icon(Icons.apple, size: 26, color: Color(0xFF1A1A1A)),
              onTap: () {},
            ),
            const SizedBox(width: 16),
            _SocialButton(icon: _facebookIcon(), onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _googleIcon() {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }

  Widget _facebookIcon() {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        height: 52,
        decoration: BoxDecoration(
          color: AuthColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AuthColors.borderColor, width: 1.2),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    _arc(canvas, cx, cy, r, -0.52, 2.1, const Color(0xFF4285F4));
    _arc(canvas, cx, cy, r, 3.6, 0.9, const Color(0xFFEA4335));
    _arc(canvas, cx, cy, r, 2.18, 1.4, const Color(0xFFFBBC05));
    _arc(canvas, cx, cy, r, 4.45, 0.75, const Color(0xFF34A853));

    canvas.drawCircle(Offset(cx, cy), r * 0.55, Paint()..color = Colors.white);

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.95, cy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = size.width * 0.2
        ..strokeCap = StrokeCap.square,
    );
  }

  void _arc(
    Canvas c,
    double cx,
    double cy,
    double r,
    double start,
    double sweep,
    Color color,
  ) {
    c.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.775),
      start,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.45,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
