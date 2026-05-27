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
    return _SheetSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          SizedBox(height: 16.h),
          _HeaderBlock(
            title: location.mapLabel,
            subtitle: location.physicalAddress,
            action: AppButton(
              text: 'Edit Location',
              variant: AppButtonVariant.secondary,
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
          ),
          SizedBox(height: 18.h),
          _InfoRow(
            label: 'Coordinates',
            value: '${location.latitude}, ${location.longitude}',
          ),
          SizedBox(height: 16.h),
          if (location.types.isNotEmpty) ...[
            Text('Types', style: AppTypography.titleSmall),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: location.types
                  .map((type) => _ChipPill(text: type.name, filled: true))
                  .toList(),
            ),
            SizedBox(height: 18.h),
          ],
          Text('Organizations', style: AppTypography.titleSmall),
          SizedBox(height: 10.h),
          if (location.organizations.isEmpty)
            _EmptyState(
              text: 'No organizations are registered at this location yet.',
            )
          else
            ...location.organizations.map(
              (organization) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OrganizationCard(
                  organization: organization,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => OrganizationDetailsSheet(
                        location: location,
                        organization: organization,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
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
    return _SheetSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          SizedBox(height: 16.h),
          _HeaderBlock(
            title: organization.name,
            subtitle: organization.type ?? location.mapLabel,
            action: AppButton(
              text: 'Edit Organization',
              variant: AppButtonVariant.secondary,
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrganizationScreen(
                      initialOrganization: organization,
                      initialLocationName: location.mapLabel,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 18.h),
          _InfoRow(
            label: 'Phone',
            value: organization.phone?.isNotEmpty == true
                ? organization.phone!
                : 'No phone provided',
          ),
          _InfoRow(
            label: 'Website',
            value: organization.website?.isNotEmpty == true
                ? organization.website!
                : 'No website provided',
          ),
          _InfoRow(
            label: 'Submitter',
            value: organization.submitterAtName?.isNotEmpty == true
                ? organization.submitterAtName!
                : 'Unknown',
          ),
          if (organization.quickInfo?.isNotEmpty == true) ...[
            SizedBox(height: 14.h),
            Text('Quick Info', style: AppTypography.titleSmall),
            SizedBox(height: 8.h),
            Text(organization.quickInfo!, style: AppTypography.bodyMedium),
          ],
          if (organization.onlineMenu?.isNotEmpty == true) ...[
            SizedBox(height: 14.h),
            Text('Online Menu', style: AppTypography.titleSmall),
            SizedBox(height: 8.h),
            Text(organization.onlineMenu!, style: AppTypography.bodyMedium),
          ],
          SizedBox(height: 18.h),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _organizationFlags(
              organization,
            ).map((tag) => _ChipPill(text: tag)).toList(),
          ),
        ],
      ),
    );
  }
}

List<String> _organizationFlags(OrganizationResponseModel organization) {
  final flags = <String>[];

  void addIfActive(int? value, String label) {
    if (value == 1) {
      flags.add(label);
    }
  }

  addIfActive(organization.isActive, 'Active');
  addIfActive(organization.isBest, 'Best');
  addIfActive(organization.isNew, 'New');
  addIfActive(organization.isOpen24Hours, '24 Hours');
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

  return flags;
}

class _SheetSurface extends StatelessWidget {
  final Widget child;

  const _SheetSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundBase,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.placeholderText.withAlpha(70),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget action;

  const _HeaderBlock({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleMedium),
              SizedBox(height: 6.h),
              Text(subtitle, style: AppTypography.bodyMedium),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        action,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  final String text;
  final bool filled;

  const _ChipPill({required this.text, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: filled
            ? AppColors.brandPrimary.withAlpha(18)
            : AppColors.placeholderText.withAlpha(28),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: filled ? AppColors.brandPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;

  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.placeholderText.withAlpha(18),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(text, style: AppTypography.bodyMedium),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final OrganizationResponseModel organization;
  final VoidCallback onTap;

  const _OrganizationCard({required this.organization, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.placeholderText.withAlpha(35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withAlpha(16),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.brandPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organization.name,
                      style: AppTypography.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      organization.type ?? 'Organization',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
