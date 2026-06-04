import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/data/models/location_models/location_response.dart';

class IconHelper {
  final Map<String, Future<Uint8List>> _cache = {};
  static const double _canvasWidth = 80;
  static const double _canvasHeight = 80;
  static const double _outerRadius = 24;
  static const double _innerRadius = 20;
  static const double _iconSize = 26;

  static const Map<String, String> typeIcons = {
    'food_drink': 'assets/icons/restaurant.svg',
    'wellness': 'assets/icons/medical.svg',
    'commercial': 'assets/icons/business.svg',
    'culture': 'assets/icons/tourism.svg',
    'education': 'assets/icons/education.svg',
    'government': 'assets/icons/government.svg',
    'hotel': 'assets/icons/hotel.svg',
    'healthcare': 'assets/icons/hospital.svg',
    'community': 'assets/icons/sports.svg',
    'religion': 'assets/icons/hotel.svg',
    'sports': 'assets/icons/sports.svg',
    'financial': 'assets/icons/bank.svg',
    'tech': 'assets/icons/technology.svg',
    'industry': 'assets/icons/location.svg',
    'transport': 'assets/icons/gas-station.svg',
    'entertainment': 'assets/icons/game.svg',
    'outdoor': 'assets/icons/movie.svg',
    'bus_station': 'assets/icons/gas-station.svg',
    'event_space': 'assets/icons/game.svg',
    'default': 'assets/icons/location.svg',
  };

  Future<Uint8List> buildLocationMarker(
    LocationResponse location, {
    bool showLabel = true,
  }) {
    final key = '${location.id}_${location.primaryTypeName}';

    return _cache.putIfAbsent(
      key,
      () =>
          _render(type: LocationTypeResolver.resolve(location.primaryTypeName)),
    );
  }

  Future<Uint8List> getRawIconBytes(String typeKey) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(40, 40);

    // Standard Circle
    canvas.drawCircle(center, 38, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      32,
      Paint()..color = AppColors.textSecondary,
    );

    // White Icon
    final iconPath = typeIcons[typeKey] ?? typeIcons['default']!;
    await _drawSvgWhite(canvas, iconPath, center);

    final img = await recorder.endRecording().toImage(80, 80);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  final Map<String, Uint8List> _imageMemory = {};
  Future<Uint8List> getMarkerImageOnly(String typeKey) async {
    if (_imageMemory.containsKey(typeKey)) return _imageMemory[typeKey]!;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(50, 50);

    //  marker circle
    canvas.drawCircle(center, 45, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      38,
      Paint()..color = AppColors.textPrimary
    );

    final iconPath = typeIcons[typeKey] ?? typeIcons['default']!;
    await _drawSvgWhite(canvas, iconPath, center);

    final img = await recorder.endRecording().toImage(100, 100);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);

    final result = bytes!.buffer.asUint8List();
    _imageMemory[typeKey] = result;
    return result;
  }

  Future<Uint8List> _render({required String type}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final center = const Offset(_canvasWidth / 2, 45);

    canvas.drawCircle(center, _outerRadius, Paint()..color = Colors.white);

    canvas.drawCircle(
      center,
      _innerRadius,
      Paint()..color = AppColors.textSecondary,
    );

    final iconPath = typeIcons[type] ?? typeIcons['default']!;
    await _drawSvgWhite(canvas, iconPath, center);

    final img = await recorder.endRecording().toImage(
      _canvasWidth.toInt(),
      _canvasHeight.toInt(),
    );

    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _drawSvgWhite(
    Canvas canvas,
    String assetPath,
    Offset center,
  ) async {
    final svgString = await rootBundle.loadString(assetPath);
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

    final scale = _iconSize / pictureInfo.size.width;

    canvas.save();
    canvas.translate(center.dx - (_iconSize / 2), center.dy - (_iconSize / 2));
    canvas.scale(scale);

    final paint = Paint()
      ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcIn);

    canvas.saveLayer(null, paint);
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();
    canvas.restore();

    pictureInfo.picture.dispose();
  }
}

class LocationTypeResolver {
  static const Map<String, String> _map = {
    'food & drink': 'food_drink',
    'food drink': 'food_drink',
    'wellness & personal care': 'wellness',
    'wellness personal care': 'wellness',
    'commercial & retail spaces': 'commercial',
    'commercial retail spaces': 'commercial',
    'cultural & creative spaces': 'culture',
    'cultural creative spaces': 'culture',
    'education & learning spaces': 'education',
    'education learning spaces': 'education',
    'government & public administration': 'government',
    'government public administration': 'government',
    'hospitality & accommodation': 'hotel',
    'hospitality accommodation': 'hotel',
    'healthcare facilities': 'healthcare',
    'community & social infrastructure': 'community',
    'religious spaces': 'religion',
    'sports & recreation facilities': 'sports',
    'recreation and sports': 'sports',
    'financial services': 'financial',
    'technology & communication services': 'tech',
    'industrial & production': 'industry',
    'mobility services': 'transport',
    'transport & mobility hubs': 'transport',
    'entertainment & leisure spaces': 'entertainment',
    'outdoor & public spaces': 'outdoor',
    'bus station': 'bus_station',
    'concerts ground': 'event_space',
  };

  static String resolve(String raw) {
    final normalized = raw
        .toLowerCase()
        .replaceAll('&', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return _map[normalized] ?? 'default';
  }
}
