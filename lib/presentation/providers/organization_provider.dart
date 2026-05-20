import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/data/models/organization_model.dart';
import 'package:street_team/data/repositories/organization_repository.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
});

final organizationsProvider = FutureProvider<List<OrganizationModel>>((
  ref,
) async {
  final repo = ref.watch(organizationRepositoryProvider);
  return repo.loadOrganizations();
});

final organizationTypeFilterProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final filteredOrganizationsProvider = Provider<List<OrganizationModel>>((ref) {
  final asyncOrgs = ref.watch(organizationsProvider);
  final activeTypes = ref.watch(organizationTypeFilterProvider);

  return asyncOrgs.maybeWhen(
    data: (orgs) {
      if (activeTypes.isEmpty) return orgs;

      return orgs
          .where((o) => activeTypes.contains(o.primaryType))
          .toList(growable: false);
    },
    orElse: () => const <OrganizationModel>[],
  );
});
