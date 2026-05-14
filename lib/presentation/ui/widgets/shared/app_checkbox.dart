import 'package:flutter/material.dart';
import 'package:street_team/core/config/theme/app_color.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? label;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.brandPrimary; // checked
            }
            return AppColors.backgroundBase; // unchecked
          }),
          // Check icon color
          checkColor: AppColors.backgroundBase,
          // Border
          side: WidgetStateBorderSide.resolveWith((states) {
            return BorderSide(color: AppColors.brandPrimary, width: 2);
          }),
        ),
        if (label != null) ...[const SizedBox(width: 0), Text(label!)],
      ],
    );
  }
}
