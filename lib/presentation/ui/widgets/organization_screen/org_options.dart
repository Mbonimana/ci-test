import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_drop_down.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_form_lable.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_text_field.dart';

typedef OrganizationSelectionChanged =
    void Function(List<Map<String, dynamic>>, String?);

class OrganizationOptions extends StatelessWidget {
  final OrganizationSelectionChanged onSelectionChanged;
  final List<Map<String, dynamic>> initialSelectedOptions;
  final String? initialOnlineMenu;

  const OrganizationOptions({
    super.key,
    required this.onSelectionChanged,
    this.initialSelectedOptions = const [],
    this.initialOnlineMenu,
  });

  @override
  Widget build(BuildContext context) {
    return _OrganizationOptionsView(
      onSelectionChanged: onSelectionChanged,
      initialSelectedOptions: initialSelectedOptions,
      initialOnlineMenu: initialOnlineMenu,
    );
  }
}

class _OrganizationOptionsView extends StatefulWidget {
  final OrganizationSelectionChanged onSelectionChanged;
  final List<Map<String, dynamic>> initialSelectedOptions;
  final String? initialOnlineMenu;

  const _OrganizationOptionsView({
    required this.onSelectionChanged,
    required this.initialSelectedOptions,
    required this.initialOnlineMenu,
  });

  @override
  State<_OrganizationOptionsView> createState() =>
      _OrganizationOptionsViewState();
}

class _OrganizationOptionsViewState extends State<_OrganizationOptionsView> {
  final TextEditingController onlineMenuCtrl = TextEditingController();

  List<Map<String, dynamic>> allOptions = [];
  Set<int> selectedIds = {};
  bool isExpanded = false;
  String _prefillSignature = '';

  // Check if "Online Menu"
  bool get hasOnlineMenu => selectedIds.contains(29);

  List<Map<String, dynamic>> get selectedOptions {
    return allOptions.where((o) => selectedIds.contains(o['id'])).toList();
  }

  @override
  void initState() {
    super.initState();
    loadOptions();
    onlineMenuCtrl.addListener(_notify);
  }

  @override
  void didUpdateWidget(covariant _OrganizationOptionsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newSignature = _buildPrefillSignature();
    if (newSignature == _prefillSignature) {
      return;
    }

    _prefillSignature = newSignature;
    if (allOptions.isNotEmpty) {
      _applyInitialValues();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _notify();
        }
      });
    }
  }

  @override
  void dispose() {
    onlineMenuCtrl.removeListener(_notify);
    onlineMenuCtrl.dispose();
    super.dispose();
  }

  Future<void> loadOptions() async {
    try {
      final data = await rootBundle.loadString(
        'assets/organization_options.json',
      );
      final decoded = json.decode(data);
      final List rawList = decoded['org_options'] ?? [];

      if (!mounted) return;

      setState(() {
        allOptions = List<Map<String, dynamic>>.from(rawList);
        _applyInitialValues();
        _prefillSignature = _buildPrefillSignature();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _notify();
        }
      });
    } catch (e) {
      debugPrint('FAILED TO LOAD OPTIONS: $e');
    }
  }

  void _applyInitialValues() {
    selectedIds = widget.initialSelectedOptions
        .where((item) => item['id'] != null)
        .map<int>((item) => item['id'] as int)
        .toSet();
    onlineMenuCtrl.text = widget.initialOnlineMenu ?? '';
  }

  String _buildPrefillSignature() {
    final optionIds =
        widget.initialSelectedOptions
            .map((item) => item['id'])
            .whereType<int>()
            .toList()
          ..sort();

    return '${optionIds.join(',')}|${widget.initialOnlineMenu ?? ''}';
  }

  void _notify() {
    widget.onSelectionChanged(selectedOptions, onlineMenuCtrl.text);
  }

  void _toggleSelection(Map<String, dynamic> item) {
    final int id = item['id'];
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<Map<String, dynamic>>(
          label: "Select organization options",
          items: allOptions,
          selectedItems: selectedOptions,
          itemLabel: (item) => item['name'],
          onSelect: (item) => _toggleSelection(item),
          isExpanded: isExpanded,
          onToggle: () => setState(() => isExpanded = !isExpanded),
        ),

        // show online menu url
        if (hasOnlineMenu) ...[
          SizedBox(height: 15.h),
          const AppFormLable(text: "Online Menu URL"),
          SizedBox(height: 15.h),
          AppTextField(
            controller: onlineMenuCtrl,
            hint: "https://menu.com/...",
            keyboardType: TextInputType.url,
          ),
        ],
      ],
    );
  }
}
