import 'package:flutter_test/flutter_test.dart';
import 'package:street_team/data/models/location_models/location_request_model.dart';

void main() {
  group('LocationModel Constructor', () {
    test('instantiates correctly with all fields provided', () {
      final model = LocationModel(
        name: 'Main Office',
        physicalAddress: '123 Main Street',
        shortName: 'MO',
        nickname: 'HQ',
        latitude: -1.2921,
        longitude: 36.8219,
        types: [1, 2],
        submitterServer: 'server_01',
        submitterAtName: 'Admin',
        userLocation: {'street': 'Main Rd'},
      );

      expect(model.name, 'Main Office');
      expect(model.physicalAddress, '123 Main Street');
      expect(model.shortName, 'MO');
      expect(model.nickname, 'HQ');
      expect(model.latitude, -1.2921);
      expect(model.longitude, 36.8219);
      expect(model.types, [1, 2]);
      expect(model.submitterServer, 'server_01');
      expect(model.submitterAtName, 'Admin');
      expect(model.userLocation, {'street': 'Main Rd'});
    });
  });

  group('LocationModel.fromJson', () {
    test('parses a complete and valid JSON map successfully', () {
      final json = {
        'name': 'Kigali Hub',
        'physical_address': 'KN 78 St',
        'short_name': 'KH',
        'nickname': 'Hub',
        'latitude': -1.9441,
        'longitude': 30.0619,
        'types': [3, 4],
        'submitter_server': 'prod_server',
        'submitter_at_name': 'Field Agent',
        'user_location': {'street': 'KN 78'},
      };

      final model = LocationModel.fromJson(json);

      expect(model.name, 'Kigali Hub');
      expect(model.physicalAddress, 'KN 78 St');
      expect(model.shortName, 'KH');
      expect(model.nickname, 'Hub');
      expect(model.latitude, -1.9441);
      expect(model.longitude, 30.0619);
      expect(model.types, [3, 4]);
      expect(model.submitterServer, 'prod_server');
      expect(model.submitterAtName, 'Field Agent');
      expect(model.userLocation, {'street': 'KN 78'});
    });

    test(
      'uses safe default fallbacks when JSON contains null values or missing fields',
      () {
        final json = <String, dynamic>{}; // Empty JSON Map

        final model = LocationModel.fromJson(json);

        expect(model.name, '');
        expect(model.physicalAddress, '');
        expect(model.shortName, isNull);
        expect(model.nickname, isNull);
        expect(model.latitude, 0.0);
        expect(model.longitude, 0.0);
        expect(model.types, isEmpty);
        expect(model.submitterServer, '');
        expect(model.submitterAtName, '');
        expect(model.userLocation, isEmpty);
      },
    );

    test(
      'handles coordinate casting safely when latitude/longitude are integers instead of doubles',
      () {
        final json = {
          'latitude': -1, // Int value
          'longitude': 30, // Int value
        };

        final model = LocationModel.fromJson(json);

        expect(model.latitude, -1.0);
        expect(model.longitude, 30.0);
      },
    );
  });

  group('LocationModel.toJson', () {
    test('serializes fields to a valid JSON map representation', () {
      final model = LocationModel(
        name: 'Hub 2',
        physicalAddress: 'Avenue 5',
        shortName: 'H2',
        nickname: 'Secondary',
        latitude: -1.5,
        longitude: 30.5,
        types: [5],
        submitterServer: 'test_server',
        submitterAtName: 'Tester',
        userLocation: {'street': 'Avenue 5'},
      );

      final json = model.toJson();

      expect(json['name'], 'Hub 2');
      expect(json['physical_address'], 'Avenue 5');
      expect(json['short_name'], 'H2');
      expect(json['nickname'], 'Secondary');
      expect(json['latitude'], -1.5);
      expect(json['longitude'], 30.5);
      expect(json['types'], [5]);
      expect(json['submitter_server'], 'test_server');
      expect(json['submitter_at_name'], 'Tester');
      expect(json['user_location'], {'street': 'Avenue 5'});
    });
  });

  group('hasValidCoordinates Validation Logic', () {
    test(
      'returns true when both latitude and longitude are non-zero values',
      () {
        final model = LocationModel(
          name: 'Valid Loc',
          physicalAddress: 'Address',
          latitude: -1.23,
          longitude: 36.45,
          types: [],
          submitterServer: '',
          submitterAtName: '',
          userLocation: {},
        );

        expect(model.hasValidCoordinates, isTrue);
      },
    );

    test('returns false when latitude is 0.0', () {
      final model = LocationModel(
        name: 'Invalid Lat',
        physicalAddress: 'Address',
        latitude: 0.0,
        longitude: 36.45,
        types: [],
        submitterServer: '',
        submitterAtName: '',
        userLocation: {},
      );

      expect(model.hasValidCoordinates, isFalse);
    });

    test('returns false when longitude is 0.0', () {
      final model = LocationModel(
        name: 'Invalid Lng',
        physicalAddress: 'Address',
        latitude: -1.23,
        longitude: 0.0,
        types: [],
        submitterServer: '',
        submitterAtName: '',
        userLocation: {},
      );

      expect(model.hasValidCoordinates, isFalse);
    });

    test('returns false when both coordinates are 0.0', () {
      final model = LocationModel(
        name: 'Invalid Both',
        physicalAddress: 'Address',
        latitude: 0.0,
        longitude: 0.0,
        types: [],
        submitterServer: '',
        submitterAtName: '',
        userLocation: {},
      );

      expect(model.hasValidCoordinates, isFalse);
    });
  });

  group('buildUserLocation Utility', () {
    test('builds user location map output correctly', () {
      final result = LocationModel.buildUserLocation(
        street: 'Avenue de la Paix',
        latitude: -1.94,
        longitude: 30.06,
      );

      expect(result, {
        'street': 'Avenue de la Paix',
        'latitude': -1.94,
        'longitude': 30.06,
      });
    });
  });
}
