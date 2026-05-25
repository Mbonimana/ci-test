import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/presentation/providers/home_screen_provider.dart';
import 'package:street_team/presentation/providers/organization_type_provider.dart';
import 'package:street_team/presentation/ui/widgets/home_screen_widgets/selected_chip.dart';

class CategorySelector extends ConsumerWidget {
  final HomeState stateData;

  const CategorySelector({super.key, required this.stateData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(homeProvider.notifier);

    final typeNamesAsync = ref.watch(organizationTypeNamesProvider);

    const Color surfaceGray = Color(0xFFF1F5F9);
    const Color chipUnselectedGray = Color(0xFFE2E8F0);

    return typeNamesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text("Error loading types")),
      data: (typeMap) {
        return Column(
          children: [
            GestureDetector(
              onTap: () => notifier.toggleExpansion(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: surfaceGray,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.placeholderText.withAlpha(40),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: stateData.selectedTypes.isEmpty
                          ? Text(
                              "Select types",
                              style: AppTypography.captionSmall.copyWith(
                                color: Colors.blueGrey,
                              ),
                            )
                          : SizedBox(
                              height: 30.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: stateData.selectedTypes.length,
                                separatorBuilder: (_, _) =>
                                    SizedBox(width: 8.w),
                                itemBuilder: (context, i) {
                                  final int typeId = stateData.selectedTypes[i];

                                  final String categoryName =
                                      typeMap[typeId] ?? "Unknown";

                                  return SelectedChip(
                                    label: categoryName,
                                    onRemove: () {
                                      notifier.toggleType(typeId);
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                    Icon(
                      stateData.isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.brandPrimary,
                      size: 24.r,
                    ),
                  ],
                ),
              ),
            ),

            if (stateData.isExpanded) ...[
              SizedBox(height: 10.h),
              Container(
                constraints: BoxConstraints(maxHeight: 280.h),
                decoration: BoxDecoration(
                  color: surfaceGray,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GridView.builder(
                  padding: EdgeInsets.all(12.r),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 3.0,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 10.h,
                  ),
                  itemCount: stateData.types.length,
                  itemBuilder: (context, index) {
                    final int typeId = stateData.types[index];

                    final String typeName = typeMap[typeId] ?? "Unknown";

                    final isSelected = stateData.selectedTypes.contains(typeId);

                    return GestureDetector(
                      onTap: () {
                        notifier.toggleType(typeId);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandPrimary
                              : chipUnselectedGray,
                          borderRadius: BorderRadius.circular(30.r),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.black.withAlpha(10)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            typeName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary.withAlpha(200),
                              fontSize: 10.sp,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
