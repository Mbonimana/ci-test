import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';

enum SnackbarVariant { success, warning, error }

class AppSnackbar {
  AppSnackbar._();

  static void show({
    required BuildContext context,
    required String message,
    required SnackbarVariant variant,
  }) {
    final config = _getVariantConfig(variant);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 20.h),
          duration: const Duration(seconds: 3),

          content: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            tween: Tween(begin: 40, end: 0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: config.backgroundColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),

                  Expanded(
                    child: Text(
                      message,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.backgroundBase,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  static _SnackbarConfig _getVariantConfig(SnackbarVariant variant) {
    switch (variant) {
      case SnackbarVariant.success:
        return _SnackbarConfig(backgroundColor: AppColors.success);

      case SnackbarVariant.warning:
        return _SnackbarConfig(backgroundColor: AppColors.warning);

      case SnackbarVariant.error:
        return _SnackbarConfig(backgroundColor: AppColors.error);
    }
  }
}

class _SnackbarConfig {
  final Color backgroundColor;

  const _SnackbarConfig({required this.backgroundColor});
}
