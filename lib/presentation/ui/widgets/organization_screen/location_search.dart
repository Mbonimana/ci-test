import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/presentation/ui/screens/location_screen.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_text_field.dart';

// state model
class LocationSearchState {
  final String query;
  final String? selectedLocationName;
  final List<String> results;
  final bool isSearching;

  LocationSearchState({
    this.query = '',
    this.selectedLocationName,
    this.results = const [],
    this.isSearching = false,
  });

  LocationSearchState copyWith({
    String? query,
    String? selectedLocationName,
    List<String>? results,
    bool? isSearching,
  }) {
    return LocationSearchState(
      query: query ?? this.query,
      selectedLocationName: selectedLocationName ?? this.selectedLocationName,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

// notifier
class LocationSearchNotifier extends StateNotifier<LocationSearchState> {
  LocationSearchNotifier() : super(LocationSearchState());

  Timer? _debounce;

  void onQueryChanged(String query) {
    state = state.copyWith(
      query: query,
      selectedLocationName: null,
      isSearching: true,
    );

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.isEmpty) {
        state = state.copyWith(results: [], isSearching: false);
        return;
      }

      // mocksearch
      final mockDatabase = [
        "Building Alpha",
        "West Wing Plaza",
        "Central Business Center",
        "Unity Towers",
      ];
      final filtered = mockDatabase
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();

      state = state.copyWith(results: filtered, isSearching: false);
    });
  }

  void selectLocation(String name) {
    state = state.copyWith(
      selectedLocationName: name,
      query: name,
      results: [],
    );
  }
}

// provider
final locationSearchProvider =
    StateNotifierProvider<LocationSearchNotifier, LocationSearchState>((ref) {
      return LocationSearchNotifier();
    });

// the UI
class LocationSearchWidget extends ConsumerStatefulWidget {
  final String? initialLocationName;

  const LocationSearchWidget({super.key, this.initialLocationName});

  @override
  ConsumerState<LocationSearchWidget> createState() =>
      _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends ConsumerState<LocationSearchWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    if (widget.initialLocationName != null &&
        widget.initialLocationName!.isNotEmpty) {
      _controller.text = widget.initialLocationName!;
      Future.microtask(() {
        if (mounted) {
          ref
              .read(locationSearchProvider.notifier)
              .selectLocation(widget.initialLocationName!);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(locationSearchProvider);
    final notifier = ref.read(locationSearchProvider.notifier);

    // Sync controller text only when a selection is made
    if (searchState.selectedLocationName != null &&
        _controller.text != searchState.selectedLocationName) {
      _controller.text = searchState.selectedLocationName!;
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LocationDetailsScreen(),
                  ),
                );
              },
            ),
          ],
        ),

        // Results Dropdown
        if (searchState.results.isNotEmpty &&
            searchState.selectedLocationName == null)
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
                return ListTile(
                  dense: true,
                  title: Text(
                    searchState.results[i],
                    style: AppTypography.bodyMedium,
                  ),
                  onTap: () {
                    notifier.selectLocation(searchState.results[i]);
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
