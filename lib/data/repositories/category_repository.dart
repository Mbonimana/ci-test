
import 'package:street_team/data/models/entiry_model.dart';
import 'package:street_team/data/services/category_service.dart';


class TypeRepository {
  final TypeService _service;
  TypeRepository(this._service);


  Future<List<EntityType>> getOrganizationTypes() async {
    return await _service.loadOrganizationTypes();
  }

  Future<List<EntityType>> getLocationTypes() async {
    return await _service.loadLocationTypes();
  }
}