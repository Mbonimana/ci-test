import 'package:flutter/material.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';

class AppFormLable extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AppFormLable({super.key, this.text, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      style: AppTypography.titleSmall.copyWith(color: AppColors.brandSecondary),
      textAlign: textAlign,
    );
  }
}
