import 'package:street_team/data/models/user_model.dart';

class LocationPayloadModel {
  final String action;

  final String locationName;
  final String physicalAddress;
  final double latitude;
  final double longitude;

  final List<int> locationTypes;
  final String name;
  final String type;

  final String? phone;
  final String? website;
  final String? onlineMenu;

  final int? murugoOrganizationId;
  final String? murugoLocationId;

  final String submitterServer;
  final String submitterAtName;

  final List<int> types;
  final List<int> subTypes;

  final UserLocation userLocation;

  final Map<String, List<OpeningHour>> openingHours;

  final OptionsModel options;

  final String? orgBuildingInfo;

  LocationPayloadModel({
    required this.action,
    required this.locationName,
    required this.physicalAddress,
    required this.latitude,
    required this.longitude,
    required this.locationTypes,
    required this.name,
    required this.type,
    required this.submitterServer,
    required this.submitterAtName,
    required this.types,
    required this.subTypes,
    required this.userLocation,
    required this.openingHours,
    required this.options,
    this.phone,
    this.website,
    this.onlineMenu,
    this.murugoOrganizationId,
    this.murugoLocationId,
    this.orgBuildingInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      "action": action,
      "location_name": locationName,
      "physical_address": physicalAddress,
      "latitude": latitude,
      "longitude": longitude,
      "location_types": locationTypes,
      "name": name,
      "type": type,
      "phone": phone,
      "website": website,
      "online_menu": onlineMenu,
      "murugo_organization_id": murugoOrganizationId,
      "murugo_location_id": murugoLocationId,
      "submitter_server": submitterServer,
      "submitter_at_name": submitterAtName,
      "types": types,
      "sub_types": subTypes,
      "user_location": userLocation.toJson(),
      "opening_hours": openingHours.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      "options": options.toJson(),
      "org_building_info": orgBuildingInfo,
    };
  }
}

class OpeningHour {
  final String open;
  final String close;

  OpeningHour({required this.open, required this.close});

  Map<String, dynamic> toJson() => {"open": open, "close": close};
}

class OptionsModel {
  final int hasBar;
  final int hasFood;
  final int hasCoffee;
  final int hasWifi;
  final int isActive;
  final int isBest;
  final int isNew;
  final int hasATM;
  final int hasShopping;
  final int isTourism;
  final int isPerson;
  final int isOpen24Hours;
  final int isNightLife;

  OptionsModel({
    this.hasBar = 0,
    this.hasFood = 0,
    this.hasCoffee = 0,
    this.hasWifi = 0,
    this.isActive = 1,
    this.isBest = 0,
    this.isNew = 1,
    this.hasATM = 0,
    this.hasShopping = 0,
    this.isTourism = 0,
    this.isPerson = 0,
    this.isOpen24Hours = 0,
    this.isNightLife = 0,
  });

  Map<String, dynamic> toJson() => {
    "has_bar": hasBar,
    "has_food": hasFood,
    "has_coffee": hasCoffee,
    "has_wifi": hasWifi,
    "is_active": isActive,
    "is_best": isBest,
    "is_new": isNew,
    "has_ATM": hasATM,
    "has_shopping": hasShopping,
    "is_tourism": isTourism,
    "is_person": isPerson,
    "is_open_24_hours": isOpen24Hours,
    "isNightLife": isNightLife,
  };
}
