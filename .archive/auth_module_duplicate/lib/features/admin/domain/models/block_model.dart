class BlockModel {
  final String id;
  final String name;
  final String? description;

  const BlockModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory BlockModel.fromMap(Map<String, dynamic> map) {
    return BlockModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? map['nom'] ?? '').toString(),
      description: map['description']?.toString(),
    );
  }

  Map<String, dynamic> toInsert() {
    return {
      'name': name,
      'description': description,
    };
  }
}
