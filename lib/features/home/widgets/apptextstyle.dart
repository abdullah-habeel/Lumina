import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle greeting = GoogleFonts.fraunces(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle subGreeting = GoogleFonts.nunito(
    fontSize: 15,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
  );

  static TextStyle sectionTitle = GoogleFonts.cormorantGaramond(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle viewAll = GoogleFonts.nunito(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static TextStyle cardTitle = GoogleFonts.cormorantGaramond(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle cardSubtitle = GoogleFonts.lora(
    fontSize: 12,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
  );

  static TextStyle cardDate = GoogleFonts.nunito(
    fontSize: 11,
    color: AppColors.textMuted,
  );

  static TextStyle quote = GoogleFonts.nunito(
    fontSize: 13,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static get chapterCardSubtitle => null;
}
