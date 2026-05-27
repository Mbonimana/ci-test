import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/data/models/location_model.dart';
import 'package:street_team/data/models/location_response.dart';
import 'package:street_team/data/repositories/location_repository.dart';

// Repository provider
final locationRepoProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

//  Initial locations (Page 1)
final locationsProvider = FutureProvider<List<LocationResponse>>((ref) async {
  final repo = ref.watch(locationRepoProvider);
  return await repo.fetchLocationsForMap();
});

//search
final remoteSearchResultsProvider = FutureProvider<List<LocationResponse>>((
  ref,
) async {
  final query = ref.watch(locationSearchProvider);
  final repo = ref.watch(locationRepoProvider);

  if (query.isEmpty || query.length < 2) return [];

  return await repo.searchLocations(query);
});

class DiscoveryNotifier extends StateNotifier<List<LocationResponse>> {
  final LocationRepository repo;
  int _currentPage = 1;

  DiscoveryNotifier(this.repo) : super([]);

  Future<void> fetchNextPage() async {
    _currentPage++;
    final results = await repo.fetchMoreLocations(_currentPage);

    state = [...state, ...results];
  }

  void injectLocation(LocationResponse location) {
    // Check if it already exists to avoid unnecessary state updates
    if (state.any((loc) => loc.id == location.id)) return;

    state = [...state, location];
  }
}

final otherResultsProvider =
    StateNotifierProvider<DiscoveryNotifier, List<LocationResponse>>((ref) {
      final repo = ref.watch(locationRepoProvider);
      return DiscoveryNotifier(repo);
    });

//  Combined Provider for the Map
final filteredLocationsProvider = Provider<List<LocationResponse>>((ref) {
  final locationsAsync = ref.watch(locationsProvider);
  final healthResults = ref.watch(otherResultsProvider);

  List<LocationResponse> all = [];
  locationsAsync.whenData((list) => all.addAll(list));
  all.addAll(healthResults);

  return all; // Usually, we want all markers visible on the map
});

final locationSearchProvider = StateProvider<String>((ref) => "");

class LocationFormState {
  final LocationModel? initial;
  final bool loading;

  LocationFormState({this.initial, this.loading = false});

  LocationFormState copyWith({LocationModel? initial, bool? loading}) {
    return LocationFormState(
      initial: initial ?? this.initial,
      loading: loading ?? this.loading,
    );
  }
}

final isSearchingProvider = StateProvider<bool>((ref) => false);

//notifier
class LocationFormNotifier extends StateNotifier<LocationFormState> {
  final LocationRepository repo;

  LocationFormNotifier(this.repo) : super(LocationFormState());

  Future<void> loadLocation(String id) async {
    state = state.copyWith(loading: true);
    final data = await repo.getLocationById(id);
    state = LocationFormState(initial: data, loading: false);
  }

  Future<void> submitLocation(LocationModel model, {String? editId}) async {
    try {
      Response response;
      if (editId == null) {
        response = await repo.submitLocation(model);
      } else {
        response = await repo.updateLocation(editId, model);
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          "Server Error: ${response.data['message'] ?? 'Unknown error'}",
        );
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? e.message;
      throw Exception(errorMsg);
    } catch (e) {
      rethrow;
    }
  }
}

final locationFormProvider =
    StateNotifierProvider<LocationFormNotifier, LocationFormState>((ref) {
      final repo = ref.watch(locationRepoProvider);
      return LocationFormNotifier(repo);
    });
