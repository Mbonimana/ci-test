import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';
import 'package:street_team/core/utils/map_helpers/label_style_helper.dart';
import 'package:street_team/data/map_engine/mapbox_map_engine.dart';
import 'package:street_team/presentation/providers/map_provider.dart';
import 'package:street_team/presentation/ui/widgets/shared/app_button.dart';

class MapPinPickerScreen extends ConsumerStatefulWidget {
  const MapPinPickerScreen({super.key});

  @override
  ConsumerState<MapPinPickerScreen> createState() => _MapPinPickerScreenState();
}

class _MapPinPickerScreenState extends ConsumerState<MapPinPickerScreen> {
  MapboxMap? _mapboxMap;
  double _currentLat = 0.0;
  double _currentLng = 0.0;
  bool _isInitialJumpDone = false;

  // ValueNotifier to update UI text without rebuilding the MapWidget
  final ValueNotifier<List<double>> _coordNotifier = ValueNotifier([0.0, 0.0]);

  @override
  void dispose() {
    _coordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapEngine = ref.watch(mapEngineProvider) as MapboxMapEngine;

    ref.listen<AsyncValue<geo.LatLng>>(userLocationProvider, (prev, next) {
      next.whenData((latLng) {
        mapEngine.cameraController.setUserLocation(latLng);

        if (!_isInitialJumpDone && _mapboxMap != null) {
          _mapboxMap?.setCamera(
            CameraOptions(
              center: Point(
                coordinates: Position(latLng.longitude, latLng.latitude),
              ),
              zoom: 16.0,
            ),
          );
          _isInitialJumpDone = true;
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: Stack(
        children: [
          //  Map Layer
          Positioned.fill(
            child: MapWidget(
              key: const ValueKey("sync_picker_map"),
              styleUri: MapboxStyles.MAPBOX_STREETS,
              textureView: true,
              onMapCreated: (map) {
                _mapboxMap = map;
                mapEngine.cameraController.attachMap(map);
              },
              onStyleLoadedListener: (data) async {
                if (_mapboxMap == null) return;

                await _mapboxMap!.location.updateSettings(
                  LocationComponentSettings(
                    enabled: true,
                    pulsingEnabled: true,
                    showAccuracyRing: true,
                  ),
                );

                await LabelStyleHelper.applyMinimalLabels(_mapboxMap!);
              },
              onCameraChangeListener: (data) {
                final center = data.cameraState.center;
                _currentLng = center.coordinates.lng.toDouble();
                _currentLat = center.coordinates.lat.toDouble();
                // Update only the panel, not the MapWidget
                _coordNotifier.value = [_currentLat, _currentLng];
              },
            ),
          ),

         // Center Pin Indicator 
          IgnorePointer(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 280.w,
                    height: 280.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.lightBlue.withAlpha(30),
                    ),
                  ),
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.lightBlue.withAlpha(56),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 40.h),
                    child: Icon(
                      Icons.location_on,
                      size: 52.sp,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //  Floating UI Controls
          Positioned(
            top: 60.h,
            left: 20.w,
            child: AppButton(
              onPressed: () => Navigator.pop(context),
              variant: AppButtonVariant.leadingIcon,
              icon: Icons.arrow_back_ios_new_rounded,
            ),
          ),

          Positioned(
            bottom: 220.h,
            right: 20.w,
            child: AppButton(
              onPressed: () =>
                  mapEngine.goToUserLocation(), 
              variant: AppButtonVariant.leadingIcon,
              icon: Icons.my_location,
            ),
          ),

          //  Floating Bottom Panel
          Positioned(
            bottom: 30.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.all(22.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<List<double>>(
                    valueListenable: _coordNotifier,
                    builder: (context, coords, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCoordRow("Latitude: ", coords[0].toString()),
                          SizedBox(height: 6.h),
                          _buildCoordRow("Longitude: ", coords[1].toString()),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  AppButton(
                    text: "Set Pin",
                    onPressed: () {
                      ref.read(pickedLocationProvider.notifier).state =
                          geo.LatLng(_currentLat, _currentLng);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: AppTypography.bodyMedium.copyWith(fontSize: 13.sp),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.lightBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: AppColors.brandSecondary),
          ),
        ],
      ),
    );
  }
}
