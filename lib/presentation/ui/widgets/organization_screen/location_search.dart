// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/data/models/location_models/location_response.dart';
import 'package:street_team/data/repositories/location_repository.dart';
import 'package:street_team/presentation/providers/location_provider.dart'
    show locationRepoProvider;
import 'package:street_team/presentation/ui/screens/location_screen.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_text_field.dart';

// state model
class LocationSearchState {
  final String query;
  final LocationResponse? selectedLocation;
  final List<LocationResponse> results;
  final bool isSearching;
  final bool isLoading;
  final String? error;

  LocationSearchState({
    this.query = '',
    this.selectedLocation,
    this.results = const [],
    this.isSearching = false,
    this.isLoading = false,
    this.error,
  });

  LocationSearchState copyWith({
    String? query,
    LocationResponse? selectedLocation,
    List<LocationResponse>? results,
    bool? isSearching,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return LocationSearchState(
      query: query ?? this.query,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// notifier
class LocationSearchNotifier extends StateNotifier<LocationSearchState> {
  final LocationRepository repo;

  LocationSearchNotifier(this.repo) : super(LocationSearchState());

  Timer? _debounce;

  void onQueryChanged(String query) {
    state = state.copyWith(
      query: query,
      selectedLocation: null,
      isSearching: true,
      isLoading: true,
      clearError: true,
    );

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final normalizedQuery = query.trim();

      if (normalizedQuery.length < 2) {
        state = state.copyWith(
          results: [],
          isSearching: false,
          isLoading: false,
          clearError: true,
        );
        return;
      }

      try {
        final results = await repo.searchLocations(normalizedQuery);
        state = state.copyWith(
          results: results,
          isSearching: true,
          isLoading: false,
          clearError: true,
        );
      } catch (e) {
        state = state.copyWith(
          results: [],
          isSearching: true,
          isLoading: false,
          error: e.toString(),
        );
      }
    });
  }

  void selectLocation(LocationResponse location) {
    state = state.copyWith(
      selectedLocation: location,
      query: location.mapLabel,
      results: [],
      isSearching: false,
      isLoading: false,
      clearError: true,
    );
  }

  void reset() {
    _debounce?.cancel();
    state = LocationSearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// provider
final locationSearchProvider =
    StateNotifierProvider.autoDispose<
      LocationSearchNotifier,
      LocationSearchState
    >((ref) {
      final repo = ref.watch(locationRepoProvider);
      return LocationSearchNotifier(repo);
    });

// the UI
class LocationSearchWidget extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final String? initialLocationName;
  final ValueChanged<dynamic>? onLocationSelected;
  final bool deferSubmit;

  const LocationSearchWidget({
    super.key,
    this.controller,
    this.initialLocationName,
    this.onLocationSelected,
    this.deferSubmit = false,
  });

  @override
  ConsumerState<LocationSearchWidget> createState() =>
      _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends ConsumerState<LocationSearchWidget> {
  TextEditingController? _internalController;

  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _internalController = TextEditingController();
    }

    if (widget.initialLocationName != null &&
        widget.initialLocationName!.isNotEmpty) {
      _controller.text = widget.initialLocationName!;
    }
  }

  @override
  void didUpdateWidget(covariant LocationSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null &&
        oldWidget.initialLocationName != widget.initialLocationName &&
        widget.initialLocationName != null &&
        widget.initialLocationName!.isNotEmpty) {
      _controller.text = widget.initialLocationName!;
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(locationSearchProvider);
    final notifier = ref.read(locationSearchProvider.notifier);

    // Sync controller text only when a selection is made
    if (searchState.selectedLocation != null &&
        _controller.text != searchState.selectedLocation!.mapLabel) {
      _controller.text = searchState.selectedLocation!.mapLabel;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _controller,
                hint: "Search location",
                onChanged: (val) => notifier.onQueryChanged(val),
              ),
            ),
            SizedBox(width: 10.w),
            AppButton(
              variant: AppButtonVariant.leadingIcon,
              icon: Icons.add_location_alt_outlined,
              color: AppColors.brandPrimary,
              textColor: AppColors.backgroundBase,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LocationDetailsScreen(deferSubmit: widget.deferSubmit),
                  ),
                );

                if (result != null) {
                  widget.onLocationSelected?.call(result);
                  notifier.reset();

                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ],
        ),

        // if (searchState.selectedLocation != null) ...[
        //   SizedBox(height: 8.h),
        //   Container(
        //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        //     decoration: BoxDecoration(
        //       color: Colors.green.shade50,
        //       borderRadius: BorderRadius.circular(10.r),
        //       border: Border.all(color: Colors.green.shade200),
        //     ),
        // child: Row(
        //   children: [
        //     Icon(
        //       Icons.check_circle_rounded,
        //       color: Colors.green.shade600,
        //       size: 20.sp,
        //     ),
        //     SizedBox(width: 10.w),
        //     Expanded(
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Text(
        //             "Location Captured Successfully",
        //             style: AppTypography.captionSmall.copyWith(
        //               fontWeight: FontWeight.bold,
        //               color: Colors.green.shade800,
        //               fontSize: 10.sp,
        //             ),
        //           ),
        //           SizedBox(height: 1.h),
        //           Text(
        //             " ${searchState.selectedLocation!.name}",
        //             style: AppTypography.captionSmall.copyWith(
        //               color: Colors.green.shade700,
        //               fontSize: 11.sp,
        //             ),
        //             maxLines: 1,
        //             overflow: TextOverflow.ellipsis,
        //           ),
        //         ],
        //       ),
        //     ),
        //     IconButton(
        //       icon: Icon(
        //         Icons.close_rounded,
        //         color: Colors.green.shade800,
        //         size: 16.sp,
        //       ),
        //       onPressed: () {
        //         _controller.clear();
        //         notifier.reset();
        //         widget.onLocationSelected?.call(null);
        //       },
        //       padding: EdgeInsets.zero,
        //       constraints: const BoxConstraints(),
        //       splashRadius: 16.r,
        //     ),
        //   ],
        // ),
        //   ),
        // ],

        // Results Dropdown
        if (searchState.isLoading)
          Container(
            margin: EdgeInsets.only(top: 5.h),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundBase,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.placeholderText.withAlpha(50),
              ),
            ),
            child: const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),

        if (!searchState.isLoading &&
            searchState.query.trim().length >= 2 &&
            searchState.results.isNotEmpty &&
            searchState.selectedLocation == null)
          Container(
            margin: EdgeInsets.only(top: 5.h),
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundBase,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.placeholderText.withAlpha(50),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: searchState.results.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final location = searchState.results[i];
                return ListTile(
                  dense: true,
                  title: Text(
                    location.mapLabel,
                    style: AppTypography.bodyMedium,
                  ),
                  subtitle: Text(
                    location.physicalAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.captionSmall,
                  ),
                  onTap: () {
                    notifier.selectLocation(location);
                    widget.onLocationSelected?.call(location);
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),

        if (!searchState.isLoading &&
            searchState.query.trim().length >= 2 &&
            searchState.results.isEmpty &&
            searchState.selectedLocation == null)
          Container(
            margin: EdgeInsets.only(top: 5.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundBase,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.placeholderText.withAlpha(50),
              ),
            ),
            child: Text(
              'No locations found',
              style: AppTypography.captionSmall,
            ),
          ),
      ],
    );
  }
}
