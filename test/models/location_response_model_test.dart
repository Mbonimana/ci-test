import 'package:flutter_test/flutter_test.dart';
import 'package:street_team/data/models/location_models/location_response.dart'; 
import 'package:street_team/data/models/organization_models/organization_response.dart';

void main() {
  group('LocationTypeResponse', () {
    test('fromJson parses standard id and name successfully', () {
      final json = {'id': 10, 'name': 'Pharmacy'};

      final model = LocationTypeResponse.fromJson(json);

      expect(model.id, 10);
      expect(model.name, 'Pharmacy');
    });

    test('fromJson defaults to an empty string when name key is null', () {
      final json = {'id': 20, 'name': null};

      final model = LocationTypeResponse.fromJson(json);

      expect(model.id, 20);
      expect(model.name, '');
    });
  });

  group('LocationResponse Constructor Initialization', () {
    test('populates fields correctly with direct assignment constructor', () {
      final mockTypes = [LocationTypeResponse(id: 1, name: 'Clinic')];
      final mockOrgs = <OrganizationResponseModel>[];

      final model = LocationResponse(
        id: 101,
        name: 'Main Clinic',
        shortName: 'MC',
        nickname: 'HQ Clinic',
        physicalAddress: '789 Blvd Road',
        latitude: -1.94,
        longitude: 30.06,
        types: mockTypes,
        organizations: mockOrgs,
      );

      expect(model.id, 101);
      expect(model.name, 'Main Clinic');
      expect(model.shortName, 'MC');
      expect(model.nickname, 'HQ Clinic');
      expect(model.physicalAddress, '789 Blvd Road');
      expect(model.latitude, -1.94);
      expect(model.longitude, 30.06);
      expect(model.types, mockTypes);
      expect(model.organizations, mockOrgs);
    });
  });

  group('LocationResponse.fromJson Deserialization', () {
    test('correctly decodes complex JSON payload with nested structures', () {
      final json = {
        'murugo_location_id': 999,
        'name': 'East Point Center',
        'short_name': 'EPC',
        'nickname': 'East Point',
        'physical_address': 'Avenue East 12',
        'latitude': -1.954,
        'longitude': 30.082,
        'types': [
          {'id': 100, 'name': 'Retail Store'},
        ],
        'organizations': [
          {'id': 'org-123', 'name': 'Regional Distribution'},
        ],
      };

      final model = LocationResponse.fromJson(json);

      expect(model.id, 999);
      expect(model.name, 'East Point Center');
      expect(model.shortName, 'EPC');
      expect(model.nickname, 'East Point');
      expect(model.physicalAddress, 'Avenue East 12');
      expect(model.latitude, -1.954);
      expect(model.longitude, 30.082);

      expect(model.types, hasLength(1));
      expect(model.types.first.id, 100);
      expect(model.types.first.name, 'Retail Store');

      expect(model.organizations, hasLength(1));
    });

    test('applies safe defaults when JSON keys are missing or null', () {
      final json = <String, dynamic>{};

      final model = LocationResponse.fromJson(json);

      expect(model.id, 0);
      expect(model.name, '');
      expect(model.shortName, isNull);
      expect(model.nickname, isNull);
      expect(model.physicalAddress, '');
      expect(model.latitude, 0.0);
      expect(model.longitude, 0.0);
      expect(model.types, isEmpty);
      expect(model.organizations, isEmpty);
    });
  });

  group('hasValidCoordinates Validation Logic', () {
    test('returns true when coordinates are non-zero values', () {
      final model = LocationResponse(
        id: 1,
        name: 'Location A',
        physicalAddress: '',
        latitude: -1.94,
        longitude: 30.06,
        types: [],
        organizations: [],
      );

      expect(model.hasValidCoordinates, isTrue);
    });

    test('returns false when latitude is zero', () {
      final model = LocationResponse(
        id: 1,
        name: 'Location A',
        physicalAddress: '',
        latitude: 0.0,
        longitude: 30.06,
        types: [],
        organizations: [],
      );

      expect(model.hasValidCoordinates, isFalse);
    });

    test('returns false when longitude is zero', () {
      final model = LocationResponse(
        id: 1,
        name: 'Location A',
        physicalAddress: '',
        latitude: -1.94,
        longitude: 0.0,
        types: [],
        organizations: [],
      );

      expect(model.hasValidCoordinates, isFalse);
    });
  });

  group('mapLabel Fallback Priority Logic', () {
    test('prioritizes name when name is present', () {
      final model = LocationResponse(
        id: 1,
        name: 'Primary Name',
        nickname: 'Secondary Nickname',
        shortName: 'PN',
        physicalAddress: '',
        latitude: 1.0,
        longitude: 1.0,
        types: [],
        organizations: [],
      );

      expect(model.mapLabel, 'Primary Name');
    });

    test('uses nickname when name is empty and nickname is provided', () {
      final model = LocationResponse(
        id: 1,
        name: '',
        nickname: 'Secondary Nickname',
        shortName: 'PN',
        physicalAddress: '',
        latitude: 1.0,
        longitude: 1.0,
        types: [],
        organizations: [],
      );

      expect(model.mapLabel, 'Secondary Nickname');
    });

    test('uses shortName when name is empty and nickname is null', () {
      final model = LocationResponse(
        id: 1,
        name: '',
        nickname: null,
        shortName: 'PN',
        physicalAddress: '',
        latitude: 1.0,
        longitude: 1.0,
        types: [],
        organizations: [],
      );

      expect(model.mapLabel, 'PN');
    });

    test(
      'returns empty string when all identifying values are empty or null',
      () {
        final model = LocationResponse(
          id: 1,
          name: '',
          nickname: null,
          shortName: null,
          physicalAddress: '',
          latitude: 1.0,
          longitude: 1.0,
          types: [],
          organizations: [],
        );

        expect(model.mapLabel, '');
      },
    );
  });

  group('primaryTypeName Extraction Logic', () {
    test('extracts first type name when types are populated', () {
      final model = LocationResponse(
        id: 1,
        name: 'A-Store',
        physicalAddress: '',
        latitude: 1.0,
        longitude: 1.0,
        types: [
          LocationTypeResponse(id: 1, name: 'Warehouse'),
          LocationTypeResponse(id: 2, name: 'Depot'),
        ],
        organizations: [],
      );

      expect(model.primaryTypeName, 'Warehouse');
    });

    test('returns default fallback "Location" when types are empty', () {
      final model = LocationResponse(
        id: 1,
        name: 'A-Store',
        physicalAddress: '',
        latitude: 1.0,
        longitude: 1.0,
        types: [],
        organizations: [],
      );

      expect(model.primaryTypeName, 'Location');
    });
  });
}
