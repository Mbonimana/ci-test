// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/core/routing/route_names.dart';
import 'package:street_team/data/services/location_capture_service.dart';
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
  bool _isPermissionGranted = false;

  // Use a sensible default center coordinate (e.g. Kigali) if GPS hasn't loaded yet
  static const _fallbackLocation = geo.LatLng(-1.9441, 30.0619);

  @override
  void initState() {
    super.initState();
    // Request permission and fetch user location right after the first frame builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionAndCenter();
    });
  }

  Future<void> _requestPermissionAndCenter() async {
    //  check  app's persistent cache
    final cachedLoc = await LocationCache.getCachedLocation();
    if (cachedLoc != null && mounted) {
      final mapEngine = ref.read(mapEngineProvider);
      mapEngine.goToCoordinates(
        latitude: cachedLoc.latitude,
        longitude: cachedLoc.longitude,
        zoom: 18,
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      if (mounted) {
        setState(() {
          _isPermissionGranted = true;
        });
      }
      ref.invalidate(userLocationProvider);
    }
  }

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

    final filteredLocations = ref.watch(filteredLocationsProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final searchResultsAsync = ref.watch(remoteSearchResultsProvider);

    // Watch for location updates to fly the map camera to the target coordinates smoothly
    ref.listen<AsyncValue<geo.LatLng>>(userLocationProvider, (previous, next) {
      next.whenData((latLng) {
        if (mounted) {
          setState(() {
            _isPermissionGranted = true;
          });
          mapEngine.goToCoordinates(
            latitude: latLng.latitude,
            longitude: latLng.longitude,
            zoom: 18,
          );
        }
      });
    });

    final currentCoordinates =
        userLocationAsync.asData?.value ?? _fallbackLocation;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundBase,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          ref.read(isSearchingProvider.notifier).state = false;
        },
        child: Stack(
          children: [
            // Map builds immediately with whatever coordinate is available
            Positioned.fill(
              child: mapEngine.buildMap(
                userLocation: currentCoordinates,
                locations: filteredLocations,
              ),
            ),

            // Optional non-blocking loading indicator shown while fetching location
            if (userLocationAsync.isLoading &&
                userLocationAsync.asData?.value == null)
              const Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text("Acquiring GPS Signal..."),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Main UI overlays
            Positioned.fill(
              child: SafeArea(
                child: Stack(
                  children: [
                    // Search Bar
                    Positioned(
                      top: 16.h,
                      left: 20.w,
                      right: 20.w,
                      child: Row(
                        children: [
                          AppButton(
                            onPressed: () {
                              context.go(RouteNames.home);
                            },
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
                                  hintStyle: AppTypography.captionSmall
                                      .copyWith(
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

                    // Search Results Panel
                    if (isSearching)
                      Positioned(
                        top: 74.h,
                        left: 20.w,
                        right: 20.w,
                        child: searchResultsAsync.when(
                          data: (results) => SearchResultsPanel(
                            results: results,
                            onSelect: (item) {
                              final loc = item;
                              searchController.text = loc.mapLabel;

                              ref
                                  .read(otherResultsProvider.notifier)
                                  .injectLocation(loc);

                              ref.read(isSearchingProvider.notifier).state =
                                  false;
                              FocusScope.of(context).unfocus();

                              mapEngine.goToCoordinates(
                                latitude: loc.latitude,
                                longitude: loc.longitude,
                                zoom: 20,
                              );
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
                            results: const [],
                            onSelect: (_) {},
                          ),
                        ),
                      ),

                    // Sync/Refresh Button
                    Positioned(
                      bottom: 48.h,
                      left: 20.w,
                      child: AppButton(
                        onPressed: () async {
                          AppSnackbar.show(
                            context: context,
                            message: "Syncing latest map data...",
                            variant: SnackbarVariant.warning,
                          );
                          try {
                            await ref
                                .read(initialSyncProvider.notifier)
                                .syncModifiedData();

                            AppSnackbar.show(
                              context: context,
                              message: "Sync complete. Map data is up to date.",
                              variant: SnackbarVariant.success,
                            );
                          } catch (e) {
                            AppSnackbar.show(
                              context: context,
                              message: "Sync failed. Please check connection.",
                              variant: SnackbarVariant.error,
                            );
                          }
                        },
                        variant: AppButtonVariant.circularIcon,
                        icon: Icons.refresh_rounded,
                      ),
                    ),

                    // Action buttons
                    Positioned(
                      bottom: 20.h,
                      right: 20.w,
                      child: SizedBox(
                        width: 250.w,
                        height: 200.h,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            //
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
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        if (showCreateActions) {
                                          setState(
                                            () => showCreateActions = false,
                                          );
                                        }
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AppButton(
                                            text: "New Location",
                                            icon: Icons.location_on_outlined,
                                            onPressed: () {
                                              setState(
                                                () => showCreateActions = false,
                                              );

                                              ref
                                                  .read(
                                                    locationFormProvider
                                                        .notifier,
                                                  )
                                                  .resetFormState();
                                              ref
                                                      .read(
                                                        pickedLocationProvider
                                                            .notifier,
                                                      )
                                                      .state =
                                                  null;

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
                                              setState(
                                                () => showCreateActions = false,
                                              );

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
                            ),

                            // GPS Button
                            Positioned(
                              bottom: 80.h,
                              right: 10.h,
                              child: Opacity(
                                opacity: _isPermissionGranted ? 1.0 : 0.5,
                                child: AppButton(
                                  onPressed: () async {
                                    LocationPermission permission =
                                        await Geolocator.checkPermission();

                                    if (permission ==
                                        LocationPermission.denied) {
                                      permission =
                                          await Geolocator.requestPermission();
                                    }

                                    if (permission ==
                                        LocationPermission.deniedForever) {
                                      if (mounted) {
                                        _showPermissionDeniedDialog();
                                      }
                                    } else if (permission ==
                                            LocationPermission.whileInUse ||
                                        permission ==
                                            LocationPermission.always) {
                                      setState(
                                        () => _isPermissionGranted = true,
                                      );

                                      // Triggers loading state in Riverpod without unmounting the Map
                                      ref.invalidate(userLocationProvider);

                                      try {
                                        final currentPosition =
                                            await Geolocator.getCurrentPosition(
                                              locationSettings:
                                                  const LocationSettings(
                                                    accuracy:
                                                        LocationAccuracy.high,
                                                    timeLimit: Duration(
                                                      seconds: 10,
                                                    ),
                                                  ),
                                            );

                                        mapEngine.goToCoordinates(
                                          latitude: currentPosition.latitude,
                                          longitude: currentPosition.longitude,
                                          zoom: 18,
                                        );
                                      } catch (e) {
                                        AppSnackbar.show(
                                          context: context,
                                          message:
                                              "Failed to fetch GPS coordinates.",
                                          variant: SnackbarVariant.error,
                                        );
                                      }
                                    }
                                  },
                                  variant: AppButtonVariant.leadingIcon,
                                  icon: Icons.my_location,
                                ),
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
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Location Required"),
        content: const Text(
          "Location permissions are permanently denied. Please enable location permissions in your system settings to find your position.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
