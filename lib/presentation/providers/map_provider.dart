import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:street_team/data/map_engine/map_engine.dart';
import 'package:street_team/data/map_engine/mapbox_map_engine.dart';
import 'package:street_team/data/models/organization_feature.dart';
import 'package:street_team/data/repositories/organization_repository.dart';

final mapRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
});

final mapEngineProvider = Provider<MapEngine>((ref) {
  return MapboxMapEngine();
});

final organizationFeaturesProvider = FutureProvider<List<OrganizationFeature>>((
  ref,
) async {
  final repository = ref.watch(mapRepositoryProvider);

  return repository.loadOrganizations();
});

final organizationTypeFilterProvider = StateProvider<Set<String>>((ref) {
  return <String>{};
});

final selectedOrganizationProvider = StateProvider<OrganizationFeature?>((ref) {
  return null;
});

final filteredOrganizationFeaturesProvider =
    Provider<List<OrganizationFeature>>((ref) {
      final organizationsAsync = ref.watch(organizationFeaturesProvider);
      final activeTypes = ref.watch(organizationTypeFilterProvider);

      return organizationsAsync.maybeWhen(
        data: (organizations) {
          if (activeTypes.isEmpty) {
            return organizations;
          }

          return organizations
              .where(
                (organization) =>
                    activeTypes.contains(organization.primaryType),
              )
              .toList(growable: false);
        },
        orElse: () => const <OrganizationFeature>[],
      );
    });

final userLocationProvider = Provider<geo.LatLng>((ref) {
  return geo.LatLng(-1.9441, 30.0619);
});
