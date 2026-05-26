
class TypeModel {
  final int id;
  final String name;
  final String category;
  final List<SubTypeModel> subTypes;

  TypeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subTypes,
  });

  factory TypeModel.fromJson(Map<String, dynamic> json) {
    return TypeModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subTypes: (json['sub_types'] as List<dynamic>? ?? [])
          .map((e) => SubTypeModel.fromJson(e))
          .toList(),
    );
  }
}

class SubTypeModel {
  final int id;
  final String name;

  SubTypeModel({
    required this.id,
    required this.name,
  });

  factory SubTypeModel.fromJson(Map<String, dynamic> json) {
    return SubTypeModel(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}