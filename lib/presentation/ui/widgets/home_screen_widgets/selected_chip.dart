import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';

class SelectedChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const SelectedChip({super.key, required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: Colors.white,
              fontSize: 10.sp,
            ),
          ),
          SizedBox(width: 4.w),
          InkWell(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14.r, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
