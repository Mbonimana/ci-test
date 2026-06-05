import 'package:flutter_test/flutter_test.dart';
import 'package:street_team/data/models/organization_models/organization_response.dart'; // Adjust path
import 'package:street_team/data/models/types_model.dart';

void main() {
  group('OrganizationResponseModel Constructor', () {
    test('instantiates correctly with default collections', () {
      final model = OrganizationResponseModel(name: 'Test Corp');

      expect(model.name, 'Test Corp');
      expect(model.types, isEmpty);
      expect(model.subTypes, isEmpty);
    });
  });

  group('OrganizationResponseModel.fromJson Mapping', () {
    test('parses complete JSON mapping with exact field configurations', () {
      final json = {
        'murugo_organization_id': 101,
        'murugo_location_id': 'loc-55',
        'name': 'Kigali Health Center',
        'phone': '+25078000',
        'address': 'Kigali, Rwanda',
        'website': 'https://kigalihealth.org',
        'quick_info': 'General clinic services',
        'type': 'Health',
        'online_menu': '',
        'submitter_server': 'prod_01',
        'submitter_at_name': 'Field Agent 1',
        'types': [
          {'id': 1, 'name': 'Medical'},
        ],
        'sub_types': [10, 11],
        'is_active': 1,
        'is_approved': 1,
        'is_best': 0,
        'is_new': 1,
        'is_person': 0,
        'is_open_24_hours': 1,
        'isNightLife': 0,
        'has_bar': 0,
        'has_food': 1,
        'has_coffee': 1,
        'has_wifi': 1,
        'has_ATM': 0,
        'has_shopping': 0,
        'is_tourism': 0,
        'has_guhemba': 1,
        'has_guhemba_menu': 0,
        'iSTemporaryClosed': 0,
        'options': {'delivery': true},
        'opening_hours': '08:00 - 17:00',
        'normal_opening_hours': '08:00',
        'normal_closing_hours': '17:00',
        'weekend_opening_hours': '09:00',
        'weekend_closing_hours': '15:00',
        'dataEnteredPhase': 'Phase 2',
        'org_building_info': 'Building B, Floor 1',
        'is_HK_active': true,
        'is_tempo_updated': false,
      };

      final model = OrganizationResponseModel.fromJson(json);

      expect(model.murugoOrganizationId, 101);
      expect(model.murugoLocationId, 'loc-55');
      expect(model.name, 'Kigali Health Center');
      expect(model.phone, '+25078000');
      expect(model.address, 'Kigali, Rwanda');
      expect(model.website, 'https://kigalihealth.org');
      expect(model.quickInfo, 'General clinic services');
      expect(model.onlineMenu, '');
      expect(model.submitterServer, 'prod_01');
      expect(model.submitterAtName, 'Field Agent 1');

      // Types list verification
      expect(model.types, hasLength(1));
      expect(model.types.first, isA<TypeModel>());
      expect(model.types.first.id, 1);

      // Subtypes parsing
      expect(model.subTypes, [10, 11]);

      // Integer mappings from nums
      expect(model.isActive, 1);
      expect(model.isApproved, 1);
      expect(model.isBest, 0);
      expect(model.isNew, 1);
      expect(model.isPerson, 0);
      expect(model.isOpen24Hours, 1);
      expect(model.isNightLife, 0);
      expect(model.hasBar, 0);
      expect(model.hasFood, 1);
      expect(model.hasCoffee, 1);
      expect(model.hasWifi, 1);
      expect(model.hasAtm, 0);
      expect(model.hasShopping, 0);
      expect(model.isTourism, 0);
      expect(model.hasGuhemba, 1);
      expect(model.hasGuhembaMenu, 0);
      expect(model.isTemporaryClosed, 0);

      // Map & dynamic payload mappings
      expect(model.options, {'delivery': true});
      expect(model.openingHours, '08:00 - 17:00');
      expect(model.orgBuildingInfo, 'Building B, Floor 1');
      expect(model.isHKActive, true);
      expect(model.isTempoUpdated, false);
    });

    test('uses fallback mapping options when parsing empty or sparse JSON', () {
      final json = <String, dynamic>{};

      final model = OrganizationResponseModel.fromJson(json);

      expect(model.name, '');
      expect(model.phone, '');
      expect(model.website, '');
      expect(model.quickInfo, '');
      expect(model.types, isEmpty);
      expect(model.subTypes, isEmpty);
    });

    test('supports alternative camelCase naming for subTypes key mapping', () {
      final json = {
        'subTypes': [20, 21, 22], // alternate key
      };

      final model = OrganizationResponseModel.fromJson(json);

      expect(model.subTypes, [20, 21, 22]);
    });
  });

  group('_asString Parser Helper Logic', () {
    test('returns empty string when property value is null', () {
      final json = {'phone': null};
      final model = OrganizationResponseModel.fromJson(json);

      expect(model.phone, '');
    });

    test('retains value if property is already a standard String', () {
      final json = {'phone': '+25011111'};
      final model = OrganizationResponseModel.fromJson(json);

      expect(model.phone, '+25011111');
    });

    test(
      'converts non-string/numeric types to standard string automatically',
      () {
        final json = {
          'phone': 788000000, // integer representation
        };
        final model = OrganizationResponseModel.fromJson(json);

        expect(model.phone, '788000000');
      },
    );

    test(
      'resolves mapping properties priority list order when key value is a Map',
      () {
        // Priority 1: 'name' key is present
        final jsonWithName = {
          'name': {'name': 'First Name Priority', 'label': 'Ignore Label'},
        };
        expect(
          OrganizationResponseModel.fromJson(jsonWithName).name,
          'First Name Priority',
        );

        // Priority 2: 'name' key is absent, resolves to 'label'
        final jsonWithLabel = {
          'name': {'label': 'Second Priority Label', 'title': 'Ignore Title'},
        };
        expect(
          OrganizationResponseModel.fromJson(jsonWithLabel).name,
          'Second Priority Label',
        );

        // Priority 3: 'name' and 'label' absent, resolves to 'title'
        final jsonWithTitle = {
          'name': {'title': 'Third Priority Title', 'value': 'Ignore Value'},
        };
        expect(
          OrganizationResponseModel.fromJson(jsonWithTitle).name,
          'Third Priority Title',
        );

        // Priority 4: Falls back to 'value'
        final jsonWithValue = {
          'name': {'value': 'Fourth Priority Value'},
        };
        expect(
          OrganizationResponseModel.fromJson(jsonWithValue).name,
          'Fourth Priority Value',
        );
      },
    );

    test(
      'falls back to standard map stringification when map has no matching priority keys',
      () {
        final json = {
          'name': {'unmatched_key': 'unmatched_value'},
        };
        final model = OrganizationResponseModel.fromJson(json);

        expect(model.name, contains('unmatched_key: unmatched_value'));
      },
    );
  });
}
