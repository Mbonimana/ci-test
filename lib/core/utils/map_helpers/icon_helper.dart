import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/data/models/organization_feature.dart';
import 'package:vector_graphics/vector_graphics.dart';

class _WhiteIconColorMapper extends svg.ColorMapper {
  const _WhiteIconColorMapper();

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    return AppColors.backgroundBase;
  }
}

class IconHelper {
  IconHelper({this.labelZoomThreshold = 13});

  final double labelZoomThreshold;

  static const Color markerColor = AppColors.mapMarkerBackground;

  static const Map<String, String> typeIcons = {
    'Bar': 'assets/icons/bar.svg',
    'Beauty and SPA': 'assets/icons/hotel.svg',
    'Business Other':
        'assets/icons/businessman-ceo-representative-boss-svgrepo-com.svg',
    'Coffee': 'assets/icons/coffee.svg',
    'Corporate':
        'assets/icons/businessman-ceo-representative-boss-svgrepo-com.svg',
    'Culture': 'assets/icons/tourism.svg',
    'Education': 'assets/icons/education.svg',
    'Embassy': 'assets/icons/government.svg',
    'FastFood': 'assets/icons/restaurant.svg',
    'Government': 'assets/icons/government.svg',
    'Accomodation': 'assets/icons/hotel.svg',
    'Medical': 'assets/icons/medical.svg',
    'Non profit': 'assets/icons/government.svg',
    'Pharmacy': 'assets/icons/medical.svg',
    'Religious': 'assets/icons/government.svg',
    'Restaurants': 'assets/icons/restaurant.svg',
    'Shopping': 'assets/icons/shopping.svg',
    'Sports': 'assets/icons/sports.svg',
    'commercial':
        'assets/icons/businessman-ceo-representative-boss-svgrepo-com.svg',
    'Insurance': 'assets/icons/bank.svg',
    'Technology': 'assets/icons/technology.svg',
    'Construction': 'assets/icons/construction.svg',
    'Coworking':
        'assets/icons/businessman-ceo-representative-boss-svgrepo-com.svg',
    'Travel Agency': 'assets/icons/tourism.svg',
    'Game Center': 'assets/icons/game.svg',
    'Banking': 'assets/icons/bank.svg',
    'Movie theater': 'assets/icons/movie.svg',
    'Library': 'assets/icons/library.svg',
    'Park': 'assets/icons/tourism.svg',
    'Gas Station': 'assets/icons/gas-station.svg',
    'Events Space': 'assets/icons/tourism.svg',
    'Media': 'assets/icons/businessman-ceo-representative-boss-svgrepo-com.svg',
    'Post Office': 'assets/icons/government.svg',
    'Forex Bureau': 'assets/icons/bank.svg',
  };

  static final Map<String, String> _normalizedTypeIcons = {
    for (final entry in typeIcons.entries)
      _normalizeKey(entry.key): entry.value,
  };

  final Map<String, Future<Uint8List>> _markerCache = {};
  final Map<String, Future<Uint8List>> _clusterCache = {};

  String iconForType(String type) {
    return _normalizedTypeIcons[_normalize(type)] ??
        'assets/icons/businessman-ceo-representative-boss-svgrepo-com.svg';
  }

  Color colorForType(String type) {
    return markerColor;
  }

  Future<Uint8List> buildMarkerBytes(
    OrganizationFeature organization, {
    required bool showLabel,
  }) {
    final cacheKey =
        '${organization.id ?? organization.displayName}|${organization.primaryType}|$showLabel';

    return _markerCache.putIfAbsent(cacheKey, () {
      return _renderMarker(organization: organization, showLabel: showLabel);
    });
  }

  Future<Uint8List> buildClusterBytes({
    required int count,
    required String type,
  }) {
    final cacheKey = '$type|$count';

    return _clusterCache.putIfAbsent(cacheKey, () {
      return _renderCluster(count: count, type: type);
    });
  }

  Future<Uint8List> _renderMarker({
    required OrganizationFeature organization,
    required bool showLabel,
  }) async {
    const double markerDiameter = 80;
    const double iconDiameter = 42;
    const double labelHeight = 34;
    const double labelPadding = 14;
    const double canvasWidth = 124;
    final double canvasHeight = showLabel ? 154 : 112;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final backgroundColor = colorForType(organization.primaryType);
    final center = Offset(canvasWidth / 2, 50);

    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: markerDiameter / 2));

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.30), 5, true);

    canvas.drawCircle(
      center,
      markerDiameter / 2 + 2,
      Paint()..color = Colors.white,
    );

    final fillPaint = Paint()..color = backgroundColor;
    canvas.drawCircle(center, markerDiameter / 2 - 2, fillPaint);

    await _drawIcon(
      canvas: canvas,
      iconPath: iconForType(organization.primaryType),
      iconDiameter: iconDiameter,
      center: center,
    );

    if (showLabel) {
      final labelText = _truncateLabel(
        organization.displayName.isEmpty
            ? organization.id ?? ''
            : organization.displayName,
      );
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
        ellipsis: '...',
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            fontSize: 11,
            height: 1.1,
            fontWeight: FontWeight.w600,
            color: Color(0xFF263238),
          ),
        ),
      )..layout(maxWidth: canvasWidth - labelPadding * 2);

      final double pillWidth = math.max(textPainter.width + 20, 60).toDouble();
      final double pillLeft = (canvasWidth - pillWidth) / 2;
      const double pillTop = 92;
      final backgroundRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pillLeft, pillTop, pillWidth, labelHeight),
        const Radius.circular(12),
      );

      canvas.drawRRect(
        backgroundRect,
        Paint()..color = Colors.white.withValues(alpha: 0.92),
      );

      textPainter.paint(
        canvas,
        Offset(
          (canvasWidth - textPainter.width) / 2,
          pillTop + (labelHeight - textPainter.height) / 2,
        ),
      );
    }

    final image = await recorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> _renderCluster({
    required int count,
    required String type,
  }) async {
    const double size = 96;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(size / 2, size / 2);
    final color = colorForType(type);

    final path = Path()..addOval(Rect.fromCircle(center: center, radius: 32));
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.30), 5, true);
    canvas.drawCircle(center, 34, Paint()..color = Colors.white);
    canvas.drawCircle(center, 30, Paint()..color = color);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '$count',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<void> _drawIcon({
    required Canvas canvas,
    required String iconPath,
    required double iconDiameter,
    required Offset center,
  }) async {
    final pictureInfo = await vg.loadPicture(
      svg.SvgAssetLoader(iconPath, colorMapper: const _WhiteIconColorMapper()),
      null,
    );

    final pictureSize = pictureInfo.size;
    final scale =
        iconDiameter / math.max(pictureSize.width, pictureSize.height);
    final scaledWidth = pictureSize.width * scale;
    final scaledHeight = pictureSize.height * scale;
    final left = center.dx - scaledWidth / 2;
    final top = center.dy - scaledHeight / 2;

    canvas.save();
    canvas.translate(left, top);
    canvas.scale(scale, scale);
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();

    pictureInfo.picture.dispose();
  }

  String _truncateLabel(String value) {
    if (value.length <= 18) {
      return value;
    }

    return '${value.substring(0, 17)}...';
  }

  String _normalize(String value) {
    return _normalizeKey(value);
  }

  static String _normalizeKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  }
}
