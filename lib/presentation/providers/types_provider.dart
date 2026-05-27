import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:street_team/data/models/types_model.dart';
import 'package:street_team/data/repositories/types_repositoty.dart';
import 'package:street_team/data/services/types_service.dart';

final typeServiceProvider = Provider<TypeService>((ref) {
  return TypeService();
});

final typeRepositoryProvider = Provider<TypeRepository>((ref) {
  return TypeRepository(ref.watch(typeServiceProvider));
});

// organization types
final organizationTypesProvider = FutureProvider<List<TypeModel>>((ref) async {
  final repository = ref.watch(typeRepositoryProvider);

  final response = await repository.getOrganizationTypes();

  if (response.success && response.data != null) {
    return response.data!;
  }

  throw Exception(response.message);
});

//location types

final locationTypesProvider = FutureProvider<List<TypeModel>>((ref) async {
  final repository = ref.watch(typeRepositoryProvider);

  final response = await repository.getLocationTypes();

  if (response.success && response.data != null) {
    return response.data!;
  }

  throw Exception(response.message);
});

// organization type name map

final organizationTypeNamesProvider = FutureProvider<Map<int, String>>((
  ref,
) async {
  final types = await ref.watch(organizationTypesProvider.future);

  return {for (final type in types) type.id: type.name};
});

//location type name map

final locationTypeNamesProvider = FutureProvider<Map<int, String>>((ref) async {
  final types = await ref.watch(locationTypesProvider.future);

  return {for (final type in types) type.id: type.name};
});
