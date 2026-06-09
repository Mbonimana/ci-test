import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/core/network/network_error_handler.dart';
import 'package:street_team/data/models/location_models/location_request_model.dart';
import 'package:street_team/data/models/location_models/location_response.dart';
import 'package:street_team/data/repositories/location_repository.dart';
import 'package:street_team/data/services/local_storage/local_database_helper.dart';
import 'package:street_team/data/services/local_storage/location_sync_engine.dart';

// Initial Sync Provider
final initialSyncProvider =
    StateNotifierProvider<InitialSyncNotifier, InitialSyncState>((ref) {
      return InitialSyncNotifier(ref);
    });

class InitialSyncNotifier extends StateNotifier<InitialSyncState> {
  final Ref _ref;
  late final SyncEngine _syncEngine;

  InitialSyncNotifier(this._ref)
    : super(
        InitialSyncState(
          status: InitialSyncStatus.idle,
          currentPage: 0,
          totalPages: 0,
        ),
      ) {
    _syncEngine = SyncEngine();
  }

  Future<void> syncModifiedData() async {
    await _syncEngine.syncModifiedData(
      onStateChanged: (newState) => state = newState,
      onFallbackToColdSync: () => checkAndSync(),
      onInvalidate: () => _ref.invalidate(locationsProvider),
    );
  }

  Future<void> checkAndSync() async {
    await _syncEngine.checkAndSync(
      onStateChanged: (newState) => state = newState,
      onInvalidate: () => _ref.invalidate(locationsProvider),
    );
  }
}

// Repository provider
final locationRepoProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

// FutureProvider that reads directly from local file database on load
final locationsProvider = FutureProvider<List<LocationResponse>>((ref) async {
  final repo = ref.watch(locationRepoProvider);
  return await repo.fetchLocationsForMap();
});

// Search provider
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
  final Ref ref;
  int _currentPage = 1;

  DiscoveryNotifier(this.repo, this.ref) : super([]);

  Future<void> fetchNextPage() async {
    _currentPage++;
    final results = await repo.fetchMoreLocations(_currentPage);

    try {
      final localMap = await LocalDatabaseHelper.readLocations();
      final response = await DioClient.dio.get(
        "${Endpoints.getLocations}&page=$_currentPage",
      );
      final List rawItems = response.data['data'] ?? [];
      for (var item in rawItems) {
        final String id = item['murugo_location_id'].toString();
        localMap[id] = item;
      }
      await LocalDatabaseHelper.writeLocations(localMap);
      ref.invalidate(locationsProvider);
    } catch (_) {}

    state = [...state, ...results];
  }

  void injectLocation(LocationResponse location) {
    if (state.any((loc) => loc.id == location.id)) return;
    state = [...state, location];
  }
}

final otherResultsProvider =
    StateNotifierProvider<DiscoveryNotifier, List<LocationResponse>>((ref) {
      final repo = ref.watch(locationRepoProvider);
      return DiscoveryNotifier(repo, ref);
    });

// Combined Provider for the Map
final filteredLocationsProvider = Provider<List<LocationResponse>>((ref) {
  final locationsAsync = ref.watch(locationsProvider);
  final healthResults = ref.watch(otherResultsProvider);

  List<LocationResponse> all = [];
  locationsAsync.whenData((list) => all.addAll(list));
  all.addAll(healthResults);

  return all;
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

// Form notifier
class LocationFormNotifier extends StateNotifier<LocationFormState> {
  final LocationRepository repo;
  final Ref ref;

  LocationFormNotifier(this.repo, this.ref) : super(LocationFormState());

  Future<void> loadLocation(String id) async {
    state = state.copyWith(loading: true);
    final data = await repo.getLocationById(id);
    state = LocationFormState(initial: data, loading: false);
  }

  void resetFormState() {
    state = LocationFormState();
  }

  Future<void> submitLocation(LocationModel model, {String? editId}) async {
    try {
      Response response;
      if (editId == null) {
        response = await repo.submitLocation(model);
      } else {
        response = await repo.updateLocation(editId, model);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final updatedData = response.data['data'];
          if (updatedData != null) {
            final localMap = await LocalDatabaseHelper.readLocations();
            final String id = updatedData['murugo_location_id'].toString();
            localMap[id] = updatedData;
            await LocalDatabaseHelper.writeLocations(localMap);
            ref.invalidate(locationsProvider);
          }
        }
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          "Server Error: ${response.data['message'] ?? 'Unknown error'}",
        );
      }
    } on DioException catch (e) {
      throw Exception(NetworkErrorHandler.toUserMessage(e));
    } catch (e) {
      throw Exception(NetworkErrorHandler.toUserMessage(e));
    }
  }
}

final locationFormProvider =
    StateNotifierProvider<LocationFormNotifier, LocationFormState>((ref) {
      final repo = ref.watch(locationRepoProvider);
      return LocationFormNotifier(repo, ref);
    });
