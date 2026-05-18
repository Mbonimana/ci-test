import 'package:street_team/data/services/category_service.dart';

class CategoryRepository {
  final CategoryService _service;
  CategoryRepository(this._service);

  Future<List<String>> getHomeCategories() async {
    return await _service.loadCategoriesFromAsset();
  }
}
