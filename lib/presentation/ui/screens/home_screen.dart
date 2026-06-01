import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/core/routing/route_names.dart';
import 'package:street_team/presentation/providers/home_screen_provider.dart';
import 'package:street_team/presentation/ui/widgets/home_screen_widgets/type_selector.dart';
import 'package:street_team/presentation/ui/widgets/home_screen_widgets/home_top_menu.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';
import 'package:street_team/presentation/ui/widgets/shared/feedback_widgets/app_snackbar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 240.h),
                  // Text(
                  //   "Select Type",
                  //   style: AppTypography.titleMedium.copyWith(
                  //     color: AppColors.textPrimary,
                  //   ),
                  // ),

                  // SizedBox(height: 15.h),
                  // CategorySelector(stateData: homeState),

                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: AppButton(
                      text: "Show Map",
                      icon: Icons.map,
                      onPressed: () {
                        // if (homeState.selectedTypes.isEmpty) {
                        //   AppSnackbar.show(
                        //     context: context,
                        //     message: 'Please select at least one type',
                        //     variant: SnackbarVariant.warning,
                        //   );
                        //   return;
                        // }

                        context.go(RouteNames.mapScreen);
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
    );
  }
}
