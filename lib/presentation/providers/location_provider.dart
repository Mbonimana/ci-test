import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/data/models/location_model.dart';
import 'package:street_team/data/repositories/location_repository.dart';

// Repository provider
final locationRepoProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

//state
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
