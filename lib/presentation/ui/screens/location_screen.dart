import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/core/routing/route_names.dart';
import 'package:street_team/data/models/location_model.dart';
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
  const LocationDetailsScreen({super.key, this.editId});

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

  final _locationService = LocationCaptureService();

  Future<void> submitLocation() async {
    final coords = ref.read(pickedLocationProvider);

    if (coords == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please pick a location")));
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

      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Location saved")));
        context.go(RouteNames.location);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
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

    final editId = widget.editId;

    if (editId != null) {
      Future.microtask(() {
        ref.read(locationFormProvider.notifier).loadLocation(editId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationTypesAsync = ref.watch(locationTypesProvider);

    final pickedCoords = ref.watch(pickedLocationProvider);

    final formState = ref.watch(locationFormProvider);

    if (formState.initial != null) {
      nameController.text = formState.initial!.name;
      addressController.text = formState.initial!.physicalAddress;
      shortNameController.text = formState.initial!.shortName ?? '';
      nicknameController.text = formState.initial!.nickname ?? '';
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
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
                        Navigator.pop(context);
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

                AppTextField(controller: nameController, hint: "Location name"),

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

                AppTextField(controller: nicknameController, hint: "Nick name"),

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
    );
  }
}
