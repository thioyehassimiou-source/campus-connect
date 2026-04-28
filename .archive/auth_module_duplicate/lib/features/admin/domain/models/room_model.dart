class RoomModel {
  final String id;
  final String blockId;
  final String name;
  final int? capacity;

  const RoomModel({
    required this.id,
    required this.blockId,
    required this.name,
    this.capacity,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: (map['id'] ?? '').toString(),
      blockId: (map['block_id'] ?? map['bloc_id'] ?? '').toString(),
      name: (map['name'] ?? map['nom'] ?? '').toString(),
      capacity: map['capacity'] is int
          ? map['capacity'] as int
          : int.tryParse((map['capacity'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toInsert() {
    return {
      'block_id': blockId,
      'name': name,
      'capacity': capacity,
    };
  }
}
