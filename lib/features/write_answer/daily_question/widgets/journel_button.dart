import 'package:flutter/material.dart';

import 'package:lumina/core/routes/constants/app_colors.dart';

/// Full-width dark-green pill button with a leading icon — used for both
/// "Write Your Answer" (question screen) and "Save Memory" (answer screen).
class JournalButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const JournalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.mode_edit_outline,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
