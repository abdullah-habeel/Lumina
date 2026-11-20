import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/notification/controller/notification_controller.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Testing only.
  final double? debugOverrideHour;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.debugOverrideHour,
  });

  static const Color _activeColor = AppColors.primaryGreen;
  static const Color _inactiveColor = AppColors.primaryGreen;

  @override
  Widget build(BuildContext context) {
    final sharedController = Get.find<SharedController>();
    final notificationsController = Get.find<NotificationsController>();

    final hour =
        debugOverrideHour ?? DaylightDebug.hour ?? DaylightTime.of(context);

    final background = DaylightAppColors.cardBackground(hour);
    final border = DaylightAppColors.borderGold(hour);

    return Obx(() {
      final hasRequests = sharedController.incomingRequests.isNotEmpty;

      final hasUnreadNotifications = notificationsController.items.any(
        (item) => !notificationsController.isRead(item.id),
      );

      return SafeArea(
        top: false,
        child: _OrganicBottomNavigation(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: background,
          borderColor: border,
          activeColor: _activeColor,
          inactiveColor: _inactiveColor,
          showSharedBadge: hasRequests,
          showProfileBadge: hasUnreadNotifications,
        ),
      );
    });
  }
}

// ============================================================
// ORGANIC BOTTOM NAVIGATION
// ============================================================

class _OrganicBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;

  final bool showSharedBadge;
  final bool showProfileBadge;
  final Color borderColor;

  const _OrganicBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    required this.borderColor,
    required this.backgroundColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.showSharedBadge,
    required this.showProfileBadge,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ------------------------------------------------
              // MAIN PAPER BAR
              // ------------------------------------------------
              Positioned(
                left: 8,
                right: 8,
                bottom: 5,
                height: 82,
                child: CustomPaint(
                  painter: _OrganicNavPainter(
                    backgroundColor: backgroundColor,
                    borderColor: borderColor,
                  ),
                ),
              ),

              // ------------------------------------------------
              // NAVIGATION ITEMS
              // ------------------------------------------------
              Positioned(
                left: 17,
                right: 17,
                bottom: 10,
                height: 72,
                child: Row(
                  children: [
                    Expanded(
                      child: _NavButton(
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home,
                        label: 'Home',
                        selected: currentIndex == 0,
                        color: currentIndex == 0 ? activeColor : inactiveColor,
                        onTap: () => onTap(0),
                        badge: false,
                      ),
                    ),

                    Expanded(
                      child: _NavButton(
                        icon: Icons.eco_outlined,
                        selectedIcon: Icons.eco,
                        label: 'Shared',
                        selected: currentIndex == 1,
                        color: currentIndex == 1 ? activeColor : inactiveColor,
                        onTap: () => onTap(1),
                        badge: showSharedBadge,
                      ),
                    ),

                    // Space occupied by raised center button.
                    SizedBox(width: math.min(76, width * 0.19)),

                    Expanded(
                      child: _NavButton(
                        icon: Icons.bookmark_outline,
                        selectedIcon: Icons.bookmark,
                        label: 'Library',
                        selected: currentIndex == 3,
                        color: currentIndex == 3 ? activeColor : inactiveColor,
                        onTap: () => onTap(3),
                        badge: false,
                      ),
                    ),

                    Expanded(
                      child: _NavButton(
                        icon: Icons.person_outline,
                        selectedIcon: Icons.person,
                        label: 'Profile',
                        selected: currentIndex == 4,
                        color: currentIndex == 4 ? activeColor : inactiveColor,
                        onTap: () => onTap(4),
                        badge: showProfileBadge,
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // CENTER RAISED BUTTON
              // ------------------------------------------------
              Positioned(
                top: 25,
                left: (width / 2) - 33,
                child: _CenterNavButton(
                  selected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// NAV ITEM
// ============================================================

class _NavButton extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final bool badge;

  const _NavButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  selected ? selectedIcon : icon,
                  key: ValueKey(selected),
                  size: 23,
                  color: color,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  height: 1,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),

          if (badge)
            Positioned(
              top: 9,
              right: 19,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// CENTER BUTTON
// ============================================================

class _CenterNavButton extends StatefulWidget {
  final bool selected;
  final VoidCallback onTap;

  const _CenterNavButton({required this.selected, required this.onTap});

  @override
  State<_CenterNavButton> createState() => _CenterNavButtonState();
}

class _CenterNavButtonState extends State<_CenterNavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _press() async {
    await _controller.reverse();
    await _controller.forward();

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: GestureDetector(
        onTap: _press,
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,

            // Deep vintage green
            color: const Color(0xFF31563F),

            border: Border.all(color: const Color(0xFFE5D7B8), width: 3),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),

              // Light ring around the button
              BoxShadow(
                color: const Color(0xFFF3E8CD).withOpacity(0.8),
                blurRadius: 2,
                spreadRadius: 1,
              ),
            ],
          ),

          child: Center(
            child: Icon(Icons.add, size: 28, color: const Color(0xFFE7DEC6)),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOM PAINTER
// ============================================================

class _OrganicNavPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;

  _OrganicNavPainter({
    required this.backgroundColor,
    required this.borderColor,
  });

  // ---- tweak these to change the look ----
  static const double _top = 4; // baseline of the top edge (sides)
  static const double _peak = -16; // hump height (button sits inside it)
  static const double _halfHump = 64; // half-width of the hump
  static const double _corner = 24; // rounded end radius
  static const double _waveAmp = 4; // crest height on the sides
  static const double _valley = 9; // dip beside the hump

  void _topEdge(Path p, double w, double dy) {
    final cx = w / 2;
    final top = _top + dy;
    final peak = _peak + dy;

    double lastY = top;

    // Smooth S-curve step with horizontal tangents at both ends.
    void seg(double x0, double x1, double y1) {
      final d = (x1 - x0) * .5;
      p.cubicTo(x0 + d, lastY, x1 - d, y1, x1, y1);
      lastY = y1;
    }

    final span = (cx - _halfHump) - _corner;

    // Left side profile (your version: curl back to the corner)
    const ts = [0.0, 0.30, 0.0];
    const ys = [0.0, -_waveAmp, _valley];

    // Left side (corner -> crest -> curl back down)
    for (int i = 1; i < ts.length; i++) {
      seg(_corner + span * ts[i - 1], _corner + span * ts[i], top + ys[i]);
    }

    // Left half of the hump
    seg(cx - _halfHump, cx, peak);

    // Right half of the hump: comes down to the far right at the valley height
    p.cubicTo(
      cx + _halfHump / 2,
      peak,
      cx + _halfHump / 2,
      top + _valley,
      w - _corner,
      top + _valley,
    );
    lastY = top + _valley;

    // Right curl: mirror of the left (valley -> crest -> corner)
    final crestX = w - (_corner + span * ts[1]);
    seg(w - _corner, crestX, top - _waveAmp);
    seg(crestX, w - _corner, top);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const r = _corner;
    final bottom = h - 3;

    // ---------------- MAIN SHAPE ----------------
    final path = Path()..moveTo(r, _top);
    _topEdge(path, w, 0);

    // Right rounded end
    path.arcTo(
      Rect.fromCircle(center: Offset(w - r, _top + r), radius: r),
      -math.pi / 2,
      math.pi / 2,
      false,
    );
    path.lineTo(w, bottom - r);
    path.arcTo(
      Rect.fromCircle(center: Offset(w - r, bottom - r), radius: r),
      0,
      math.pi / 2,
      false,
    );

    // Soft bottom edge (very subtle wave)
    path.cubicTo(w * .78, bottom + 1.5, w * .62, bottom - 1.5, w * .5, bottom);
    path.cubicTo(w * .38, bottom + 1.5, w * .22, bottom - 1.5, r, bottom);

    // Left rounded end
    path.arcTo(
      Rect.fromCircle(center: Offset(r, bottom - r), radius: r),
      math.pi / 2,
      math.pi / 2,
      false,
    );
    path.lineTo(0, _top + r);
    path.arcTo(
      Rect.fromCircle(center: Offset(r, _top + r), radius: r),
      math.pi,
      math.pi / 2,
      false,
    );
    path.close();

    // ---------------- SHADOW ----------------
    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withOpacity(0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // ---------------- PAPER FILL ----------------
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(backgroundColor, Colors.white, 0.12) ?? backgroundColor,
        backgroundColor,
        Color.lerp(backgroundColor, const Color(0xFFD7C59F), 0.12) ??
            backgroundColor,
      ],
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(0, _peak, w, h - _peak)),
    );

    // ---------------- TEXTURE + HIGHLIGHT (clipped to shape) ----------------
    canvas.save();
    canvas.clipPath(path);
    _drawPaperTexture(canvas, size);

    final highlight = Path()..moveTo(r, _top + 4);
    _topEdge(highlight, w, 4);
    canvas.drawPath(
      highlight,
      Paint()
        ..color = const Color(0xFFF8EED9).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.restore();

    // ---------------- BORDER ----------------
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawPaperTexture(Canvas canvas, Size size) {
    final random = math.Random(72);
    final paint = Paint()
      ..color = const Color(0xFF8E7D5D).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 170; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 0.65 + 0.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrganicNavPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.borderColor != borderColor;
}
