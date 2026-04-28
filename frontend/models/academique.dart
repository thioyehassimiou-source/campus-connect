import 'package:flutter/material.dart';
import 'user.dart';
import 'infrastructure.dart';

class Faculte {
  final String id;
  final String nom;
  final String doyen;
  final List<Departement> departements;

  Faculte({
    required this.id,
    required this.nom,
    required this.doyen,
    this.departements = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'doyen': doyen,
    };
  }

  factory Faculte.fromMap(Map<String, dynamic> map) {
    return Faculte(
      id: map['id'],
      nom: map['nom'],
      doyen: map['doyen'],
    );
  }
}

class Departement {
  final String id;
  final String nom;
  final String chefDepartement;
  final Faculte faculte;
  final List<Filiere> filieres;

  Departement({
    required this.id,
    required this.nom,
    required this.chefDepartement,
    required this.faculte,
    this.filieres = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'chefDepartement': chefDepartement,
      'faculteId': faculte.id,
    };
  }

  factory Departement.fromMap(Map<String, dynamic> map, Faculte faculte) {
    return Departement(
      id: map['id'],
      nom: map['nom'],
      chefDepartement: map['chefDepartement'],
      faculte: faculte,
    );
  }
}

class Filiere {
  final String id;
  final String nom;
  final Departement departement;
  final List<Etudiant> etudiants;

  Filiere({
    required this.id,
    required this.nom,
    required this.departement,
    this.etudiants = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'departementId': departement.id,
    };
  }

  factory Filiere.fromMap(Map<String, dynamic> map, Departement departement) {
    return Filiere(
      id: map['id'],
      nom: map['nom'],
      departement: departement,
    );
  }
}

class EmploiDuTemps {
  final String id;
  final String jour;
  final TimeOfDay heureDebut;
  final TimeOfDay heureFin;
  final String matiere;
  final Filiere filiere;
  final Salle salle;
  final Enseignant enseignant;

  EmploiDuTemps({
    required this.id,
    required this.jour,
    required this.heureDebut,
    required this.heureFin,
    required this.matiere,
    required this.filiere,
    required this.salle,
    required this.enseignant,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jour': jour,
      'heureDebut': '${heureDebut.hour}:${heureDebut.minute}',
      'heureFin': '${heureFin.hour}:${heureFin.minute}',
      'matiere': matiere,
      'filiereId': filiere.id,
      'salleId': salle.id,
      'enseignantId': enseignant.id,
    };
  }

  factory EmploiDuTemps.fromMap(
    Map<String, dynamic> map,
    Filiere filiere,
    Salle salle,
    Enseignant enseignant,
  ) {
    final debutParts = (map['heureDebut'] as String).split(':');
    final finParts = (map['heureFin'] as String).split(':');

    return EmploiDuTemps(
      id: map['id'],
      jour: map['jour'],
      heureDebut: TimeOfDay(
        hour: int.parse(debutParts[0]),
        minute: int.parse(debutParts[1]),
      ),
      heureFin: TimeOfDay(
        hour: int.parse(finParts[0]),
        minute: int.parse(finParts[1]),
      ),
      matiere: map['matiere'],
      filiere: filiere,
      salle: salle,
      enseignant: enseignant,
    );
  }
}

class Note {
  final String id;
  final double valeur;
  final String session;
  final String matiere;
  final Etudiant etudiant;

  Note({
    required this.id,
    required this.valeur,
    required this.session,
    required this.matiere,
    required this.etudiant,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'valeur': valeur,
      'session': session,
      'matiere': matiere,
      'etudiantId': etudiant.id,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map, Etudiant etudiant) {
    return Note(
      id: map['id'],
      valeur: (map['valeur'] as num).toDouble(),
      session: map['session'],
      matiere: map['matiere'],
      etudiant: etudiant,
    );
  }
}
