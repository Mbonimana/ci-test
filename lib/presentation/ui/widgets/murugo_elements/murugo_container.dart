import 'package:flutter/material.dart';
import 'package:street_team/presentation/ui/widgets/murugo_elements/murugo_clouds.dart';

class MurugoHeader extends StatelessWidget {
  const MurugoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      color: const Color(0xFF00A3E4),
      child: Stack(
        children: [
          // 1. THE SUN
          Positioned(
            top: 60,
            right: 20,
            child: Image.asset(
              'assets/icons/ic_sun_large_icon.png',
              width: 90,
              height: 90,
            ),
          ),

          // 2. THE LABEL
          Positioned(
            top: 80,
            left: 20,
            child: Image.asset(
              'assets/icons/murugo_cloud_label.png',
              width: 180,
              fit: BoxFit.cover,
            ),
          ),

          // 3. THE CLOUDS
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MurugoCloudBackground(),
          ),
        ],
      ),
    );
  }
}
