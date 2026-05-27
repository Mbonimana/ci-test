import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:street_team/core/utils/talker_helper.dart';
import 'package:street_team/data/models/organization_model.dart';
import 'package:street_team/data/models/types_model.dart';
import 'package:street_team/data/repositories/organization_repository.dart';
import 'package:street_team/data/repositories/types_repositoty.dart';
import 'package:street_team/data/services/types_service.dart';

/// =====================
/// REPOSITORIES
/// =====================

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
});

final typeRepositoryProvider = Provider<TypeRepository>((ref) {
  return TypeRepository(TypeService());
});

/// =====================
/// ORGANIZATIONS
/// =====================

final organizationsProvider = FutureProvider<List<OrganizationModel>>((
  ref,
) async {
  final repo = ref.watch(organizationRepositoryProvider);

  talker.info("Fetching organizations...");

  final result = await repo.loadOrganizations();

  talker.info("Loaded ${result.length} organizations");

  return result;
});

/// =====================
/// TYPES (FIXED: ApiResponse HANDLING)
/// =====================

final organizationTypesListProvider = FutureProvider<List<TypeModel>>((
  ref,
) async {
  final repo = ref.watch(typeRepositoryProvider);

  final response = await repo.getOrganizationTypes();

  if (response.success && response.data != null) {
    return response.data!;
  }

  throw Exception(response.message ?? "Failed to load organization types");
});

final locationTypesListProvider = FutureProvider<List<TypeModel>>((ref) async {
  final repo = ref.watch(typeRepositoryProvider);

  final response = await repo.getLocationTypes();

  if (response.success && response.data != null) {
    return response.data!;
  }

  throw Exception(response.message ?? "Failed to load location types");
});
