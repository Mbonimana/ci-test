import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/data/services/local_storage/local_database_helper.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final timestamp = await LocalDatabaseHelper.getLastSyncTimestamp();

      if (timestamp != null) {
        final dio = DioClient.dio;
        final String url =
            "${Endpoints.getLocations}&last_updated_at=$timestamp";

        final response = await dio.get(url);
        final List updatedItems = response.data['data'] ?? [];

        if (updatedItems.isNotEmpty) {
          final localMap = await LocalDatabaseHelper.readLocations();
          for (var json in updatedItems) {
            final String id = json['murugo_location_id'].toString();
            localMap[id] = json;
          }

          await LocalDatabaseHelper.writeLocations(localMap);
        }

        await LocalDatabaseHelper.saveLastSyncTimestamp(
          DateTime.now().toUtc().toIso8601String(),
        );
      }
      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  });
}
