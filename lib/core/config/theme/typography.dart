import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:street_team/core/config/theme/app_color.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get captionSmall => GoogleFonts.quicksand(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.placeholderText,
      );

  static TextStyle get titleSmall => GoogleFonts.quicksand(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.quicksand(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.quicksand(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.quicksand(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => GoogleFonts.quicksand(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.buttonTextPrimary
      );
}