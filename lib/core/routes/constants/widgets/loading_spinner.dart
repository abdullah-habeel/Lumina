import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        ModalBarrier(dismissible: false, color: Color.fromRGBO(0, 0, 0, 0.35)),
        Center(
          child: CircularProgressIndicator(
            color: AppColors.borderGold,
            strokeWidth: 3,
          ),
        ),
      ],
    );
  }
}
