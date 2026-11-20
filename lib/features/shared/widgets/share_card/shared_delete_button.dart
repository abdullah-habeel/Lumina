import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';

class SharedDeleteButton extends StatelessWidget {
  const SharedDeleteButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF4E8D3),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderGold.withOpacity(0.75)),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.16),
                blurRadius: 7,
                offset: const Offset(1, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            size: 19,
            color: AppColors.red,
          ),
        ),
      ),
    );
  }
}
