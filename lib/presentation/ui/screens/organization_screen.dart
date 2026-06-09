import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/network/network_error_handler.dart';
import 'package:street_team/core/routing/route_names.dart';
import 'package:street_team/data/models/location_models/location_response.dart';
import 'package:street_team/data/models/organization_models/organization_response.dart';
import 'package:street_team/data/models/types_model.dart';
import 'package:street_team/presentation/providers/organization/organization_form_helpers.dart';
import 'package:street_team/presentation/providers/organization/organization_provider.dart';
import 'package:street_team/presentation/providers/types_provider.dart';
import 'package:street_team/presentation/ui/widgets/loading_states/loading_indicator.dart';
import 'package:street_team/presentation/ui/widgets/organization_screen/location_search.dart';
import 'package:street_team/presentation/ui/widgets/organization_screen/org_options.dart';
import 'package:street_team/presentation/ui/widgets/organization_screen/working_hours.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_drop_down.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_form_lable.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_text_field.dart';

class OrganizationScreen extends ConsumerStatefulWidget {
  final OrganizationResponseModel? initialOrganization;
  final String? initialLocationName;
  final String? initialLocationId;

  const OrganizationScreen({
    super.key,
    this.initialOrganization,
    this.initialLocationName,
    this.initialLocationId,
  });

  @override
  ConsumerState<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends ConsumerState<OrganizationScreen> {
  int currentStep = 0;

  bool get _isEditing =>
      widget.initialOrganization?.murugoOrganizationId != null;

  List<String> selectedOrgTypes = [];
  List<int> selectedSubtypes = [];
  Map<String, dynamic>? createdLocationData;

  bool expandOrg = false;
  bool expandSubtypes = false;
  bool _prefilled = false;
  bool get hasOnlineMenu {
    return selectedOrgOptions.any((e) => e["name"] == "Online Menu");
  }

  // Validation Error Messages
  String? locationError;
  String? orgNameError;
  String? orgTypeError;
  String? phoneError;

  final locationCtrl = TextEditingController();
  final orgNameCtrl = TextEditingController();
  final onlineMenuCtrl = TextEditingController();
  final phone = TextEditingController();
  final website = TextEditingController();
  final quickinfo = TextEditingController();
  final buildingDetails = TextEditingController();

  Map<String, dynamic>? workingHoursSummary;
  List<Map<String, dynamic>> selectedOrgOptions = [];
  String? selectedMurugoLocationId;

  @override
  void initState() {
    super.initState();

    if (widget.initialLocationId != null) {
      selectedMurugoLocationId = widget.initialLocationId;
    }

    // Attach listeners to clear inline validation messages instantly while typing
    orgNameCtrl.addListener(_onOrgNameChanged);
    phone.addListener(_onPhoneChanged);
  }

  void _onOrgNameChanged() {
    if (orgNameError != null && orgNameCtrl.text.trim().isNotEmpty) {
      setState(() => orgNameError = null);
    }
  }

  void _onPhoneChanged() {
    if (phoneError != null && phone.text.trim().isNotEmpty) {
      setState(() => phoneError = null);
    }
  }

  @override
  void dispose() {
    orgNameCtrl.removeListener(_onOrgNameChanged);
    phone.removeListener(_onPhoneChanged);

    locationCtrl.dispose();
    orgNameCtrl.dispose();
    onlineMenuCtrl.dispose();
    phone.dispose();
    website.dispose();
    quickinfo.dispose();
    buildingDetails.dispose();

    ref.read(locationSearchProvider.notifier).reset();

    super.dispose();
  }

  /// Runs the inline validation check for Step 1
  bool _validateStepOne() {
    bool isValid = true;

    setState(() {
      //Location Validation
      if ((selectedMurugoLocationId ?? '').isEmpty &&
          createdLocationData == null) {
        locationError = "Please select a valid location.";
        isValid = false;
      } else {
        locationError = null;
      }

      // Org Name Validation
      if (orgNameCtrl.text.trim().isEmpty) {
        orgNameError = "Organization name is required.";
        isValid = false;
      } else {
        orgNameError = null;
      }

      //  Org Type Validation
      if (selectedOrgTypes.isEmpty) {
        orgTypeError = "Please select at least one organization type.";
        isValid = false;
      } else {
        orgTypeError = null;
      }

      // Phone Validation
      final phoneVal = phone.text.trim();
      if (phoneVal.isEmpty) {
        phoneError = "Phone number is required.";
        isValid = false;
      } else if (phoneVal.length < 3) {
        phoneError = "Please enter a valid phone number (min 3 digits).";
        isValid = false;
      } else {
        phoneError = null;
      }
    });

    return isValid;
  }

  void _applyInitialPrefill(List<TypeModel> orgTypes) {
    final initial = widget.initialOrganization;
    if (initial == null || _prefilled) {
      return;
    }

    _prefilled = true;

    if (widget.initialLocationName != null &&
        widget.initialLocationName!.isNotEmpty) {
      locationCtrl.text = widget.initialLocationName!;
    }

    selectedMurugoLocationId = initial.murugoLocationId;

    orgNameCtrl.text = initial.name;
    phone.text = initial.phone ?? '';
    website.text = initial.website ?? '';
    quickinfo.text = initial.quickInfo ?? '';
    buildingDetails.text = initial.orgBuildingInfo?.toString() ?? '';
    onlineMenuCtrl.text = initial.onlineMenu ?? '';
    workingHoursSummary = workingHoursFromOrganization(initial);

    if (initial.types.isNotEmpty) {
      selectedOrgTypes = initial.types.map((t) => t.name).toList();
      syncSubtypes(orgTypes);
    }

    _applyInitialSubtypes(orgTypes, initial);
    selectedOrgOptions = organizationOptionsFromOrganization(initial);
  }

  void _applyInitialSubtypes(
    List<TypeModel> orgTypes,
    OrganizationResponseModel initial,
  ) {
    if (initial.subTypes.isEmpty) return;

    final requestedIds = extractSubTypeIds(initial.subTypes);
    final requestedNames = extractSubTypeNames(initial.subTypes);

    final available = subtypeOptionsForSelection(orgTypes, selectedOrgTypes);
    selectedSubtypes = available
        .where(
          (item) =>
              requestedIds.contains(item.id) ||
              requestedNames.contains(item.name.toLowerCase()),
        )
        .map((item) => item.id)
        .toList();
  }

  void syncSubtypes(List<TypeModel> orgTypes) {
    selectedSubtypes = selectedSubTypeIds(
      orgTypes,
      selectedOrgTypes,
      selectedSubtypes,
    );
  }

  void toggleOrg(String name, List<TypeModel> orgTypes) {
    setState(() {
      if (selectedOrgTypes.contains(name)) {
        selectedOrgTypes.remove(name);
      } else {
        selectedOrgTypes.add(name);
      }
      orgTypeError = null;
      syncSubtypes(orgTypes);
    });
  }

  void toggleSubtype(int value) {
    setState(() {
      if (selectedSubtypes.contains(value)) {
        selectedSubtypes.remove(value);
      } else {
        selectedSubtypes.add(value);
      }
    });
  }

  List<int> _selectedTypeIds(List<TypeModel> orgTypes) {
    return selectedTypeIds(orgTypes, selectedOrgTypes);
  }

  List<int> _selectedSubTypeIds(List<TypeModel> orgTypes) {
    return selectedSubTypeIds(orgTypes, selectedOrgTypes, selectedSubtypes);
  }

  Future<void> _save() async {
    final orgName = orgNameCtrl.text.trim();
    final organizationId = widget.initialOrganization?.murugoOrganizationId;

    if (!_validateStepOne()) {
      setState(() => currentStep = 0);
      return;
    }

    final orgTypes = await ref.read(organizationTypesProvider.future);
    final notifier = ref.read(organizationFormProvider.notifier);
    final initialOrganization = widget.initialOrganization;
    final effectiveWorkingHours =
        workingHoursSummary ??
        (initialOrganization != null
            ? workingHoursFromOrganization(initialOrganization)
            : null) ??
        <String, dynamic>{};
    final effectiveSelectedOptions = _prefilled || initialOrganization == null
        ? selectedOrgOptions
        : organizationOptionsFromOrganization(initialOrganization);

    try {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            const PopScope(canPop: false, child: LoadingIndicator()),
      );

      await notifier.submitOrganization(
        action: _isEditing ? 'UPDATE' : 'ADD',
        name: orgName,
        type: selectedOrgTypes.first,
        phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
        quickInfo: quickinfo.text.trim().isEmpty ? null : quickinfo.text.trim(),
        website: website.text.trim().isEmpty ? null : website.text.trim(),
        onlineMenu: onlineMenuCtrl.text.trim().isEmpty
            ? null
            : onlineMenuCtrl.text.trim(),
        murugoLocationId: selectedMurugoLocationId,
        newLocationData: createdLocationData,
        types: _selectedTypeIds(orgTypes),
        subTypes: _selectedSubTypeIds(orgTypes),
        selectedOptions: effectiveSelectedOptions,
        workingHoursData: effectiveWorkingHours,
        orgBuildingInfo: buildingDetails.text.trim().isEmpty
            ? null
            : buildingDetails.text.trim(),
        murugoOrganizationId: organizationId,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Organization updated successfully.'
                : 'Organization submitted successfully.',
          ),
        ),
      );

      context.go(RouteNames.mapScreen);
    } catch (e) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        final message = NetworkErrorHandler.toUserMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(organizationFormProvider);
    final orgTypesAsync = ref.watch(organizationTypesProvider);
    final locTypesAsync = ref.watch(locationTypesProvider);

    if (orgTypesAsync.isLoading || locTypesAsync.isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }
    if (orgTypesAsync.hasError || locTypesAsync.hasError) {
      final error = orgTypesAsync.error ?? locTypesAsync.error;
      final errorMessage = NetworkErrorHandler.toUserMessage(error);

      return Scaffold(
        backgroundColor: AppColors.backgroundBase,
        appBar: AppBar(
          title: const Text('Organization Details'),
          leading: Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: AppButton(
              onPressed: () => Navigator.maybePop(context),
              variant: AppButtonVariant.leadingIcon,
              icon: Icons.arrow_back_ios_new_rounded,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.brandPrimary,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 60.sp,
                    color: AppColors.brandPrimary.withAlpha(160),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Connection Failed",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 160.w,
                    child: AppButton(
                      onPressed: () {
                        // Force invalidation to re-execute provider futures
                        ref.invalidate(organizationTypesProvider);
                        ref.invalidate(locationTypesProvider);
                      },
                      variant: AppButtonVariant.primary,
                      text: "Retry ",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final orgTypes = orgTypesAsync.value ?? [];

    if (!_prefilled && orgTypes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _applyInitialPrefill(orgTypes);
          });
        }
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.backgroundBase,
            appBar: AppBar(
              title: const Text('Organization Details'),
              leading: Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: AppButton(
                  onPressed: () {
                    if (currentStep == 0) {
                      Navigator.pop(context);
                    } else {
                      setState(() => currentStep = 0);
                    }
                  },
                  variant: AppButtonVariant.leadingIcon,
                  icon: Icons.arrow_back_ios_new_rounded,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.brandPrimary,
              elevation: 0,
            ),
            bottomNavigationBar: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        _stepNode(0, "Step 1"),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: Colors.grey.shade200,
                          ),
                        ),
                        _stepNode(1, "Step 2"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: AppButton(
                      onPressed: () {
                        if (formState.isSubmitting) return;
                        if (currentStep == 0) {
                          if (_validateStepOne()) {
                            setState(() => currentStep = 1);
                          }
                          return;
                        }
                        _save();
                      },
                      variant: AppButtonVariant.primary,
                      text: currentStep == 0
                          ? "Next"
                          : (_isEditing ? "Update" : "Submit"),
                    ),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentStep == 0) _buildStepOne(orgTypes),
                  if (currentStep == 1) _buildStepTwo(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepOne(List<TypeModel> orgTypes) {
    final subtypeOptions = subtypeOptionsForSelection(
      orgTypes,
      selectedOrgTypes,
    );
    final subtypeNameMap = subtypeNameMapForSelection(
      orgTypes,
      selectedOrgTypes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppFormLable(text: 'Location '),
        SizedBox(height: 15.h),

        LocationSearchWidget(
          controller: locationCtrl,
          initialLocationName: widget.initialLocationName,
          deferSubmit: true,
          onLocationSelected: (dynamic location) {
            setState(() {
              locationError = null;
              if (location is LocationResponse) {
                createdLocationData = null;
                selectedMurugoLocationId = location.id.toString();
                locationCtrl.text = location.mapLabel;
              } else if (location is Map<String, dynamic>) {
                createdLocationData = Map<String, dynamic>.from(location);
                selectedMurugoLocationId = null;
                locationCtrl.text =
                    createdLocationData?['location_name']
                            ?.toString()
                            .trim()
                            .isNotEmpty ==
                        true
                    ? createdLocationData!['location_name'].toString()
                    : createdLocationData?['physical_address']?.toString() ??
                          '';
              }
            });
          },
        ),
        _buildValidationError(locationError),

        SizedBox(height: 15.h),
        const AppFormLable(text: 'Organization Name'),
        SizedBox(height: 12.h),
        AppTextField(controller: orgNameCtrl, hint: "  John's Cafe"),
        _buildValidationError(orgNameError),

        SizedBox(height: 15.h),
        const AppFormLable(text: "Organization Type(s)"),
        SizedBox(height: 12.h),
        AppDropdown<String>(
          label: "Select Organization Type",
          items: organizationOptions(
            orgTypes,
          ).map((o) => o["type"].toString()).toList(),
          selectedItems: selectedOrgTypes,
          itemLabel: (s) => s,
          onSelect: (val) => toggleOrg(val, orgTypes),
          isExpanded: expandOrg,
          onToggle: () => setState(() {
            expandOrg = !expandOrg;
            expandSubtypes = false;
          }),
        ),
        _buildValidationError(orgTypeError),

        SizedBox(height: 15.h),
        const AppFormLable(text: 'Organization Sub-type(s)'),
        SizedBox(height: 12.h),

        AppDropdown<int>(
          label: "Select Subtypes",
          items: subtypeOptions.map((s) => s.id).toList(),
          selectedItems: selectedSubtypes,
          itemLabel: (id) => subtypeNameMap[id] ?? id.toString(),
          onSelect: toggleSubtype,
          isExpanded: expandSubtypes,
          onToggle: () => setState(() {
            expandSubtypes = !expandSubtypes;
            expandOrg = false;
          }),
        ),

        SizedBox(height: 15.h),
        const AppFormLable(text: "Phone"),
        SizedBox(height: 15.h),
        AppTextField(
          controller: phone,
          hint: "250 780 000 000",
          numbersOnly: true,
        ),
        _buildValidationError(phoneError),

        SizedBox(height: 15.h),
        const AppFormLable(text: "Website"),
        SizedBox(height: 15.h),
        AppTextField(controller: website, hint: "https://johnscafe.com"),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppFormLable(text: "Quick Info"),
        SizedBox(height: 12.h),
        AppTextField(
          controller: quickinfo,
          hint: " e.g:A cozy place for coffee lovers",
        ),
        SizedBox(height: 15.h),
        const AppFormLable(text: "Organization Options"),
        Builder(
          builder: (context) {
            final rawWeekly =
                workingHoursSummary?['weekly_hours'] ??
                workingHoursSummary?['weeklyHours'];
            Map<String, dynamic>? initialWeekly;
            if (rawWeekly is Map) {
              try {
                initialWeekly = Map<String, dynamic>.from(rawWeekly);
              } catch (_) {
                initialWeekly = rawWeekly.cast<String, dynamic>();
              }
            }

            return WorkingHours(
              onSaved: (val) => workingHoursSummary = val,
              initialIsActive:
                  (workingHoursSummary?['is_active'] ??
                      workingHoursSummary?['isActive']) ==
                  true,
              initialIsOpen24:
                  (workingHoursSummary?['is_open_24_hours'] ??
                      workingHoursSummary?['isOpen24']) ==
                  true,
              initialIsTempClosed:
                  (workingHoursSummary?['is_temporary_closed'] ??
                      workingHoursSummary?['isTempClosed']) ==
                  true,
              initialPossibleReturnDate:
                  (workingHoursSummary?['possible_return_date'] ??
                          workingHoursSummary?['possibleReturnDate'])
                      ?.toString(),
              initialWeeklyHours: initialWeekly,
            );
          },
        ),
        SizedBox(height: 12.h),
        const AppFormLable(text: 'Organization has:'),
        SizedBox(height: 12.h),

        OrganizationOptions(
          initialSelectedOptions: selectedOrgOptions,
          initialOnlineMenu: onlineMenuCtrl.text,
          onSelectionChanged: (selectedVal, onlineMenu) {
            setState(() {
              selectedOrgOptions = selectedVal;
              onlineMenuCtrl.text = onlineMenu ?? "";
            });
          },
        ),
        SizedBox(height: 12.h),
        const AppFormLable(text: "Building Details"),
        SizedBox(height: 12.h),
        AppTextField(controller: buildingDetails, hint: ' Floor 5 on Bloc C '),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _stepNode(int step, String label) {
    bool isActive = currentStep == step;
    return GestureDetector(
      onTap: () {
        if (step == 1 && currentStep == 0) {
          if (!_validateStepOne()) return;
        }
        setState(() => currentStep = step);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.lightBlue : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom inline validation rendering widget
  Widget _buildValidationError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 6.h, left: 4.w),
      child: Text(
        error,
        style: TextStyle(
          color: Colors.red.withAlpha(200),
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
