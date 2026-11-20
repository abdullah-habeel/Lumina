import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/utils/notification_dot.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart'; // wherever DaylightTime lives

class ProfileBookStats extends StatelessWidget {
  final int entries;
  final int trusted;
  final int shared;

  const ProfileBookStats({
    super.key,
    required this.entries,
    required this.trusted,
    required this.shared,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2211 / 815,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AppImages.profileStatBook, fit: BoxFit.fill),
              Positioned(
                left: w * 0.15,
                right: w * 0.15,
                top: h * 0.22,
                bottom: h * 0.28,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ProfileStatTile(
                        value: '$entries',
                        label: 'Entries',
                      ),
                    ),
                    _StatDivider(height: h),
                    Expanded(
                      child: ProfileStatTile(
                        value: '$trusted',
                        label: 'Trusted',
                      ),
                    ),
                    _StatDivider(height: h),
                    Expanded(
                      child: ProfileStatTile(value: '$shared', label: 'Shared'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileStatTile extends StatefulWidget {
  final String value;
  final String label;

  const ProfileStatTile({super.key, required this.value, required this.label});

  @override
  State<ProfileStatTile> createState() => _ProfileStatTileState();
}

class _ProfileStatTileState extends State<ProfileStatTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _countAnimation;

  @override
  void initState() {
    super.initState();
    final target = int.tryParse(widget.value) ?? 0;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _countAnimation = IntTween(
      begin: 0,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, _) {
              return Text(
                '${_countAnimation.value}',
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.brown.withOpacity(.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final double height;
  const _StatDivider({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: height * 0.35,
      color: Colors.brown.withOpacity(.25),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showDivider;
  final bool showNotificationDot;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.showDivider = true,
    this.showNotificationDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);

    // If the caller explicitly passed a color (e.g. red for delete,
    // green for "Turn Off PIN"), respect that override. Otherwise
    // fall back to the time-based accent so normal menu items
    // shift with the day.
    final color = iconColor ?? DaylightAppColors.accentGold(hour);
    final resolvedTextColor = textColor ?? DaylightAppColors.headingText(hour);
    final chevronColor = DaylightAppColors.accentGold(hour).withOpacity(0.6);
    final dividerColor = DaylightAppColors.borderGold(hour).withOpacity(0.4);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                NotificationDot(
                  show: showNotificationDot,
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      icon,
                      width: 19,
                      height: 19,
                      colorFilter: ColorFilter.mode(
                        DaylightAppColors.iconColor(hour),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: DaylightAppColors.bookTitleText(hour),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: chevronColor, size: 20),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: dividerColor, indent: 52),
      ],
    );
  }
}

class IconDataMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const IconDataMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final color = DaylightAppColors.accentGold(hour);
    final chevronColor = DaylightAppColors.accentGold(hour).withOpacity(0.6);
    final dividerColor = DaylightAppColors.borderGold(hour).withOpacity(0.4);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: DaylightAppColors.iconColor(hour),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: DaylightAppColors.bookTitleText(hour),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: chevronColor, size: 20),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: dividerColor, indent: 52),
      ],
    );
  }
}
