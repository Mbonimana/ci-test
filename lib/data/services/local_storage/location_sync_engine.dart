import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/data/services/local_storage/local_database_helper.dart';

enum InitialSyncStatus { idle, syncing, completed, error }

class InitialSyncState {
  final InitialSyncStatus status;
  final int currentPage;
  final int totalPages;
  final String errorMessage;

  InitialSyncState({
    required this.status,
    required this.currentPage,
    required this.totalPages,
    this.errorMessage = '',
  });
}

class SyncEngine {
  SyncEngine();

  /// last successful sync timestamp to prevent downloading the entire database again.
  Future<void> syncModifiedData({
    required void Function(InitialSyncState) onStateChanged,
    required Future<void> Function() onFallbackToColdSync,
    required void Function() onInvalidate,
  }) async {
    // Retrieve the metadata timestamp of the last successful sync
    final timestamp = await LocalDatabaseHelper.getLastSyncTimestamp();

    // If no previous sync timestamp exists, automatically fallback to a full cold sync
    if (timestamp == null) {
      await onFallbackToColdSync();
      return;
    }

    onStateChanged(
      InitialSyncState(
        status: InitialSyncStatus.completed,
        currentPage: 0,
        totalPages: 0,
      ),
    );

    try {
      final dio = DioClient.dio;
      final String url = "${Endpoints.getLocations}&last_updated_at=$timestamp";
      final response = await dio.get(url);
      final List updatedItems = response.data['data'] ?? [];

      if (updatedItems.isNotEmpty) {
        final localMap = await LocalDatabaseHelper.readLocations();
        for (var json in updatedItems) {
          final String id = json['murugo_location_id'].toString();
          localMap[id] = json;
        }

        await LocalDatabaseHelper.writeLocations(localMap);

        onInvalidate();
      }

      await LocalDatabaseHelper.saveLastSyncTimestamp(
        DateTime.now().toUtc().toIso8601String(),
      );
    } catch (_) {}
  }

  Future<void> checkAndSync({
    required void Function(InitialSyncState) onStateChanged,
    required void Function() onInvalidate,
  }) async {
    final existingData = await LocalDatabaseHelper.readLocations();
    final timestamp = await LocalDatabaseHelper.getLastSyncTimestamp();

    // If local database is already populated, skip download and mark as completed
    if (existingData.isNotEmpty && timestamp != null) {
      onStateChanged(
        InitialSyncState(
          status: InitialSyncStatus.completed,
          currentPage: 0,
          totalPages: 0,
        ),
      );
      return;
    }

    // Initialize the loading UI overlay state
    onStateChanged(
      InitialSyncState(
        status: InitialSyncStatus.syncing,
        currentPage: 1,
        totalPages: 1,
      ),
    );

    try {
      final Map<String, dynamic> allMergedLocations = {};
      final dio = DioClient.dio;

      // Fetch Page 1 dynamically first to discover total page count from metadata
      final response = await dio.get("${Endpoints.getLocations}&page=1");
      final meta = response.data['meta'];
      final int lastPage = meta['last_page'] ?? 1;

      final List initialItems = response.data['data'] ?? [];
      for (var json in initialItems) {
        final String id = json['murugo_location_id'].toString();
        allMergedLocations[id] = json;
      }

      onStateChanged(
        InitialSyncState(
          status: InitialSyncStatus.syncing,
          currentPage: 1,
          totalPages: lastPage,
        ),
      );

      for (int page = 2; page <= lastPage; page++) {
        final pageResponse = await dio.get(
          "${Endpoints.getLocations}&page=$page",
        );
        final List pageItems = pageResponse.data['data'] ?? [];
        for (var json in pageItems) {
          final String id = json['murugo_location_id'].toString();
          allMergedLocations[id] = json;
        }

        // Notify UI of current download progress page
        onStateChanged(
          InitialSyncState(
            status: InitialSyncStatus.syncing,
            currentPage: page,
            totalPages: lastPage,
          ),
        );
      }

      // Write the complete initial map database to file storage
      await LocalDatabaseHelper.writeLocations(allMergedLocations);
      await LocalDatabaseHelper.saveLastSyncTimestamp(
        DateTime.now().toUtc().toIso8601String(),
      );

      onInvalidate();
      onStateChanged(
        InitialSyncState(
          status: InitialSyncStatus.completed,
          currentPage: lastPage,
          totalPages: lastPage,
        ),
      );
    } catch (e) {
      onStateChanged(
        InitialSyncState(
          status: InitialSyncStatus.error,
          currentPage: 0,
          totalPages: 0,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine();
});
