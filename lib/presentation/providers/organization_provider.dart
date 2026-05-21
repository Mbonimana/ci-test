import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/core/utils/talker_helper.dart';
import 'package:street_team/data/models/entiry_model.dart'; // Updated as per your file name
import 'package:street_team/data/models/organization_model.dart';
import 'package:street_team/data/repositories/category_repository.dart'; // Ensure TypeRepository is here
import 'package:street_team/data/repositories/organization_repository.dart';
import 'package:street_team/data/services/category_service.dart'; // Ensure TypeService is here



final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
});


final typeRepositoryProvider = Provider<TypeRepository>((ref) {
  return TypeRepository(TypeService());
});


final organizationsProvider = FutureProvider<List<OrganizationModel>>((
  ref,
) async {
  final repo = ref.watch(organizationRepositoryProvider);
  talker.info("Fetching organizations...");
  try {
    final orgs = await repo.loadOrganizations();
    talker.info("Loaded ${orgs.length} organizations successfully");
    return orgs;
  } catch (e, st) {
    talker.handle(e, st, "Failed to load organizations");
    rethrow;
  }
});


final organizationTypesListProvider = FutureProvider<List<EntityType>>((
  ref,
) async {
  final repo = ref.watch(typeRepositoryProvider);
  return repo.getOrganizationTypes();
});

/// Fetches the static list of Location Types (Buildings) from location_types.json
final locationTypesListProvider = FutureProvider<List<EntityType>>((ref) async {
  final repo = ref.watch(typeRepositoryProvider);
  return repo.getLocationTypes();
});


final organizationTypeFilterProvider = StateProvider<Set<int>>((ref) {
  return <int>{};
});


final organizationSearchProvider = StateProvider<String>((ref) => '');

/// Active state for search mode
final isSearchingProvider = StateProvider<bool>((ref) => false);


final selectedOrganizationProvider = StateProvider<OrganizationModel?>(
  (ref) => null,
);


final filteredOrganizationsProvider = Provider<List<OrganizationModel>>((ref) {
  final organizationsAsync = ref.watch(organizationsProvider);
  final activeTypeIds = ref.watch(organizationTypeFilterProvider);

  return organizationsAsync.maybeWhen(
    data: (organizations) {
      if (activeTypeIds.isEmpty) {
        return organizations;
      }

      return organizations
          .where((org) {
            return org.organizationTypes.any(
              (type) => activeTypeIds.contains(type.id),
            );
          })
          .toList(growable: false);
    },
    orElse: () => const <OrganizationModel>[],
  );
});

/// Provides organizations filtered by the search text
final searchedOrganizationsProvider = Provider<List<OrganizationModel>>((ref) {
  final query = ref.watch(organizationSearchProvider);
  final organizationsAsync = ref.watch(organizationsProvider);

  return organizationsAsync.maybeWhen(
    data: (organizations) {
      if (query.trim().isEmpty) return [];

      final search = query.toLowerCase();
      talker.info("Performing search for: '$search'");

      final results = organizations
          .where((org) {
            final nameMatch = org.organizationName.toLowerCase().contains(
              search,
            );
            final locMatch = org.location.name.toLowerCase().contains(search);
            final typeMatch = org.primaryType.toLowerCase().contains(search);

            return nameMatch || locMatch || typeMatch;
          })
          .toList(growable: false);

      talker.verbose("Search results found: ${results.length}");
      return results;
    },
    orElse: () => [],
  );
});
