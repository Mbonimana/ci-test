class EntityType {
  final int id;
  final String name;

  EntityType({required this.id, required this.name});

  factory EntityType.fromJson(Map<String, dynamic> json) {
    return EntityType(id: json['id'] as int, name: json['name'] as String);
  }
}
