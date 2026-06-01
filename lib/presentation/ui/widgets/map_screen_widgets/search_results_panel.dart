import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/data/models/location_models/location_response.dart';

class SearchResultsPanel extends StatelessWidget {
  const SearchResultsPanel({
    super.key,
    required this.results,
    required this.onSelect,
  });

  final List<LocationResponse> results;
  final Function(LocationResponse location) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 320.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundBase,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: results.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: results.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: Colors.black.withValues(alpha: 0.04),
              ),
              itemBuilder: (context, index) {
                final location = results[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 18.r,
                    backgroundColor: AppColors.brandPrimary.withValues(
                      alpha: 0.1,
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.brandPrimary,
                      size: 18.r,
                    ),
                  ),
                  title: Text(
                    location.mapLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.captionSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "${location.physicalAddress} • ${location.primaryTypeName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.placeholderText,
                      fontSize: 10.sp,
                    ),
                  ),
                  onTap: () => onSelect(location),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 32.r,
            color: AppColors.placeholderText,
          ),
          SizedBox(height: 12.h),
          Text(
            "No results found",
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.placeholderText,
            ),
          ),
        ],
      ),
    );
  }
}
