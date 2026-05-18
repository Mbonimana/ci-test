import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:street_team/core/config/theme/app_color.dart';

class MurugoCloudsUI extends StatelessWidget {
  const MurugoCloudsUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300.h,
      color: AppColors.murugoBlue,
      child: Stack(
        children: [
          // the sun
          Positioned(
            top: 50.h,
            right: 20.w,
            child: SvgPicture.asset(
              'assets/murugo/murugo_sun.svg',
              width: 120.w,
              height: 120.h,
            ),
          ),

          // the clouds
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/murugo/murugo_clouds.webp',
              height: 200.h,
              fit: BoxFit.fitWidth,
            ),
          ),

          // the label
          Positioned(
            top: 120.h,
            left: 35.w,

            child: Image.asset(
              'assets/murugo/murugo_cloud_label.webp',
              height: 38.h,
              fit: BoxFit.fitHeight,
            ),
          ),
        ],
      ),
    );
  }
}
