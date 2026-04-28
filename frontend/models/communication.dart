import 'enums.dart';
import 'user.dart';
import 'academique.dart';
import 'infrastructure.dart';

class Annonce {
  final String id;
  final String titre;
  final String contenu;
  final DateTime datePublication;
  final Utilisateur auteur;

  Annonce({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.datePublication,
    required this.auteur,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'datePublication': datePublication.toIso8601String(),
      'auteurId': auteur.id,
    };
  }

  factory Annonce.fromMap(Map<String, dynamic> map, Utilisateur auteur) {
    return Annonce(
      id: map['id'],
      titre: map['titre'],
      contenu: map['contenu'],
      datePublication: DateTime.parse(map['datePublication']),
      auteur: auteur,
    );
  }
}

class Document {
  final String id;
  final String titre;
  final TypeDocument type;
  final String url;
  final Enseignant enseignant;
  final Filiere filiere;

  Document({
    required this.id,
    required this.titre,
    required this.type,
    required this.url,
    required this.enseignant,
    required this.filiere,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'type': type.name,
      'url': url,
      'enseignantId': enseignant.id,
      'filiereId': filiere.id,
    };
  }

  factory Document.fromMap(
    Map<String, dynamic> map,
    Enseignant enseignant,
    Filiere filiere,
  ) {
    return Document(
      id: map['id'],
      titre: map['titre'],
      type: TypeDocument.values.firstWhere((t) => t.name == map['type']),
      url: map['url'],
      enseignant: enseignant,
      filiere: filiere,
    );
  }
}

class ServiceAdministratif {
  final String id;
  final String nom;
  final String responsable;
  final String contact;
  final BlocBatiment bloc;

  ServiceAdministratif({
    required this.id,
    required this.nom,
    required this.responsable,
    required this.contact,
    required this.bloc,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'responsable': responsable,
      'contact': contact,
      'blocId': bloc.id,
    };
  }

  factory ServiceAdministratif.fromMap(Map<String, dynamic> map, BlocBatiment bloc) {
    return ServiceAdministratif(
      id: map['id'],
      nom: map['nom'],
      responsable: map['responsable'],
      contact: map['contact'],
      bloc: bloc,
    );
  }
}
