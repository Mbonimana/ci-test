import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/data/models/location_model.dart';
import 'package:street_team/data/models/organization_model.dart';
import 'package:street_team/data/repositories/location_repository.dart';
import 'package:street_team/data/services/location_service.dart';
import 'package:street_team/presentation/providers/organization_provider.dart';

final locationServiceProvider = Provider((ref) => LocationService());

final locationRepositoryProvider = Provider((ref) {
  return LocationRepository(ref.watch(locationServiceProvider));
});

//locations list
final locationsProvider = FutureProvider<List<LocationModel>>((ref) async {
  return ref.watch(locationRepositoryProvider).getLocations();
});

final selectedLocationProvider = StateProvider<LocationModel?>((ref) => null);

final organizationsByLocationProvider =
    Provider.family<List<OrganizationModel>, String>((ref, locationId) {
      final allOrgsAsync = ref.watch(organizationsProvider);

      return allOrgsAsync.maybeWhen(
        data: (orgs) =>
            orgs.where((org) => org.location.id == locationId).toList(),
        orElse: () => [],
      );
    });

final searchedLocationsProvider = Provider<List<LocationModel>>((ref) {
  final query = ref.watch(organizationSearchProvider).toLowerCase();
  final locationsAsync = ref.watch(locationsProvider);

  if (query.isEmpty) return [];

  return locationsAsync.maybeWhen(
    data: (locs) => locs
        .where(
          (l) =>
              l.name.toLowerCase().contains(query) ||
              l.physicalAddress.toLowerCase().contains(query),
        )
        .toList(),
    orElse: () => [],
  );
});
