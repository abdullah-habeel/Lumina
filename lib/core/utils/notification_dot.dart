import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';

class NotificationDot extends StatelessWidget {
  final Widget child;
  final bool show;

  const NotificationDot({super.key, required this.child, required this.show});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (show)
          Positioned(
            right: -3,
            top: -3,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
