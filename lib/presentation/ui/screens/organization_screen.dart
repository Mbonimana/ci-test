import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/data/models/organization_response.dart';
import 'package:street_team/data/models/types_model.dart';
import 'package:street_team/presentation/providers/types_provider.dart';
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

  // selections
  List<String> selectedLocationIds = [];
  List<String> selectedLocationNames = [];
  List<String> selectedOrgTypes = [];
  List<String> selectedSubtypes = [];

  bool expandLocation = false;
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

    orgNameCtrl.text = initial.name;
    phone.text = initial.phone ?? '';
    website.text = initial.website ?? '';
    quickinfo.text = initial.quickInfo ?? '';
    buildingDetails.text = initial.orgBuildingInfo?.toString() ?? '';
    onlineMenuCtrl.text = initial.onlineMenu ?? '';

    if (initial.type != null && initial.type!.isNotEmpty) {
      selectedOrgTypes = [initial.type!];
      syncSubtypes(orgTypes);
    }

    selectedOrgOptions = _optionsFromOrganization(initial, orgTypes);
  }

  String locationName(String id, List<TypeModel> locTypes) {
    try {
      return locTypes.firstWhere((c) => c.id.toString() == id).name;
    } catch (_) {
      return id;
    }
  }

  List<Map<String, dynamic>> getOrganizationOptions(List<TypeModel> orgTypes) {
    return orgTypes.map((org) {
      final List<dynamic> subTypesList =
          (org as dynamic).subTypes ?? (org as dynamic).sub_types ?? [];
      final List<String> subtypeNames = subTypesList
          .map((sub) => (sub as dynamic).name.toString())
          .toList();

      return {"type": org.name, "id": org.id, "subtypes": subtypeNames};
    }).toList();
  }

  List<String> getSubtypeOptions(List<TypeModel> orgTypes) {
    final Set<String> result = {};
    for (final org in getOrganizationOptions(orgTypes)) {
      if (selectedOrgTypes.contains(org["type"])) {
        result.addAll(List<String>.from(org["subtypes"]));
      }
    }
    return result.toList();
  }

  void syncSubtypes(List<TypeModel> orgTypes) {
    final valid = getSubtypeOptions(orgTypes).toSet();
    selectedSubtypes = selectedSubtypes
        .where((s) => valid.contains(s))
        .toList();
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

  void toggleSubtype(String value) {
    setState(() {
      if (selectedSubtypes.contains(value)) {
        selectedSubtypes.remove(value);
      } else {
        selectedSubtypes.add(value);
      }
    });
  }

  void _save() {
    //todo: implement save logic
  }

  @override
  Widget build(BuildContext context) {
    final orgTypesAsync = ref.watch(organizationTypesProvider);
    final locTypesAsync = ref.watch(locationTypesProvider);

    //  loading state if either source is retrieving data
    if (orgTypesAsync.isLoading || locTypesAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
          _applyInitialPrefill(orgTypes);
        }
      });
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundBase,
        appBar: AppBar(
          title: const Text('Organization Details'),
          leading: AppButton(
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
                      child: Container(height: 2, color: Colors.grey.shade200),
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
                  onPressed: currentStep == 0
                      ? () => setState(() => currentStep = 1)
                      : _save,
                  variant: AppButtonVariant.primary,
                  text: currentStep == 0 ? "Next" : "Submit",
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
    );
  }

  // step 1 fields
  Widget _buildStepOne(List<TypeModel> orgTypes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppFormLable(text: 'Location '),
        SizedBox(height: 15.h),

        // Search row
        LocationSearchWidget(initialLocationName: widget.initialLocationName),

        SizedBox(height: 15.h),
        const AppFormLable(text: 'Organization Name'),
        SizedBox(height: 12.h),
        AppTextField(controller: orgNameCtrl, hint: "Enter organization name"),
        SizedBox(height: 15.h),
        const AppFormLable(text: "Organization Type(s)"),
        SizedBox(height: 12.h),
        AppDropdown<String>(
          label: "Select Organization Type",
          items: getOrganizationOptions(
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

        AppDropdown<String>(
          label: "Select Subtypes",
          items: getSubtypeOptions(orgTypes),
          selectedItems: selectedSubtypes,
          itemLabel: (s) => s,
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
        AppTextField(controller: phone, hint: "Enter phone number"),
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
        WorkingHours(
          onSaved: (val) => setState(() => workingHoursSummary = val),
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

  List<Map<String, dynamic>> _optionsFromOrganization(
    OrganizationResponseModel organization,
    List<TypeModel> orgTypes,
  ) {
    final selectedNames = <String>{};

    void addIfActive(int? value, String label) {
      if (value == 1) {
        selectedNames.add(label);
      }
    }

    addIfActive(organization.hasBar, 'Bar');
    addIfActive(organization.hasFood, 'Food');
    addIfActive(organization.hasCoffee, 'Coffee');
    addIfActive(organization.hasWifi, 'Wifi');
    addIfActive(organization.hasAtm, 'ATM');
    addIfActive(organization.hasShopping, 'Shopping');
    addIfActive(organization.isTourism, 'Tourism');
    addIfActive(organization.isNightLife, 'Nightlife');
    addIfActive(organization.hasGuhemba, 'Guhemba');
    addIfActive(organization.hasGuhembaMenu, 'Guhemba Menu');

    return getOrganizationOptions(orgTypes)
        .where((item) => selectedNames.contains(item['type']))
        .map<Map<String, dynamic>>((item) => item)
        .toList();
  }
}
