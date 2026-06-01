import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:street_team/core/config/theme/app_color.dart';
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

  const OrganizationScreen({
    super.key,
    this.initialOrganization,
    this.initialLocationName,
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
  void dispose() {
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
    } else if (initial.type != null && initial.type!.isNotEmpty) {
      selectedOrgTypes = [initial.type!];
      syncSubtypes(orgTypes);
    }

    _applyInitialSubtypes(orgTypes, initial);
    selectedOrgOptions = organizationOptionsFromOrganization(initial, orgTypes);
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

    if (orgName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organization name is required.')),
      );
      return;
    }

    if (selectedOrgTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one organization type.')),
      );
      return;
    }

    if ((selectedMurugoLocationId ?? '').isEmpty &&
        createdLocationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a valid location first.')),
      );
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
        : organizationOptionsFromOrganization(initialOrganization, orgTypes);

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

      // ✅ close loading dialog FIRST
      Navigator.of(context).pop();

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // optional small safety delay to avoid route conflict
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

      //  final navigation
      context.go(RouteNames.mapScreen);
    } catch (e) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(organizationFormProvider);
    final orgTypesAsync = ref.watch(organizationTypesProvider);
    final locTypesAsync = ref.watch(locationTypesProvider);

    //  loading state if either source is retrieving data
    if (orgTypesAsync.isLoading || locTypesAsync.isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }
    if (orgTypesAsync.hasError || locTypesAsync.hasError) {
      final error = orgTypesAsync.error ?? locTypesAsync.error;
      return Scaffold(body: Center(child: Text("Error loading data: $error")));
    }

    final orgTypes = orgTypesAsync.value ?? [];

    // initial field prefilling after the first frame
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
      onTap: () => FocusScope.of(context).unfocus(),
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
                  // STEP INDICATOR (Step 1 ------ Step 2)
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
                  // Navigator Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: AppButton(
                      onPressed: () {
                        if (formState.isSubmitting) return;
                        if (currentStep == 0) {
                          setState(() => currentStep = 1);
                          return;
                        }
                        _save();
                      },
                      variant: AppButtonVariant.primary,
                      // isLoading: formState.isSubmitting,
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

  // step 1 fields
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

        // Search row
        LocationSearchWidget(
          controller: locationCtrl,
          initialLocationName: widget.initialLocationName,
          deferSubmit: true,
          onLocationSelected: (dynamic location) {
            if (location is LocationResponse) {
              createdLocationData = null;
              selectedMurugoLocationId = location.id.toString();
              locationCtrl.text = location.mapLabel;
            } else if (location is Map<String, dynamic>) {
              // Returned new location data from LocationDetailsScreen
              createdLocationData = Map<String, dynamic>.from(location);
              selectedMurugoLocationId = null;
              locationCtrl.text =
                  createdLocationData?['location_name']
                          ?.toString()
                          .trim()
                          .isNotEmpty ==
                      true
                  ? createdLocationData!['location_name'].toString()
                  : createdLocationData?['physical_address']?.toString() ?? '';
            }
          },
        ),

        SizedBox(height: 15.h),
        const AppFormLable(text: 'Organization Name'),
        SizedBox(height: 12.h),
        AppTextField(controller: orgNameCtrl, hint: "Enter organization name"),
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
          hint: "Enter phone number",
          numbersOnly: true,
        ),
        SizedBox(height: 15.h),
        const AppFormLable(text: "Website"),
        SizedBox(height: 15.h),
        AppTextField(controller: website, hint: "Enter website URL"),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppFormLable(text: "Quick Info"),
        SizedBox(height: 12.h),
        AppTextField(controller: quickinfo, hint: "Quick Info"),
        SizedBox(height: 15.h),
        const AppFormLable(text: "Organization Options"),
        Builder(
          builder: (context) {
            // Safely cast weekly hours maps which may be Map<dynamic,dynamic>
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
        AppTextField(
          controller: buildingDetails,
          hint: 'eg: Floor 5 on Bloc C ',
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  // ui components
  Widget _stepNode(int step, String label) {
    bool isActive = currentStep == step;
    return GestureDetector(
      onTap: () => setState(() => currentStep = step),
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
}
