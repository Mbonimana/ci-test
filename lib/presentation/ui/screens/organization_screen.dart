import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_form_lable.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_text_field.dart';
import 'package:street_team/presentation/ui/widgets/shared/hours_widget.dart';
import 'package:street_team/presentation/ui/widgets/shared/org_options.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  int currentStep = 0;

  List<dynamic> categories = [];
  List<dynamic> organizations = [];

  // selections
  List<String> selectedLocationIds = [];
  List<String> selectedLocationNames = [];
  List<String> selectedOrgTypes = [];
  List<String> selectedSubtypes = [];

  bool expandLocation = false;
  bool expandOrg = false;
  bool expandSubtypes = false;
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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final locStr = await rootBundle.loadString('assets/location_types.json');
      final orgStr = await rootBundle.loadString(
        'assets/organization_types.json',
      );
      final locJson = json.decode(locStr);
      final orgJson = json.decode(orgStr);
      if (!mounted) return;
      setState(() {
        categories = List<Map<String, dynamic>>.from(
          locJson["locationCategories"] ?? [],
        );
        organizations = List<Map<String, dynamic>>.from(
          orgJson["organizationTypes"] ?? [],
        );
      });
    } catch (e) {
      debugPrint("LOAD ERROR: $e");
    }
  }

  String locationName(String id) => categories.firstWhere(
    (c) => c["id"] == id,
    orElse: () => {"name": id},
  )["name"];
  List<Map<String, dynamic>> get organizationOptions => organizations
      .map(
        (org) => {
          "type": org["name"],
          "id": org["id"],
          "subtypes": List<String>.from(org["subtypes"] ?? []),
        },
      )
      .toList();
  List<String> get subtypeOptions {
    final Set<String> result = {};
    for (final org in organizationOptions) {
      if (selectedOrgTypes.contains(org["type"])) {
        result.addAll(List<String>.from(org["subtypes"]));
      }
    }
    return result.toList();
  }

  void syncSubtypes() {
    final valid = subtypeOptions.toSet();
    selectedSubtypes = selectedSubtypes
        .where((s) => valid.contains(s))
        .toList();
  }

  void toggleOrg(String name) {
    setState(() {
      if (selectedOrgTypes.contains(name)) {
        selectedOrgTypes.remove(name);
      } else {
        selectedOrgTypes.add(name);
      }
      syncSubtypes();
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
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        title: Text('Organization Details'),
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
        backgroundColor:Colors.transparent,
        foregroundColor: AppColors.brandPrimary,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // STEP INDICATOR (Step 1 ------ Step 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentStep == 0) _buildStepOne(),
                  if (currentStep == 1) _buildStepTwo(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
    );
  }

  // step 1 fields
  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormLable(text: 'Location '),
        SizedBox(height: 15.h),
        AppTextField(controller: locationCtrl, hint: "Search location"),
        SizedBox(height: 15.h),
        AppFormLable(text: 'Organization Name'),
        SizedBox(height: 12.h),
        AppTextField(controller: orgNameCtrl, hint: "Enter organization name"),
        SizedBox(height: 15.h),
        AppFormLable(text: "Organization Type(s)"),
        SizedBox(height: 12.h),
        _field(
          label: "Select Organization Type",
          expanded: expandOrg,
          chips: selectedOrgTypes,
          rawValues: selectedOrgTypes,
          options: organizationOptions
              .map((o) => o["type"].toString())
              .toList(),
          optionNames: organizationOptions
              .map((o) => o["type"].toString())
              .toList(),
          onToggle: () => setState(() {
            expandOrg = !expandOrg;
            expandSubtypes = false;
          }),
          onSelect: toggleOrg,
          isSelected: selectedOrgTypes.contains,
        ),
        SizedBox(height: 15.h),
        AppFormLable(text: 'Organization Sub-type(s)'),
        SizedBox(height: 12.h),
        _field(
          label: "Select Subtypes",
          expanded: expandSubtypes,
          chips: selectedSubtypes,
          rawValues: selectedSubtypes,
          options: subtypeOptions,
          optionNames: subtypeOptions,
          onToggle: () => setState(() {
            expandSubtypes = !expandSubtypes;
            expandOrg = false;
          }),
          onSelect: toggleSubtype,
          isSelected: selectedSubtypes.contains,
        ),
        SizedBox(height: 15.h),

        AppFormLable(text: "Phone"),
        SizedBox(height: 15.h),
        AppTextField(controller: phone, hint: "Enter phone number"),
        SizedBox(height: 15.h),
        AppFormLable(text: "Website"),
        SizedBox(height: 15.h),
        AppTextField(controller: website, hint: "Enter website URL"),
      ],
    );
  }

  // step 2 fields
  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormLable(text: "Quick Info"),
        SizedBox(height: 12.h),
        AppTextField(controller: quickinfo, hint: "Quick Info"),
        SizedBox(height: 15.h),
        AppFormLable(text: "Organization Options"),
        BusinessHoursScreen(
          onSaved: (val) => setState(() => workingHoursSummary = val),
        ),
        SizedBox(height: 12.h),
        AppFormLable(text: 'Organization has:'),
        SizedBox(height: 12.h),
        OrganizationOptions(
          onSelectionChanged: (val, onlineMenu) {
            setState(() {
              selectedOrgOptions = val;
              onlineMenuCtrl.text = onlineMenu ?? "";
            });
          },
        ),
        SizedBox(height: 12.h),
        AppFormLable(text: "Building Details"),
        SizedBox(height: 12.h),
        AppTextField(
          controller: buildingDetails,
          hint: 'eg: Floor 5 on Bloc C ',
        ),

        SizedBox(height: 12.h),
      ],
    );
  }

  // --- UI COMPONENTS ---
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

  Widget _field({
    required String label,
    required bool expanded,
    required List<String> chips,
    required List<String> rawValues,
    required List<String> options,
    required List<String> optionNames,
    required VoidCallback onToggle,
    required Function(String) onSelect,
    required bool Function(String) isSelected,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: chips.isEmpty
                      ? Text(label, style: const TextStyle(color: Colors.grey))
                      : SizedBox(
                          height: 30,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: chips.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 6),
                            itemBuilder: (ctx, i) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.lightBlue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    chips[i],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => onSelect(rawValues[i]),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.lightBlue),
              ],
            ),
          ),
        ),
        if (expanded)
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  options.length,
                  (i) => ListTile(
                    dense: true,
                    title: Text(
                      optionNames[i],
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: isSelected(options[i])
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () => onSelect(options[i]),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
