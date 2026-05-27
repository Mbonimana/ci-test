// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/presentation/providers/location_provider.dart';
import 'package:street_team/presentation/providers/map_provider.dart';
import 'package:street_team/presentation/ui/widgets/map_screen_widgets/search_results_panel.dart'; // Ensure this path is correct
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

    final locationsAsync = ref.watch(locationsProvider);
    final filteredLocations = ref.watch(filteredLocationsProvider);
    final isSearching = ref.watch(isSearchingProvider);

    final searchResultsAsync = ref.watch(remoteSearchResultsProvider);

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
            // Map Layer
            Positioned.fill(
              child: userLocationAsync.when(
                data: (userLocation) => locationsAsync.when(
                  data: (_) => mapEngine.buildMap(
                    userLocation: userLocation,
                    locations: filteredLocations,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text("Error: $error")),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),

            // Search Bar
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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results Panel (Asynchronous)
            if (isSearching)
              Positioned(
                top: 118.h,
                left: 20.w,
                right: 20.w,
                child: searchResultsAsync.when(
                  data: (results) => SearchResultsPanel(
                    results: results, // Pass the backend results here
                    onSelect: (item) {
                      final loc = item;
                      searchController.text = loc.mapLabel;

                      // 1. Inject this location into the map's data source provider immediately
                      // This ensures the icon appears on the map even if it wasn't there before
                      ref
                          .read(otherResultsProvider.notifier)
                          .injectLocation(loc);

                      ref.read(isSearchingProvider.notifier).state = false;
                      FocusScope.of(context).unfocus();

                      // 2. Move camera to the location
                      mapEngine.goToCoordinates(
                        latitude: loc.latitude,
                        longitude: loc.longitude,
                        zoom: 16, // Zoom in close so they see the icon
                      );

                      // 3. Automatically open the detail sheet
                     
                    },
                  ),
                  loading: () => Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBase,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (err, _) => SearchResultsPanel(
                    results: const [], // Show "No results" on error
                    onSelect: (_) {},
                  ),
                ),
              ),

            // Refresh Button
            Positioned(
              bottom: 40.h,
              left: 20.w,
              child: AppButton(
                onPressed: () async {
                  AppSnackbar.show(
                    context: context,
                    message: "Discovering...",
                    variant: SnackbarVariant.warning,
                  );
                  try {
                    await ref
                        .read(otherResultsProvider.notifier)
                        .fetchNextPage();
                  } catch (e) {
                    AppSnackbar.show(
                      context: context,
                      message: e.toString(),
                      variant: SnackbarVariant.error,
                    );
                  }
                },
                variant: AppButtonVariant.circularIcon,
                icon: Icons.refresh_rounded,
              ),
            ),

            // Action FAB (Add Location/Org)
            Positioned(bottom: 40.h, right: 20.w, child: _buildActionButtons()),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // ... logic for showCreateActions remains same as your original snippet ...
    return SizedBox(
      width: 250.w,
      height: 200.h,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // (Keep your existing AnimatedPositioned and FAB code here)
          // ...
        ],
      ),
    );
  }
}
