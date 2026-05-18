import 'dart:convert';

import 'package:flutter/services.dart';

class CategoryService {
  Future<List<String>> loadCategoriesFromAsset() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/mock/home_categories.json',
      );
      final data = await json.decode(response);
      return List<String>.from(data['categories']);
    } catch (e) {
      throw Exception("Failed to load JSON data");
    }
  }
}
