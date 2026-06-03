import 'package:flutter_test/flutter_test.dart';
import 'package:street_team/data/models/organization_models/organization_request.dart'; 

void main() {
  group('OrganizationRequestModel Initialization', () {
    test('instantiates with all provided arguments successfully', () {
      const model = OrganizationRequestModel(
        action: 'NEW',
        name: 'Team Hub',
        type: 'non-profit',
        submitterServer: 'server_1',
        submitterAtName: 'Agent Alpha',
        types: [1],
        subTypes: [2],
        userLocation: {'latitude': 1.0, 'longitude': 2.0},
        workingHoursData: {'is_active': true},
        selectedOptions: [],
      );

      expect(model.action, 'NEW');
      expect(model.name, 'Team Hub');
      expect(model.type, 'non-profit');
      expect(model.submitterServer, 'server_1');
      expect(model.submitterAtName, 'Agent Alpha');
    });
  });

  group('toJson Serialization Logic', () {
    final defaultWorkingHours = {
      'is_active': true,
      'is_open_24_hours': false,
      'is_temporary_closed': false,
      'weekly_hours': {},
    };

    test('serializes standard update/edit action (non-NEW) correctly', () {
      const model = OrganizationRequestModel(
        action: 'UPDATE',
        name: 'Alpha Corps',
        type: 'corporate',
        submitterServer: 'server_1',
        submitterAtName: 'Agent Alpha',
        types: [1],
        subTypes: [10],
        userLocation: {'latitude': -1.9, 'longitude': 30.0},
        workingHoursData: {
          'is_active': true,
          'is_open_24_hours': false,
          'is_temporary_closed': false,
          'weekly_hours': {},
        },
        selectedOptions: [],
        murugoLocationId: '123', // String format to test tryParse logic
        murugoOrganizationId: 456,
        phone: '+250780000000',
        quickInfo: 'Info text',
        website: 'https://alpha.corp',
        onlineMenu: '', // Empty to test emptyToNull logic
      );

      final payload = model.toJson();

      expect(payload['action'], 'UPDATE');
      expect(payload['name'], 'Alpha Corps');
      expect(payload['type'], 'corporate');
      expect(payload['phone'], '+250780000000');
      expect(payload['quick_info'], 'Info text');
      expect(payload['website'], 'https://alpha.corp');

      // Verifies string parsing helper handles String-to-Int mapping successfully
      expect(payload['murugo_location_id'], 123);
      expect(payload['murugo_organization_id'], 456);

      // Verifies location properties meant for NEW actions are not appended
      expect(payload.containsKey('location_name'), isFalse);
    });

    test(
      'structures payload correctly for "NEW" action and merges newLocationData',
      () {
        final newLocData = {
          'location_name': 'New HQ Store',
          'short_name': 'NHQ',
          'nickname': 'HQ East',
          'physical_address': 'Avenue St 5',
          'latitude': -1.94,
          'longitude': 30.06,
          'location_types': [
            '1',
            '2',
            3,
          ], // Mixed types to test integer array parsing
        };

        final model = OrganizationRequestModel(
          action: 'new', // lowercase to test action.toUpperCase() comparison
          name: 'HQ Org',
          type: 'retail',
          submitterServer: 'server_prod',
          submitterAtName: 'Field Operative',
          types: [5],
          subTypes: [55],
          userLocation: {'latitude': -1.94, 'longitude': 30.06},
          workingHoursData: defaultWorkingHours,
          selectedOptions: [],
          newLocationData: newLocData,
          murugoLocationId: '999', // should be removed in NEW actions
        );

        final payload = model.toJson();

        expect(payload['action'], 'new');
        expect(payload['location_name'], 'New HQ Store');
        expect(payload['short_name'], 'NHQ');
        expect(payload['nickname'], 'HQ East');
        expect(payload['physical_address'], 'Avenue St 5');
        expect(payload['latitude'], -1.94);
        expect(payload['longitude'], 30.06);

        // Verifies conversion list parser returns parsed integer lists
        expect(payload['location_types'], [1, 2, 3]);

        // Verifies location id is removed when action is NEW
        expect(payload.containsKey('murugo_location_id'), isFalse);
      },
    );

    test(
      'falls back to location name key if location_name is absent in newLocationData',
      () {
        final newLocData = {
          'name': 'Fallback Name Key',
          'physical_address': 'Avenue St 5',
        };

        final model = OrganizationRequestModel(
          action: 'NEW',
          name: 'HQ Org',
          type: 'retail',
          submitterServer: 'server_prod',
          submitterAtName: 'Field Operative',
          types: [],
          subTypes: [],
          userLocation: {},
          workingHoursData: defaultWorkingHours,
          selectedOptions: [],
          newLocationData: newLocData,
        );

        final payload = model.toJson();

        expect(payload['location_name'], 'Fallback Name Key');
      },
    );

    test('normalizes empty string entries to null values', () {
      const model = OrganizationRequestModel(
        action: 'UPDATE',
        name: 'Test Org',
        type: 'test',
        submitterServer: 'server',
        submitterAtName: 'Tester',
        types: [],
        subTypes: [],
        userLocation: {},
        workingHoursData: {},
        selectedOptions: [],
        onlineMenu:
            '   ', // Whitespace strings to verify trim and empty-to-null filter
      );

      final payload = model.toJson();

      expect(payload['online_menu'], isNull);
    });
  });
}
