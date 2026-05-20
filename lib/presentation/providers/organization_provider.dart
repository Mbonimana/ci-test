import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/data/models/organization_model.dart';
import 'package:street_team/data/repositories/organization_repository.dart';

//repository

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
});

//raw organizations

final organizationsProvider = FutureProvider<List<OrganizationModel>>((
  ref,
) async {
  final repo = ref.watch(organizationRepositoryProvider);

  return repo.loadOrganizations();
});

//category/type filter

final organizationTypeFilterProvider = StateProvider<Set<String>>((ref) {
  return <String>{};
});

//search query

final organizationSearchProvider = StateProvider<String>((ref) {
  return '';
});

//search active state

final isSearchingProvider = StateProvider<bool>((ref) {
  return false;
});

//selected organization

final selectedOrganizationProvider = StateProvider<OrganizationModel?>((ref) {
  return null;
});

//filted categories/types

final filteredOrganizationsProvider = Provider<List<OrganizationModel>>((ref) {
  final organizationsAsync = ref.watch(organizationsProvider);

  final activeTypes = ref.watch(organizationTypeFilterProvider);

  return organizationsAsync.maybeWhen(
    data: (organizations) {
      if (activeTypes.isEmpty) {
        return organizations;
      }

      return organizations
          .where(
            (organization) => activeTypes.contains(organization.primaryType),
          )
          .toList(growable: false);
    },
    orElse: () => const <OrganizationModel>[],
  );
});

//search results

final searchedOrganizationsProvider = Provider<List<OrganizationModel>>((ref) {
  final query = ref.watch(organizationSearchProvider);

  //search through all data
  final organizationsAsync = ref.watch(organizationsProvider);

  return organizationsAsync.maybeWhen(
    data: (organizations) {
      if (query.trim().isEmpty) {
        return [];
      }

      final search = query.toLowerCase();

      return organizations
          .where((organization) {
            return organization.organizationName.toLowerCase().contains(
                  search,
                ) ||
                organization.locationName.toLowerCase().contains(search) ||
                organization.primaryType.toLowerCase().contains(search);
          })
          .toList(growable: false);
    },

    orElse: () => [],
  );
});
