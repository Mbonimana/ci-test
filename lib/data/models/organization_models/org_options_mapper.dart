Map<String, dynamic> buildBackendPayload({
  required List<Map<String, dynamic>> selectedFeatures,
  required String onlineMenuUrl,
  required Map<String, dynamic> workingHoursData,
}) {
  // 1. Map of standard feature UI option IDs to backend keys
  const Map<int, String> featureIdToBackendKey = {
    2: "delivery_available",
    4: "brunch_available",
    6: "has_bar",
    7: "work_friendly",
    8: "has_wifi",
    9: "reservation_required",
    10: "has_ATM",
    11: "has_parking",
    12: "has_coffee",
    13: "wheelchair_accessible",
    14: "family_friendly",
    15: "swimming_pool",
    16: "has_gym",
    17: "has_spa",
    18: "pool_table",
    19: "is_tourism",
    20: "is_night_life",
    21: "has_food",
    22: "has_shopping",
    23: "has_guhemba_menu",
    24: "has_guhemba",
    25: "has_takeaway",
    26: "kids_activities",
    27: "sunday_school",
    28: "outdoor_activities",
  };

  // Extract selected IDs (excluding ID 29, which is the independent Online Menu)
  final Set<int> selectedIds = selectedFeatures
      .map((item) => item['id'] as int?)
      .whereType<int>()
      .toSet();

  final Map<String, int> optionsMap = {};

  // Build features part of the options map
  featureIdToBackendKey.forEach((id, backendKey) {
    optionsMap[backendKey] = selectedIds.contains(id) ? 1 : 0;
  });

  // Extract and map working hour boolean states
  final bool isActive = workingHoursData['isActive'] ?? false;
  final bool isOpen24 = workingHoursData['isOpen24'] ?? false;
  final bool isTempClosed = workingHoursData['isTempClosed'] ?? false;

  optionsMap['is_active'] = isActive ? 1 : 0;
  optionsMap['is_open_24_hours'] = isOpen24 ? 1 : 0;
  optionsMap['is_temporary_closed'] = isTempClosed ? 1 : 0;

  // 2. Extract independent fields
  final String? possibleReturnDate = workingHoursData['possibleReturnDate'];
  final Map<String, dynamic> weeklyHours =
      workingHoursData['weeklyHours'] ?? {};
  final bool hasOnlineMenu = selectedIds.contains(29);

  return {
    "options": optionsMap,
    "online_menu_url": hasOnlineMenu ? onlineMenuUrl : null,
    "possible_return_date": possibleReturnDate,
    "working_hours": weeklyHours, // Map format from workingHours
  };
}
