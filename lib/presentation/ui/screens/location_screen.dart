import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/data/models/entiry_model.dart';
import 'package:street_team/presentation/providers/map_provider.dart';
import 'package:street_team/presentation/providers/organization_provider.dart';
import 'package:street_team/presentation/ui/screens/map_pin_picker_screen.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_drop_down.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_form_lable.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_text_field.dart';

class LocationDetailsScreen extends ConsumerStatefulWidget {
  const LocationDetailsScreen({super.key});

  @override
  ConsumerState<LocationDetailsScreen> createState() =>
      _LocationDetailsScreenState();
}

class _LocationDetailsScreenState extends ConsumerState<LocationDetailsScreen> {
  // Form Controllers
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final shortNameController = TextEditingController();
  final nicknameController = TextEditingController();

  // Dropdown State
  bool isTypeDropdownExpanded = false;
  List<EntityType> selectedLocationTypes = [];

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    shortNameController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  void _toggleType(EntityType type) {
    setState(() {
      if (selectedLocationTypes.contains(type)) {
        selectedLocationTypes.remove(type);
      } else {
        selectedLocationTypes.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the location types provider
    final locationTypesAsync = ref.watch(locationTypesListProvider);
    //picked coordinates
    final pickedCoords = ref.watch(pickedLocationProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    AppButton(
                      variant: AppButtonVariant.leadingIcon,
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => Navigator.pop(context),
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
                  onPressed: () {
                    //navigate to the picker
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
                  error: (err, _) => const Text("Error loading types"),
                  data: (types) => AppDropdown<EntityType>(
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

                // Bottom Action Button
                AppButton(
                  text: "Done",
                  onPressed: () {
                    // TODO:Collect data and save
                  },
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
