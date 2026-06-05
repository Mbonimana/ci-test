import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';

class SyncProgressOverlay extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const SyncProgressOverlay({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  Color _getProgressColor(double progress) {
    final Color startColor = AppColors.brandPrimary;
    final Color midColor = AppColors.brandPrimary;
    final Color endColor = AppColors.brandPrimary;

    if (progress < 0.5) {
      return Color.lerp(startColor, midColor, progress * 2) ?? startColor;
    } else {
      return Color.lerp(midColor, endColor, (progress - 0.5) * 2) ?? endColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = totalPages > 0
        ? (currentPage / totalPages).clamp(0.0, 1.0)
        : 0.0;

    final Color activeColor = _getProgressColor(progress);

    // Baseline string for the text-based progress bar
    const String fullText = "Loading.Please wait...";
    final int totalLength = fullText.length;

    // Calculate how many characters are colored based on the active progress ratio
    final int cutoffIndex = (totalLength * progress).round().clamp(
      0,
      totalLength,
    );

    final String activePart = fullText.substring(0, cutoffIndex);
    final String inactivePart = fullText.substring(cutoffIndex);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(115),
        child: Center(
          child: Material(
            // FIXED: Wrapping inside a transparent Material widget inherits proper typography and removes underlines
            type: MaterialType.transparency,
            child: Container(
              width: 290.w,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Deterministic dynamic-color progress circle
                  SizedBox(
                    width: 32.r,
                    height: 32.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      value: progress,
                      valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          // Progress-colored portion of the text (left side)
                          TextSpan(
                            text: activePart,
                            style: AppTypography.captionSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: activeColor,
                              fontSize: 14.sp,
                            ),
                          ),
                          // Uncompleted portion of the text in solid black (right side)
                          TextSpan(
                            text: inactivePart,
                            style: AppTypography.captionSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
