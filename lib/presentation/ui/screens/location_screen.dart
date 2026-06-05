import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/core/routing/route_names.dart';
import 'package:street_team/data/models/location_models/location_request_model.dart';
import 'package:street_team/data/models/location_models/location_response.dart';
import 'package:street_team/data/models/types_model.dart';
import 'package:street_team/data/services/location_capture_service.dart';
import 'package:street_team/presentation/providers/location_provider.dart';
import 'package:street_team/presentation/providers/map_provider.dart';
import 'package:street_team/presentation/providers/types_provider.dart';
import 'package:street_team/presentation/ui/screens/map_pin_picker_screen.dart';
import 'package:street_team/presentation/ui/widgets/loading_states/loading_indicator.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_drop_down.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_form_lable.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_text_field.dart';

class LocationDetailsScreen extends ConsumerStatefulWidget {
  final String? editId;
  final LocationResponse? initialLocation;
  final bool deferSubmit;

  const LocationDetailsScreen({
    super.key,
    this.editId,
    this.initialLocation,
    this.deferSubmit = false,
  });

  @override
  ConsumerState<LocationDetailsScreen> createState() =>
      _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends ConsumerState<LocationDetailsScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final shortNameController = TextEditingController();
  final nicknameController = TextEditingController();

  // Dropdown State
  bool isTypeDropdownExpanded = false;

  // Selected Types
  List<TypeModel> selectedLocationTypes = [];
  bool _hasAppliedInitialLocation = false;
  bool _hasAppliedInitialTypes = false;
  bool _hasAppliedLoadedLocation = false;
  bool _hasAppliedLoadedTypes = false;

  final _locationService = LocationCaptureService();

  bool get _isEditing =>
      widget.editId != null || widget.initialLocation != null;

  void _applyInitialLocation(LocationResponse initialLocation) {
    if (_hasAppliedInitialLocation) {
      return;
    }

    _hasAppliedInitialLocation = true;

    nameController.text = initialLocation.name;
    addressController.text = initialLocation.physicalAddress;
    shortNameController.text = initialLocation.shortName ?? '';
    nicknameController.text = initialLocation.nickname ?? '';

    ref.read(pickedLocationProvider.notifier).state = geo.LatLng(
      initialLocation.latitude,
      initialLocation.longitude,
    );
  }

  void _applyInitialTypes(
    List<TypeModel> types,
    LocationResponse initialLocation,
  ) {
    if (_hasAppliedInitialTypes) {
      return;
    }

    final initialTypeIds = initialLocation.types.map((type) => type.id).toSet();

    selectedLocationTypes = types
        .where((type) => initialTypeIds.contains(type.id))
        .toList();
    _hasAppliedInitialTypes = true;
  }

  void _applyLoadedLocation(LocationModel initial) {
    if (_hasAppliedLoadedLocation) {
      return;
    }

    _hasAppliedLoadedLocation = true;

    nameController.text = initial.name;
    addressController.text = initial.physicalAddress;
    shortNameController.text = initial.shortName ?? '';
    nicknameController.text = initial.nickname ?? '';

    ref.read(pickedLocationProvider.notifier).state = geo.LatLng(
      initial.latitude,
      initial.longitude,
    );
  }

  void _applyLoadedTypes(List<TypeModel> types, LocationModel initial) {
    if (_hasAppliedLoadedTypes) {
      return;
    }

    final initialTypeIds = initial.types.toSet();
    selectedLocationTypes = types
        .where((type) => initialTypeIds.contains(type.id))
        .toList();
    _hasAppliedLoadedTypes = true;
  }

  void _clearSharedLocationState() {
    ref.read(locationFormProvider.notifier).resetFormState();
    ref.read(pickedLocationProvider.notifier).state = null;
  }

  void _handleClose() {
    _clearSharedLocationState();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> submitLocation() async {
    final coords = ref.read(pickedLocationProvider);

    if (coords == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please pick a location")));
      return;
    }

    if (widget.deferSubmit) {
      // Return the new location payload to the caller without sending to server.
      final newLocation = {
        'location_name': nameController.text,
        'short_name': shortNameController.text,
        'nickname': nicknameController.text,
        'physical_address': addressController.text,
        'latitude': coords.latitude,
        'longitude': coords.longitude,
        'location_types': selectedLocationTypes.map((e) => e.id).toList(),
      };

      if (mounted) Navigator.pop(context, newLocation);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(canPop: false, child: LoadingIndicator()),
    );

    try {
      final submitterAtName = await _locationService.resolveSubmitterName();
      final submitterServer = await _locationService.resolveSubmitterServer();
      final userLocation = await _locationService.buildUserLocation();

      final model = LocationModel(
        name: nameController.text,
        physicalAddress: addressController.text,
        shortName: shortNameController.text,
        nickname: nicknameController.text,
        latitude: coords.latitude,
        longitude: coords.longitude,
        types: selectedLocationTypes.map((e) => e.id).toList(),
        submitterServer: submitterServer,
        submitterAtName: submitterAtName,
        userLocation: userLocation,
      );

      await ref
          .read(locationFormProvider.notifier)
          .submitLocation(model, editId: widget.editId);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Location saved")));
      _clearSharedLocationState();

      if (_isEditing) {
        Navigator.pop(context, true);
      } else {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context, true);
        } else {
          context.go(RouteNames.mapScreen);
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location Permission denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    shortNameController.dispose();
    nicknameController.dispose();

    super.dispose();
  }

  void _toggleType(TypeModel type) {
    setState(() {
      final exists = selectedLocationTypes.any((e) => e.id == type.id);

      if (exists) {
        selectedLocationTypes.removeWhere((e) => e.id == type.id);
      } else {
        selectedLocationTypes.add(type);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    final initialLocation = widget.initialLocation;

    if (initialLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _applyInitialLocation(initialLocation);
      });
      return;
    }

    final editId = widget.editId;

    if (editId != null) {
      Future.microtask(() {
        ref.read(locationFormProvider.notifier).loadLocation(editId);
      });
      return;
    }

    Future.microtask(() {
      if (!mounted) return;
      _clearSharedLocationState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationTypesAsync = ref.watch(locationTypesProvider);

    final pickedCoords = ref.watch(pickedLocationProvider);

    final formState = ref.watch(locationFormProvider);

    final initialLocation = widget.initialLocation;

    if (initialLocation != null &&
        locationTypesAsync.hasValue &&
        !_hasAppliedInitialTypes) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _applyInitialTypes(locationTypesAsync.requireValue, initialLocation);
        });
      });
    }

    if (formState.initial != null && initialLocation == null) {
      final loaded = formState.initial!;

      if (!_hasAppliedLoadedLocation) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          _applyLoadedLocation(loaded);
          setState(() {});
        });
      }

      if (locationTypesAsync.hasValue && !_hasAppliedLoadedTypes) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          setState(() {
            _applyLoadedTypes(locationTypesAsync.requireValue, loaded);
          });
        });
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),

      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          _handleClose();
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundBase,

          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // header
                  Row(
                    children: [
                      AppButton(
                        variant: AppButtonVariant.leadingIcon,

                        icon: Icons.arrow_back_ios_new_rounded,

                        onPressed: () {
                          _handleClose();
                        },
                      ),

                      SizedBox(width: 20.w),

                      Text(
                        "LOCATION DETAILS",

                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.brandPrimary,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Coordinates  Card
                  Container(
                    width: double.infinity,

                    padding: EdgeInsets.all(20.r),

                    decoration: BoxDecoration(
                      color: AppColors.placeholderText.withAlpha(20),

                      borderRadius: BorderRadius.circular(12.r),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Latitude",

                          style: AppTypography.titleSmall.copyWith(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        //picked latitude
                        Text(
                          pickedCoords != null
                              ? pickedCoords.latitude.toString()
                              : "0.0",

                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        Text(
                          "Longitude",

                          style: AppTypography.titleSmall.copyWith(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          pickedCoords != null
                              ? pickedCoords.longitude.toString()
                              : "0.0",

                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15.h),

                  // Pin Point Button
                  AppButton(
                    text: "Pin point",
                    icon: Icons.location_on_outlined,
                    //navigate to the picker
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => const MapPinPickerScreen(),
                        ),
                      );
                    },

                    variant: AppButtonVariant.primary,
                  ),

                  SizedBox(height: 10.h),

                  // Form Inputs
                  const AppFormLable(text: "Location name"),

                  SizedBox(height: 8.h),

                  AppTextField(
                    controller: nameController,
                    hint: "Location name",
                  ),

                  SizedBox(height: 10.h),

                  const AppFormLable(text: "Physical address"),

                  SizedBox(height: 8.h),

                  AppTextField(
                    controller: addressController,
                    hint: "Physical address",
                  ),

                  SizedBox(height: 10.h),

                  const AppFormLable(text: "Short name"),

                  SizedBox(height: 8.h),

                  AppTextField(
                    controller: shortNameController,
                    hint: "Short name",
                  ),

                  SizedBox(height: 10.h),

                  const AppFormLable(text: "Nick name"),

                  SizedBox(height: 8.h),

                  AppTextField(
                    controller: nicknameController,
                    hint: "Nick name",
                  ),

                  SizedBox(height: 10.h),

                  // Location Type Dropdown (Multi-select)
                  const AppFormLable(text: "Location type"),

                  SizedBox(height: 8.h),

                  locationTypesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (err, _) => Text(err.toString()),

                    data: (types) => AppDropdown<TypeModel>(
                      label: "Select location types",

                      items: types,

                      selectedItems: selectedLocationTypes,

                      itemLabel: (type) => type.name,

                      onSelect: (type) => _toggleType(type),

                      isExpanded: isTypeDropdownExpanded,

                      onToggle: () {
                        setState(() {
                          isTypeDropdownExpanded = !isTypeDropdownExpanded;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 10.h),

                  /// submitBUTTON
                  AppButton(text: "Done", onPressed: submitLocation),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
