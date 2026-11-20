import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';

class SaveMemoryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final String iconAsset;

  const SaveMemoryButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Save Memory',
    this.backgroundColor = AppColors.primaryGreen,
    this.borderColor = const Color(0xFFB89558),
    this.textColor = AppColors.borderGold,
    this.iconColor = const Color(0xFFB89558),
    this.iconAsset = 'assets/images/feather.png',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shadowColor: Colors.brown.withOpacity(0.15),
          elevation: 3,
          side: BorderSide(color: borderColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.borderGold,
                  strokeWidth: 2,
                ),
              )
            else
              Image.asset(iconAsset, width: 20, height: 20, color: iconColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.cormorantGaramond(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
