import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final organizationTypeNamesProvider = FutureProvider<Map<int, String>>((
  ref,
) async {
  final jsonString = await rootBundle.loadString(
    'assets/mock/organization_types.json',
  );

  final List data = jsonDecode(jsonString);

  final Map<int, String> map = {
    for (final item in data) item['id'] as int: item['name'] as String,
  };

  return map;
});
