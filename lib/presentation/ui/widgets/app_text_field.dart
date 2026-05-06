import 'package:flutter/material.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';

class AppTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;

  const AppTextField({
    super.key,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      cursorColor: AppColors.brandPrimary,
      cursorWidth: 2.0,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.brandPrimary, width: 1.5),
        ),
        fillColor: AppColors.placeholderText.withAlpha(25),
        hintStyle: AppTypography.captionSmall.copyWith(
          color: AppColors.textSecondary.withAlpha(120),
        ),
      ),
    );
  }
}
