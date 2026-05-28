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
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      website: json['website'],
      quickInfo: json['quick_info'],
      type: json['type'],
      onlineMenu: json['online_menu'],
      submitterServer: json['submitter_server'],
      submitterAtName: json['submitter_at_name'],
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
}
