// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/presentation/providers/location_provider.dart';
import 'package:street_team/presentation/providers/map_provider.dart';
import 'package:street_team/presentation/ui/screens/location_screen.dart';
import 'package:street_team/presentation/ui/screens/organization_screen.dart';
import 'package:street_team/presentation/ui/widgets/map_screen_widgets/search_results_panel.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';
import 'package:street_team/presentation/ui/widgets/shared/feedback_widgets/app_snackbar.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool showCreateActions = false;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  // Search logic for LocationResponse data
  void _onSearchChanged(String value) {
    ref.read(isSearchingProvider.notifier).state = value.trim().isNotEmpty;

    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(locationSearchProvider.notifier).state = value;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapEngine = ref.watch(mapEngineProvider);
    final userLocationAsync = ref.watch(userLocationProvider);

    // Fetching the LocationResponse list
    final locationsAsync = ref.watch(locationsProvider);
    final filteredLocations = ref.watch(filteredLocationsProvider);
    final isSearching = ref.watch(isSearchingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          ref.read(isSearchingProvider.notifier).state = false;
        },
        child: Stack(
          children: [
            //map layer
            Positioned.fill(
              child: userLocationAsync.when(
                data: (userLocation) {
                  return locationsAsync.when(
                    data: (_) {
                      return mapEngine.buildMap(
                        userLocation: userLocation,
                        locations: filteredLocations,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          "Location Error: ${error.toString()}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),

            //search bar
            Positioned(
              top: 60.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  AppButton(
                    onPressed: () => Navigator.pop(context),
                    variant: AppButtonVariant.leadingIcon,
                    icon: Icons.arrow_back_ios_new_rounded,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Container(
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBase,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: _onSearchChanged,
                        style: AppTypography.captionSmall,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: "Search locations...",
                          hintStyle: AppTypography.captionSmall.copyWith(
                            color: AppColors.placeholderText,
                          ),
                          suffixIcon: Icon(
                            Icons.search,
                            color: AppColors.brandPrimary,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 16.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // search results list
            if (isSearching)
              Positioned(
                top: 118.h,
                left: 20.w,
                right: 20.w,
                child: SearchResultsPanel(
                  results: filteredLocations,
                  onSelect: (item) {
                    final loc = item;
                    searchController.text = loc.mapLabel;

                    ref.read(isSearchingProvider.notifier).state = false;
                    FocusScope.of(context).unfocus();

                    mapEngine.goToCoordinates(
                      latitude: loc.latitude,
                      longitude: loc.longitude,
                    );
                  },
                ),
              ),

            //refresh icon
            Positioned(
              bottom: 40.h,
              left: 20.w,
              child: AppButton(
                onPressed: () async {
                  AppSnackbar.show(
                    context: context,
                    message: "Discovering more locations...",
                    variant: SnackbarVariant.warning,
                  );

                  try {
                    await ref
                        .read(otherResultsProvider.notifier)
                        .fetchNextPage();

                    AppSnackbar.show(
                      context: context,
                      message: "New locations added to map",
                      variant: SnackbarVariant.success,
                    );
                  } catch (e) {
                    AppSnackbar.show(
                      context: context,
                      message: " ${e.toString()}",
                      variant: SnackbarVariant.error,
                    );
                  }
                },
                variant: AppButtonVariant.circularIcon,
                icon: Icons.refresh_rounded,
              ),
            ),

            // action buttons
            Positioned(
              bottom: 40.h,
              right: 20.w,
              child: SizedBox(
                width: 250.w,
                height: 200.h,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      right: showCreateActions ? 70 : -90.w,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: showCreateActions ? 1 : 0,
                        child: IgnorePointer(
                          ignoring: !showCreateActions,
                          child: Container(
                            width: 180.w,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundBase,
                              borderRadius: BorderRadius.circular(18.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(30),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppButton(
                                  text: "New Location",
                                  icon: Icons.location_on_outlined,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LocationDetailsScreen(),
                                      ),
                                    );
                                  },
                                  variant: AppButtonVariant.secondary,
                                ),
                                SizedBox(height: 10.h),
                                AppButton(
                                  text: "New Organization",
                                  icon: Icons.business_outlined,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OrganizationScreen(),
                                      ),
                                    );
                                  },
                                  variant: AppButtonVariant.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    //location
                    Positioned(
                      bottom: 70.h,
                      right: 10.h,
                      child: AppButton(
                        onPressed: mapEngine.goToUserLocation,
                        variant: AppButtonVariant.leadingIcon,
                        icon: Icons.my_location,
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: AppButton(
                        onPressed: () {
                          setState(() {
                            showCreateActions = !showCreateActions;
                          });
                        },
                        variant: AppButtonVariant.circularIcon,
                        icon: Icons.add_location_alt_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
