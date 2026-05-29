import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/data/models/location_response.dart';
import 'package:street_team/data/models/organization_response.dart';
import 'package:street_team/presentation/ui/screens/location_screen.dart';
import 'package:street_team/presentation/ui/screens/organization_screen.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';

class LocationDetailsSheet extends StatelessWidget {
  final LocationResponse location;

  const LocationDetailsSheet({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return _BaseScrollSheet(
      title: 'Location Details',
      action: _ModernEditButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LocationDetailsScreen(
                editId: location.id.toString(),
                initialLocation: location,
              ),
            ),
          );
        },
      ),
      children: [
        // Location block
        _SimpleBlock("Location Name", location.name),
        if (location.nickname?.isNotEmpty == true)
          _SimpleBlock("Nickname", location.nickname!),
        _SimpleBlock("Physical Address", location.physicalAddress),

        _SimpleBlock("Short Name", " ${location.shortName}"),
        _SectionTitle(title: "Coo"),

        // Types
        if (location.types.isNotEmpty) ...[
          _SectionTitle(title: "Types"),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: location.types
                .map((t) => _ChipPill(text: t.name))
                .toList(),
          ),
        ],

        SizedBox(height: 16.h),

        //orgs
        _SectionTitle(
          title: "Organizations (${location.organizations.length})",
        ),

        SizedBox(height: 8.h),

        if (location.organizations.isEmpty)
          Text("No organizations", style: AppTypography.bodyMedium)
        else
          ...location.organizations.map(
            (org) => _CompactOrgCard(
              name: org.name,
              type: _organizationTypeLabel(org),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => OrganizationDetailsSheet(
                    location: location,
                    organization: org,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class OrganizationDetailsSheet extends StatelessWidget {
  final LocationResponse location;
  final OrganizationResponseModel organization;

  const OrganizationDetailsSheet({
    super.key,
    required this.location,
    required this.organization,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseScrollSheet(
      title: 'Organization Info',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
        onPressed: () => Navigator.pop(context),
      ),
      action: _ModernEditButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrganizationScreen(
                initialOrganization: organization,
                initialLocationName: location.name,
              ),
            ),
          );
        },
      ),

      children: [
        // simple
        _SectionTitle(title: "Organization Details"),

        _SimpleBlock("Name", organization.name),
        _SimpleBlock("Type", _organizationTypeLabel(organization)),
        _SimpleBlock("Phone", organization.phone ?? "No phone"),
        _SimpleBlock("Website", organization.website ?? "No website"),
        if (organization.quickInfo != null)
          _SimpleBlock("Quick Info", organization.quickInfo!),

        if (_organizationSubTypes(organization).isNotEmpty) ...[
          SizedBox(height: 10.h),
          _SectionTitle(title: "Sub Types"),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: _organizationSubTypes(organization)
                .map((subType) => _ChipPill(text: subType, isOutline: true))
                .toList(),
          ),
        ],

        SizedBox(height: 10.h),

        if (_workingHoursSummary(organization).isNotEmpty)
          _SimpleBlock("Working Hours", _workingHoursSummary(organization)),
        if (_workingHoursExtra(organization).isNotEmpty)
          _SimpleBlock("Notes", _workingHoursExtra(organization)),

        _SectionTitle(title: "Organization has:"),

        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: _orgFlags(
            organization,
          ).map((t) => _ChipPill(text: t, isOutline: true)).toList(),
        ),
      ],
    );
  }
}

class _BaseScrollSheet extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget? leading;
  final List<Widget> children;

  const _BaseScrollSheet({
    required this.title,
    required this.children,
    this.action,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.60;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xfff6f7fb),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(50),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: SizedBox(
              height: 40.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (leading != null) Positioned(left: 0, child: leading!),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 110.w),
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (action != null) Positioned(right: 0, child: action!),
                ],
              ),
            ),
          ),

          // SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ================= SIMPLE BLOCK (NO CARD UI) =================

class _SimpleBlock extends StatelessWidget {
  final String label;
  final String value;

  const _SimpleBlock(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 8.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brandPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brandSecondary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// organization card
class _CompactOrgCard extends StatelessWidget {
  final String name;
  final String type;
  final VoidCallback onTap;

  const _CompactOrgCard({
    required this.name,
    required this.type,
    required this.onTap,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        10.r,
      ), // Added to keep ripple contained
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        // Increased vertical padding from 10 to 14 for extra height
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          // Added a very subtle border or shadow to make the increased height feel distinct
          border: Border.all(color: AppColors.placeholderText.withAlpha(25)),
        ),
        child: Row(
          children: [
            // Increased icon size slightly for better alignment with new height
            Icon(
              Icons.business_rounded,
              size: 18.sp,
              color: AppColors.brandPrimary,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                name,
                style: AppTypography.titleSmall.copyWith(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                type,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.brandSecondary.withAlpha(153),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// type chip
class _ChipPill extends StatelessWidget {
  final String text;
  final bool isOutline;

  const _ChipPill({required this.text, this.isOutline = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isOutline
            ? Colors.transparent
            : AppColors.brandPrimary.withAlpha(25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.brandPrimary.withAlpha(50)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: AppColors.brandPrimary),
      ),
    );
  }
}

// edit
class _ModernEditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ModernEditButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return AppButton(
      variant: AppButtonVariant.leadingIcon,
      icon: Icons.edit,
      color: AppColors.brandPrimary,
      textColor: AppColors.backgroundBase,
      onPressed: onPressed,
    );
  }
}

// ================= FLAGS =================

List<String> _orgFlags(OrganizationResponseModel organization) {
  final flags = <String>[];

  final options = _normalizedOptions(organization.options);

  final flagDefinitions = <_OrgFlagDefinition>[
    _OrgFlagDefinition('Wifi', ['has_wifi'], legacyValue: organization.hasWifi),
    _OrgFlagDefinition('Food', ['has_food'], legacyValue: organization.hasFood),
    _OrgFlagDefinition('Bar', ['has_bar'], legacyValue: organization.hasBar),
    _OrgFlagDefinition('24/7', [
      'is_open_24_hours',
    ], legacyValue: organization.isOpen24Hours),
    _OrgFlagDefinition('ATM', ['has_ATM', 'has_atm']),
    _OrgFlagDefinition('Parking', ['has_parking']),
    _OrgFlagDefinition('Coffee', [
      'has_coffee',
    ], legacyValue: organization.hasCoffee),
    _OrgFlagDefinition('Tourism', [
      'is_tourism',
    ], legacyValue: organization.isTourism),
    _OrgFlagDefinition('Nightlife', [
      'is_night_life',
    ], legacyValue: organization.isNightLife),
    _OrgFlagDefinition('Shopping', [
      'has_shopping',
    ], legacyValue: organization.hasShopping),
    _OrgFlagDefinition('Guhemba', [
      'has_guhemba',
    ], legacyValue: organization.hasGuhemba),
    _OrgFlagDefinition('Guhemba Menu', [
      'has_guhemba_menu',
    ], legacyValue: organization.hasGuhembaMenu),
    _OrgFlagDefinition('Delivery', ['delivery_available']),
    _OrgFlagDefinition('Brunch', ['brunch_available']),
    _OrgFlagDefinition('Work Friendly', ['work_friendly']),
    _OrgFlagDefinition('Reservation Required', ['reservation_required']),
    _OrgFlagDefinition('Wheelchair Accessible', ['wheelchair_accessible']),
    _OrgFlagDefinition('Family Friendly', ['family_friendly']),
    _OrgFlagDefinition('Swimming Pool', ['swimming_pool']),
    _OrgFlagDefinition('Gym', ['has_gym']),
    _OrgFlagDefinition('Spa', ['has_spa']),
    _OrgFlagDefinition('Pool Table', ['pool_table']),
    _OrgFlagDefinition('Takeaway', ['has_takeaway']),
    _OrgFlagDefinition('Kids Activities', ['kids_activities']),
    _OrgFlagDefinition('Sunday School', ['sunday_school']),
    _OrgFlagDefinition('Outdoor Activities', ['outdoor_activities']),
  ];

  for (final definition in flagDefinitions) {
    if (definition.isEnabled(options)) {
      flags.add(definition.label);
    }
  }

  return flags;
}

Map<String, dynamic> _normalizedOptions(Map<String, dynamic>? options) {
  return options == null
      ? const <String, dynamic>{}
      : Map<String, dynamic>.from(options);
}

class _OrgFlagDefinition {
  final String label;
  final List<String> optionKeys;
  final int? legacyValue;

  const _OrgFlagDefinition(this.label, this.optionKeys, {this.legacyValue});

  bool isEnabled(Map<String, dynamic> options) {
    for (final key in optionKeys) {
      final value = options[key];
      if (value == 1 || value == true || value?.toString() == '1') {
        return true;
      }
    }

    return legacyValue == 1;
  }
}

String _organizationTypeLabel(OrganizationResponseModel organization) {
  if (organization.types.isNotEmpty) {
    return organization.types.map((type) => type.name).join(', ');
  }

  final legacyType = organization.type?.trim() ?? '';
  return legacyType.isEmpty ? 'N/A' : legacyType;
}

List<String> _organizationSubTypes(OrganizationResponseModel organization) {
  final values = <String>[];

  for (final entry in organization.subTypes) {
    final text = _displayValue(entry);
    if (text.isNotEmpty && !values.contains(text)) {
      values.add(text);
    }
  }

  return values;
}

String _workingHoursSummary(OrganizationResponseModel organization) {
  final weeklyHours = _workingHoursMap(organization);
  if (weeklyHours.isEmpty) {
    return '';
  }

  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final lines = <String>[];

  for (final day in days) {
    final entries = weeklyHours[day];

    if (entries == null || entries.isEmpty) {
      lines.add('$day: closed');
      continue;
    }

    final ranges = <String>[];
    for (final entry in entries) {
      final range = _workingHourRange(entry);
      if (range.isNotEmpty) {
        ranges.add(range);
      }
    }

    if (ranges.isEmpty) {
      lines.add('$day: closed');
    } else {
      lines.add('$day: ${ranges.join(', ')}');
    }
  }

  return lines.join('\n');
}

String _workingHoursExtra(OrganizationResponseModel organization) {
  final notes = <String>[];

  if (organization.orgBuildingInfo != null) {
    final buildingInfo = _displayValue(organization.orgBuildingInfo);
    if (buildingInfo.isNotEmpty) {
      notes.add('Building: $buildingInfo');
    }
  }

  if (organization.isTempoUpdated != null) {
    final tempoUpdated = _displayValue(organization.isTempoUpdated);
    if (tempoUpdated.isNotEmpty && tempoUpdated != 'null') {
      notes.add('Tempo updated: $tempoUpdated');
    }
  }

  return notes.join('\n');
}

Map<String, List<dynamic>> _workingHoursMap(
  OrganizationResponseModel organization,
) {
  final candidates = [
    organization.openingHours,
    organization.normalOpeningHours,
    organization.weekendOpeningHours,
  ];

  for (final candidate in candidates) {
    final normalized = _extractWeeklyHours(candidate);
    if (normalized.isNotEmpty) {
      return normalized;
    }
  }

  return const {};
}

Map<String, List<dynamic>> _extractWeeklyHours(dynamic source) {
  if (source == null) return const {};

  final map = source is Map ? Map<String, dynamic>.from(source) : null;
  if (map == null) return const {};

  final weeklySource = map['weekly_hours'] ?? map['weeklyHours'] ?? map;
  if (weeklySource is! Map) return const {};

  final result = <String, List<dynamic>>{};
  final weeklyMap = Map<String, dynamic>.from(weeklySource);

  for (final entry in weeklyMap.entries) {
    final value = entry.value;
    if (value is List) {
      result[entry.key] = value;
    } else if (value is String && value.toLowerCase() == 'closed') {
      result[entry.key] = const [];
    } else if (value is Map) {
      result[entry.key] = [value];
    }
  }

  return result;
}

String _workingHourRange(dynamic entry) {
  if (entry is! Map) {
    return _displayValue(entry);
  }

  final map = Map<String, dynamic>.from(entry);
  final open = _timeOnly(map['open'] ?? map['open_time']);
  final close = _timeOnly(map['close'] ?? map['close_time']);

  if (open.isEmpty && close.isEmpty) {
    return _displayValue(map);
  }

  if (open.isEmpty) return close;
  if (close.isEmpty) return open;

  return '$open - $close';
}

String _timeOnly(dynamic value) {
  final text = _displayValue(value);
  if (text.isEmpty) return '';

  if (text.contains(' ')) {
    final parts = text.split(' ');
    if (parts.isNotEmpty) {
      return parts.first.trim();
    }
  }

  return text;
}

String _displayValue(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is num || value is bool) return value.toString();
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    final candidates = [
      map['name'],
      map['label'],
      map['title'],
      map['value'],
      map['open'],
      map['close'],
      map['open_time'],
      map['close_time'],
      map['day'],
    ];

    final buffer = <String>[];
    for (final candidate in candidates) {
      final text = _displayValue(candidate);
      if (text.isNotEmpty) {
        buffer.add(text);
      }
    }

    if (buffer.isNotEmpty) {
      return buffer.join(' - ');
    }

    return map.entries
        .map((entry) => '${entry.key}: ${_displayValue(entry.value)}')
        .join(', ');
  }
  if (value is Iterable) {
    return value
        .map(_displayValue)
        .where((value) => value.isNotEmpty)
        .join(', ');
  }
  return value.toString();
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}
