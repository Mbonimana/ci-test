import 'package:street_team/data/models/types_model.dart';

class OrganizationResponseModel {
  final int? murugoOrganizationId;
  final String? murugoLocationId;
  final String name;
  final String? phone;
  final String? address;
  final String? website;
  final String? quickInfo;
  final String? type;
  final String? onlineMenu;
  final String? submitterServer;
  final String? submitterAtName;
  final List<TypeModel> types;
  final List<dynamic> subTypes;
  final int? isActive;
  final int? isApproved;
  final int? isBest;
  final int? isNew;
  final int? isPerson;
  final int? isOpen24Hours;
  final int? isNightLife;
  final int? hasBar;
  final int? hasFood;
  final int? hasCoffee;
  final int? hasWifi;
  final int? hasAtm;
  final int? hasShopping;
  final int? isTourism;
  final int? hasGuhemba;
  final int? hasGuhembaMenu;
  final int? isTemporaryClosed;
  final Map<String, dynamic>? options;
  final dynamic openingHours;
  final dynamic normalOpeningHours;
  final dynamic normalClosingHours;
  final dynamic weekendOpeningHours;
  final dynamic weekendClosingHours;
  final dynamic dataEnteredPhase;
  final dynamic orgBuildingInfo;
  final dynamic isHKActive;
  final dynamic isTempoUpdated;

  OrganizationResponseModel({
    this.murugoOrganizationId,
    this.murugoLocationId,
    required this.name,
    this.phone,
    this.address,
    this.website,
    this.quickInfo,
    this.type,
    this.onlineMenu,
    this.submitterServer,
    this.submitterAtName,
    this.types = const [],
    this.subTypes = const [],
    this.isActive,
    this.isApproved,
    this.isBest,
    this.isNew,
    this.isPerson,
    this.isOpen24Hours,
    this.isNightLife,
    this.hasBar,
    this.hasFood,
    this.hasCoffee,
    this.hasWifi,
    this.hasAtm,
    this.hasShopping,
    this.isTourism,
    this.hasGuhemba,
    this.hasGuhembaMenu,
    this.isTemporaryClosed,
    this.options,
    this.openingHours,
    this.normalOpeningHours,
    this.normalClosingHours,
    this.weekendOpeningHours,
    this.weekendClosingHours,
    this.dataEnteredPhase,
    this.orgBuildingInfo,
    this.isHKActive,
    this.isTempoUpdated,
  });

  factory OrganizationResponseModel.fromJson(Map<String, dynamic> json) {
    return OrganizationResponseModel(
      murugoOrganizationId: (json['murugo_organization_id'] as num?)?.toInt(),
      murugoLocationId: json['murugo_location_id']?.toString(),
      name: _asString(json['name']),
      phone: _asString(json['phone']),
      address: json['address'],
      website: _asString(json['website']),
      quickInfo: _asString(json['quick_info']),
      type: _asString(json['type']),
      onlineMenu: _asString(json['online_menu']),
      submitterServer: _asString(json['submitter_server']),
      submitterAtName: _asString(json['submitter_at_name']),
      types:
          (json['types'] as List<dynamic>?)
              ?.map(
                (type) => TypeModel.fromJson(Map<String, dynamic>.from(type)),
              )
              .toList() ??
          const [],
      subTypes:
          (json['sub_types'] as List<dynamic>?) ??
          (json['subTypes'] as List<dynamic>?) ??
          const [],
      isActive: (json['is_active'] as num?)?.toInt(),
      isApproved: (json['is_approved'] as num?)?.toInt(),
      isBest: (json['is_best'] as num?)?.toInt(),
      isNew: (json['is_new'] as num?)?.toInt(),
      isPerson: (json['is_person'] as num?)?.toInt(),
      isOpen24Hours: (json['is_open_24_hours'] as num?)?.toInt(),
      isNightLife: (json['isNightLife'] as num?)?.toInt(),
      hasBar: (json['has_bar'] as num?)?.toInt(),
      hasFood: (json['has_food'] as num?)?.toInt(),
      hasCoffee: (json['has_coffee'] as num?)?.toInt(),
      hasWifi: (json['has_wifi'] as num?)?.toInt(),
      hasAtm: (json['has_ATM'] as num?)?.toInt(),
      hasShopping: (json['has_shopping'] as num?)?.toInt(),
      isTourism: (json['is_tourism'] as num?)?.toInt(),
      hasGuhemba: (json['has_guhemba'] as num?)?.toInt(),
      hasGuhembaMenu: (json['has_guhemba_menu'] as num?)?.toInt(),
      isTemporaryClosed: (json['iSTemporaryClosed'] as num?)?.toInt(),
      options: json['options'],
      openingHours: json['opening_hours'],
      normalOpeningHours: json['normal_opening_hours'],
      normalClosingHours: json['normal_closing_hours'],
      weekendOpeningHours: json['weekend_opening_hours'],
      weekendClosingHours: json['weekend_closing_hours'],
      dataEnteredPhase: json['dataEnteredPhase'],
      orgBuildingInfo: json['org_building_info'],
      isHKActive: json['is_HK_active'],
      isTempoUpdated: json['is_tempo_updated'],
    );
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final candidates = [
        map['name'],
        map['label'],
        map['title'],
        map['value'],
      ];
      for (final candidate in candidates) {
        if (candidate is String && candidate.isNotEmpty) {
          return candidate;
        }
      }
    }
    return value.toString();
  }
}
