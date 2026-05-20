import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:street_team/data/map_engine/map_engine.dart';
import 'package:street_team/data/map_engine/mapbox_map_engine.dart';
import 'package:street_team/data/models/organization_model.dart';
import 'package:street_team/data/repositories/organization_repository.dart';

//repository

final mapRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository();
});

///map engine

final mapEngineProvider = Provider<MapEngine>((ref) {
  return MapboxMapEngine();
});

//organization

final organizationFeaturesProvider = FutureProvider<List<OrganizationModel>>((
  ref,
) async {
  final repository = ref.watch(mapRepositoryProvider);

  return repository.loadOrganizations();
});

//filters

final organizationTypeFilterProvider = StateProvider<Set<String>>((ref) {
  return <String>{};
});

//selected organization

final selectedOrganizationProvider = StateProvider<OrganizationModel?>((ref) {
  return null;
});

//filtered organizations

final filteredOrganizationFeaturesProvider = Provider<List<OrganizationModel>>((
  ref,
) {
  final organizationsAsync = ref.watch(organizationFeaturesProvider);

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

// user location

final userLocationProvider = Provider<geo.LatLng>((ref) {
  return geo.LatLng(-1.9441, 30.0619);
});
