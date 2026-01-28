import 'enums.dart';

abstract class Utilisateur {
  final String id;
  final String nom;
  final String email;
  final String motDePasse;
  final Role role;
  final String telephone;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.motDePasse,
    required this.role,
    required this.telephone,
  });

  Map<String, dynamic> toMap();

  factory Utilisateur.fromMap(Map<String, dynamic> map, Role role) {
    switch (role) {
      case Role.student:
        return Etudiant.fromMap(map);
      case Role.teacher:
        return Enseignant.fromMap(map);
      case Role.admin:
        return Administrateur.fromMap(map);
    }
  }

  void seConnecter() {}
  void seDeconnecter() {}
  void consulterAnnonces() {}
}

class Etudiant extends Utilisateur {
  final String matricule;
  final String niveau;
  final String filiere;

  Etudiant({
    required String id,
    required String nom,
    required String email,
    required String motDePasse,
    required String telephone,
    required this.matricule,
    required this.niveau,
    required this.filiere,
  }) : super(
          id: id,
          nom: nom,
          email: email,
          motDePasse: motDePasse,
          role: Role.student,
          telephone: telephone,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'motDePasse': motDePasse,
      'role': role.name,
      'telephone': telephone,
      'matricule': matricule,
      'niveau': niveau,
      'filiere': filiere,
    };
  }

  factory Etudiant.fromMap(Map<String, dynamic> map) {
    return Etudiant(
      id: map['id'],
      nom: map['nom'],
      email: map['email'],
      motDePasse: map['motDePasse'],
      telephone: map['telephone'],
      matricule: map['matricule'],
      niveau: map['niveau'],
      filiere: map['filiere'],
    );
  }

  void consulterNotes() {}
  void consulterEmploiTemps() {}
}

class Enseignant extends Utilisateur {
  final String departement;
  final String grade;

  Enseignant({
    required String id,
    required String nom,
    required String email,
    required String motDePasse,
    required String telephone,
    required this.departement,
    required this.grade,
  }) : super(
          id: id,
          nom: nom,
          email: email,
          motDePasse: motDePasse,
          role: Role.teacher,
          telephone: telephone,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'motDePasse': motDePasse,
      'role': role.name,
      'telephone': telephone,
      'departement': departement,
      'grade': grade,
    };
  }

  factory Enseignant.fromMap(Map<String, dynamic> map) {
    return Enseignant(
      id: map['id'],
      nom: map['nom'],
      email: map['email'],
      motDePasse: map['motDePasse'],
      telephone: map['telephone'],
      departement: map['departement'],
      grade: map['grade'],
    );
  }

  void publierDocument() {}
  void publierAnnonce() {}
}

class Administrateur extends Utilisateur {
  Administrateur({
    required String id,
    required String nom,
    required String email,
    required String motDePasse,
    required String telephone,
  }) : super(
          id: id,
          nom: nom,
          email: email,
          motDePasse: motDePasse,
          role: Role.admin,
          telephone: telephone,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'motDePasse': motDePasse,
      'role': role.name,
      'telephone': telephone,
    };
  }

  factory Administrateur.fromMap(Map<String, dynamic> map) {
    return Administrateur(
      id: map['id'],
      nom: map['nom'],
      email: map['email'],
      motDePasse: map['motDePasse'],
      telephone: map['telephone'],
    );
  }

  void gererUtilisateurs() {}
  void gererBlocs() {}
  void publierAnnonceOfficielle() {}
}
