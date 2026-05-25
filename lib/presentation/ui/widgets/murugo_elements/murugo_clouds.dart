import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:street_team/core/config/theme/app_color.dart';

class MurugoCloudsUI extends StatefulWidget {
  const MurugoCloudsUI({super.key});

  @override
  State<MurugoCloudsUI> createState() => _MurugoCloudsUIState();
}

class _MurugoCloudsUIState extends State<MurugoCloudsUI> {
  bool showCloudLabel = false;
  bool showSun = false;

  @override
  void initState() {
    super.initState();

    // Label fade in
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      setState(() {
        showCloudLabel = true;
      });
    });
    //show sun
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      setState(() {
        showSun = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300.h,
      color: AppColors.murugoBlue,
      child: Stack(
        children: [
          Positioned(
            top: 50.h,
            right: 20.w,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOut,
              offset: showSun ? const Offset(0, 0) : const Offset(0, 1),

              child: SvgPicture.asset(
                'assets/murugo/murugo_sun.svg',
                width: 120.w,
                height: 120.h,
              ),
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

            child: AnimatedOpacity(
              opacity: showCloudLabel ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1500),
              child: Image.asset(
                'assets/murugo/murugo_cloud_label.webp',
                height: 38.h,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
