import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';

enum AppButtonVariant { primary, leadingIcon, circularIcon, secondary }

class AppButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;

  const AppButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _PrimaryButton(
          text: text ?? '',
          icon: icon,
          onPressed: onPressed,
          isLoading: isLoading,
          width: width,
          height: height,
          color: color,
          textColor: textColor,
        );

      case AppButtonVariant.leadingIcon:
        return _LeadingIconButton(
          icon: icon ?? Icons.arrow_back,
          onPressed: onPressed,
        );

      case AppButtonVariant.circularIcon:
        return _CircularIconButton(
          icon: icon ?? Icons.add,
          onPressed: onPressed,
          color: color,
        );

      case AppButtonVariant.secondary:
        return _SecondaryButton(
          text: text ?? '',
          onPressed: onPressed,
          color: color,
          textColor: textColor,
        );
    }
  }
}

// primary button
class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.buttonTextPrimary,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 24.sp, color: AppColors.buttonTextPrimary),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.buttonTextPrimary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

//leadin icon
class _LeadingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _LeadingIconButton({required this.icon, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.backgroundBase,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.brandPrimary, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(70),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: onPressed,
          child: Icon(icon, size: 22.sp, color: AppColors.brandPrimary),
        ),
      ),
    );
  }
}

//Circlura icon button
class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _CircularIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 60.w,
        height: 60.w,
        decoration: BoxDecoration(
          color: AppColors.brandPrimary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.buttonTextPrimary, size: 24.sp),
      ),
    );
  }
}

//secondary button

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;

  const _SecondaryButton({
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140.w,
      height: 50.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.buttonTextPrimary,
          ),
        ),
      ),
    );
  }
}
