import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/presentation/providers/map_provider.dart';
import 'package:street_team/presentation/providers/organization_provider.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool showCreateActions = false;

  @override
  Widget build(BuildContext context) {
    final mapEngine = ref.watch(mapEngineProvider);
    final userLocation = ref.watch(userLocationProvider);

    final organizationsAsync = ref.watch(organizationsProvider);
    final filteredOrganizations = ref.watch(filteredOrganizationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      resizeToAvoidBottomInset: false,

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),

        child: Stack(
          children: [
            /// MAP
            Positioned.fill(
              child: organizationsAsync.when(
                data: (_) {
                  return mapEngine.buildMap(
                    userLocation: userLocation,
                    organizations: filteredOrganizations,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error.toString(), textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),

            /// TOP BAR
            Positioned(
              top: 60.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  AppButton(
                    onPressed: () => Navigator.pop(context),
                    variant: AppButtonVariant.leadingIcon,
                    icon: Icons.arrow_back_ios_new_rounded,
                  ),

                  SizedBox(width: 14.w),

                  Expanded(
                    child: Container(
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBase,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: AppTypography.captionSmall,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: "Search locations or organizations",
                          suffixIcon: Icon(
                            Icons.search,
                            color: AppColors.brandPrimary,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 16.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// LEFT ACTION
            Positioned(
              bottom: 40.h,
              left: 20.w,
              child: AppButton(
                onPressed: () {},
                variant: AppButtonVariant.circularIcon,
                icon: Icons.refresh_rounded,
              ),
            ),

            /// RIGHT ACTIONS
            Positioned(
              bottom: 40.h,
              right: 20.w,
              child: SizedBox(
                width: 200.w,
                height: 200.h,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      right: showCreateActions ? 60 : -90.w,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: showCreateActions ? 1 : 0,
                        child: Container(
                          width: 180.w,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundBase,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppButton(
                                text: "New Location",
                                icon: Icons.location_on_outlined,
                                onPressed: () {},
                                variant: AppButtonVariant.secondary,
                              ),
                              SizedBox(height: 10.h),
                              AppButton(
                                text: "New Organization",
                                icon: Icons.business_outlined,
                                onPressed: () {},
                                variant: AppButtonVariant.secondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// GPS
                    Positioned(
                      bottom: 70.h,
                      right: 0,
                      child: AppButton(
                        onPressed: mapEngine.goToUserLocation,
                        variant: AppButtonVariant.leadingIcon,
                        icon: Icons.my_location,
                      ),
                    ),

                    /// TOGGLE
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: AppButton(
                        onPressed: () {
                          setState(() {
                            showCreateActions = !showCreateActions;
                          });
                        },
                        variant: AppButtonVariant.circularIcon,
                        icon: Icons.add_location_alt_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
