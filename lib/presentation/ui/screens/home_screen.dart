import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/routing/route_names.dart';
import 'package:street_team/data/services/local_storage/location_sync_engine.dart';
import 'package:street_team/presentation/providers/location_provider.dart';
import 'package:street_team/presentation/ui/widgets/home_screen_widgets/home_top_menu.dart';
import 'package:street_team/presentation/ui/widgets/loading_states/syncy_progress_overlay.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Triggers modified background sync,
      ref.read(initialSyncProvider.notifier).syncModifiedData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(initialSyncProvider);

    return PopScope(
      canPop: syncState.status == InitialSyncStatus.completed,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.backgroundBase,
              appBar: AppBar(
                backgroundColor: AppColors.backgroundBase,
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: AppButton(
                    onPressed: () => showHomeTopMenu(context, ref),
                    variant: AppButtonVariant.leadingIcon,
                    icon: Icons.menu,
                  ),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 300.h),
                        SizedBox(
                          width: double.infinity,
                          height: 55.h,
                          child: AppButton(
                            text: "Show Map",
                            icon: Icons.map,
                            onPressed: () {
                              if (syncState.status ==
                                  InitialSyncStatus.completed) {
                                context.push(RouteNames.mapScreen);
                              } else {
                                ref
                                    .read(initialSyncProvider.notifier)
                                    .syncModifiedData();
                              }
                            },
                            variant: AppButtonVariant.primary,
                          ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Extracted Sync Progress Overlay Widget
            if (syncState.status == InitialSyncStatus.syncing)
              SyncProgressOverlay(
                currentPage: syncState.currentPage,
                totalPages: syncState.totalPages,
              ),
          ],
        ),
      ),
    );
  }
}
