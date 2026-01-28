class Salle {
  final String id;
  final String nom;
  final int capacite;
  final TypeSalle type;
  final String? localisation;
  final String? description;

  Salle({
    required this.id,
    required this.nom,
    required this.capacite,
    required this.type,
    this.localisation,
    this.description,
  });

  factory Salle.fromJson(Map<String, dynamic> json) {
    return Salle(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      capacite: json['capacite'] ?? 0,
      type: _parseType(json['type']),
      localisation: json['localisation'],
      description: json['description'],
    );
  }

  static TypeSalle _parseType(dynamic typeValue) {
    if (typeValue == null) return TypeSalle.classRoom;
    final typeStr = typeValue.toString().toLowerCase();
    if (typeStr.contains('lab')) return TypeSalle.laboratoire;
    if (typeStr.contains('amphi')) return TypeSalle.amphitheatre;
    if (typeStr.contains('bureau')) return TypeSalle.bureau;
    return TypeSalle.classRoom;
  }
}

enum TypeSalle {
  classRoom,
  laboratoire,
  amphitheatre,
  bureau,
}

class Zone {
  final String id;
  final String nom;
  final String? description;
  final List<String> salles;

  Zone({
    required this.id,
    required this.nom,
    this.description,
    required this.salles,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      description: json['description'],
      salles: List<String>.from(json['salles'] ?? []),
    );
  }
}
