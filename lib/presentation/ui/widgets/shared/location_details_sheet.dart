import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/data/models/location_response.dart';
import 'package:street_team/data/models/organization_response.dart';
import 'package:street_team/presentation/ui/screens/location_screen.dart';
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
              builder: (_) =>
                  LocationDetailsScreen(editId: location.id.toString()),
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
              type: org.type ?? "General",
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
      action: _ModernEditButton(onPressed: () {}),

      children: [
        // ================= SIMPLE BLOCKS ONLY =================
        _SectionTitle(title: "Organization Details"),

        _SimpleBlock("Name", organization.name),
        _SimpleBlock("Type", organization.type ?? "N/A"),
        _SimpleBlock("Phone", organization.phone ?? "No phone"),
        _SimpleBlock("Website", organization.website ?? "No website"),
        if (organization.quickInfo != null)
          _SimpleBlock("Info", organization.quickInfo!),

        SizedBox(height: 10.h),

        _SectionTitle(title: "Facilities"),

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
    // FORCE 60% HEIGHT
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
                      textAlign: TextAlign
                          .left, 
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 17.sp, 
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandPrimary
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

  if (organization.hasWifi == 1) flags.add("Wifi");
  if (organization.hasFood == 1) flags.add("Food");
  if (organization.hasBar == 1) flags.add("Bar");
  if (organization.isOpen24Hours == 1) flags.add("24/7");

  return flags;
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
