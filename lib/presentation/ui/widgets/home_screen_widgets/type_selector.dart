import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/presentation/providers/home_screen_provider.dart';
import 'package:street_team/presentation/providers/types_provider.dart';

class CategorySelector extends ConsumerStatefulWidget {
  final HomeState stateData;

  const CategorySelector({super.key, required this.stateData});

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.stateData.mode == CategoryMode.organization ? 0 : 1,
    );
  }

  @override
  void didUpdateWidget(covariant CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    final target = widget.stateData.mode == CategoryMode.organization ? 0 : 1;

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(homeProvider.notifier);

    final typeNamesAsync = widget.stateData.mode == CategoryMode.organization
        ? ref.watch(organizationTypeNamesProvider)
        : ref.watch(locationTypeNamesProvider);

    const surfaceGray = Color(0xFFF1F5F9);
    const chipUnselectedGray = Color(0xFFE2E8F0);

    return typeNamesAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text(e.toString()),
      data: (typeMap) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: surfaceGray,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.placeholderText.withAlpha(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //header chips
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: notifier.toggleExpansion,
                child: Row(
                  children: [
                    Expanded(
                      child: widget.stateData.selectedTypes.isEmpty
                          ? Text(
                              "Select types",
                              style: AppTypography.captionSmall.copyWith(
                                color: Colors.blueGrey,
                              ),
                            )
                          : SizedBox(
                              height: 34.h,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: widget.stateData.selectedTypes.map((
                                  id,
                                ) {
                                  final name = typeMap[id] ?? "Unknown";

                                  return Container(
                                    margin: EdgeInsets.only(right: 8.w),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandPrimary,
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          name,
                                          style: AppTypography.labelSmall.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 6.w),

                                        // remove button
                                        GestureDetector(
                                          onTap: () => notifier.toggleType(id),
                                          child: Icon(
                                            Icons.close,
                                            size: 14.r,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                    Icon(
                      widget.stateData.isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.brandPrimary,
                    ),
                  ],
                ),
              ),

              // expand
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: widget.stateData.isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    SizedBox(height: 12.h),

                    // tabs
                    Container(
                      height: 42.h,
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBase,
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: Colors.black.withAlpha(10)),
                      ),
                      child: Row(
                        children: [
                          _Tab(
                            title: "Organizations",
                            active:
                                widget.stateData.mode ==
                                CategoryMode.organization,
                            onTap: () =>
                                notifier.switchMode(CategoryMode.organization),
                          ),
                          _Tab(
                            title: "Locations",
                            active:
                                widget.stateData.mode == CategoryMode.location,
                            onTap: () =>
                                notifier.switchMode(CategoryMode.location),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // chip grid
                    SizedBox(
                      height: 320.h,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (i) {
                          notifier.switchMode(
                            i == 0
                                ? CategoryMode.organization
                                : CategoryMode.location,
                          );
                        },
                        children: [
                          _Grid(
                            types: widget.stateData.types,
                            selected: widget.stateData.selectedTypes,
                            typeMap: typeMap,
                            onToggle: notifier.toggleType,
                            chipColor: chipUnselectedGray,
                          ),
                          _Grid(
                            types: widget.stateData.types,
                            selected: widget.stateData.selectedTypes,
                            typeMap: typeMap,
                            onToggle: notifier.toggleType,
                            chipColor: chipUnselectedGray,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// tab
class _Tab extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.title, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? AppColors.brandPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: active ? Colors.white : AppColors.brandSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//chip grid
class _Grid extends StatelessWidget {
  final List<int> types;
  final List<int> selected;
  final Map<int, String> typeMap;
  final Function(int) onToggle;
  final Color chipColor;

  const _Grid({
    required this.types,
    required this.selected,
    required this.typeMap,
    required this.onToggle,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(10.r),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3.2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 10.h,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final id = types[index];
        final name = typeMap[id] ?? "Unknown";
        final isSelected = selected.contains(id);

        return GestureDetector(
          onTap: () => onToggle(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandPrimary : chipColor,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : AppColors.textPrimary.withAlpha(200),
              ),
            ),
          ),
        );
      },
    );
  }
}
