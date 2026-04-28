import 'enums.dart';

class BlocBatiment {
  final String id;
  final String nom;
  final int capacite;
  final String zone;

  BlocBatiment({
    required this.id,
    required this.nom,
    required this.capacite,
    required this.zone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'capacite': capacite,
      'zone': zone,
    };
  }

  factory BlocBatiment.fromMap(Map<String, dynamic> map) {
    return BlocBatiment(
      id: map['id'],
      nom: map['nom'],
      capacite: map['capacite'],
      zone: map['zone'],
    );
  }
}

class Salle {
  final String id;
  final String nom;
  final int capacite;
  final TypeSalle type;

  Salle({
    required this.id,
    required this.nom,
    required this.capacite,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'capacite': capacite,
      'type': type.name,
    };
  }

  factory Salle.fromMap(Map<String, dynamic> map) {
    return Salle(
      id: map['id'],
      nom: map['nom'],
      capacite: map['capacite'],
      type: TypeSalle.values.firstWhere((t) => t.name == map['type']),
    );
  }
}
