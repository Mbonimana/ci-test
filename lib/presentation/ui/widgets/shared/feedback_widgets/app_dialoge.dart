import 'package:flutter/material.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';

class AppDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? message,
    Widget? customContent,
    String? confirmText,
    bool showCancel = true,
    IconData? icon,
    Color? iconColor,
    AppButtonVariant confirmVariant = AppButtonVariant.primary,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        //Dialog
        return AlertDialog(
          backgroundColor: AppColors.backgroundBase,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),

          //Title
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 40, color: iconColor ?? Colors.lightBlue),
                const SizedBox(height: 12),
              ],
              Text(title, style: AppTypography.titleMedium),
            ],
          ),

          //eneble scrolling for content if message is too long
          content: SingleChildScrollView(
            child:
                customContent ??
                (message != null
                    ? Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : const SizedBox.shrink()),
          ),

          // buttons
          actions: [
            Row(
              children: [
                if (showCancel) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onConfirm != null) onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),

                      backgroundColor: AppColors.brandPrimaryLight.withAlpha(
                        70,
                      ),

                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      textStyle: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      confirmText ?? "OK",
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.statusError,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
