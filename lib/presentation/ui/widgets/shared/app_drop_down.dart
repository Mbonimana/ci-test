import 'package:flutter/material.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';

class AppDropdown<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final Function(T) onSelect;
  final bool isExpanded;
  final VoidCallback onToggle;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.onSelect,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            widget.onToggle();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.placeholderText.withAlpha(30),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: widget.selectedItems.isEmpty
                      ? Text(widget.label, style: AppTypography.captionSmall)
                      : SizedBox(
                          height: 30,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.selectedItems.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 6),
                            itemBuilder: (context, i) {
                              final item = widget.selectedItems[i];
                              // selected item chip with a close icon
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.brandPrimary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      widget.itemLabel(item),
                                      style: AppTypography.captionSmall
                                          .copyWith(
                                            color: AppColors.buttonTextPrimary,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    // close icon to remove item from selected items
                                    InkWell(
                                      onTap: () => widget.onSelect(item),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: AppColors.buttonTextPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
                // dropdown arrow icon
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.brandPrimary,
                ),
              ],
            ),
          ),
        ),
        if (widget.isExpanded)
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: AppColors.backgroundBase,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.placeholderText.withAlpha(30),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: widget.items.map((item) {
                  final isSelected = widget.selectedItems.contains(item);
                  return ListTile(
                    dense: true,
                    title: Text(
                      widget.itemLabel(item),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    //display check icon if item is selected
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.brandPrimary)
                        : null,
                    onTap: () => widget.onSelect(item),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
