import '../models/enums.dart';
import '../models/infrastructure.dart';
import '../models/academique.dart';
import '../models/communication.dart';
import '../models/user.dart';
import '../services/infrastructure_service.dart';
import '../services/academique_service.dart';
import '../services/communication_service.dart';
import '../services/user_service.dart';

class InitData {
  static Future<void> initializeSampleData({
    required InfrastructureService infrastructureService,
    required AcademiqueService academiqueService,
    required CommunicationService communicationService,
    required UserService userService,
  }) async {
    // 1. Créer les blocs (organisation interne Université de Labé)
    final blocA = Bloc(
      id: 'bloc-a',
      nom: 'Bloc A - Administration centrale',
      zone: Zone.admin,
    );
    final blocB = Bloc(
      id: 'bloc-b',
      nom: 'Bloc B - Salles de cours et amphithéâtres',
      zone: Zone.a,
    );
    final blocC = Bloc(
      id: 'bloc-c',
      nom: 'Bloc C - Départements académiques',
      zone: Zone.b,
    );
    final blocD = Bloc(
      id: 'bloc-d',
      nom: 'Bloc D - Services universitaires',
      zone: Zone.c,
    );

    await infrastructureService.createBloc(blocA);
    await infrastructureService.createBloc(blocB);
    await infrastructureService.createBloc(blocC);
    await infrastructureService.createBloc(blocD);

    // 2. Créer les salles
    final salles = [
      Salle(id: 'amphi-1', nom: 'Amphithéâtre 1', capacite: 300, type: TypeSalle.amphitheatre),
      Salle(id: 'amphi-2', nom: 'Amphithéâtre 2', capacite: 250, type: TypeSalle.amphitheatre),
      Salle(id: 'td-1', nom: 'Salle TD 1', capacite: 40, type: TypeSalle.td),
      Salle(id: 'td-2', nom: 'Salle TD 2', capacite: 40, type: TypeSalle.td),
      Salle(id: 'info-1', nom: 'Salle Informatique 1', capacite: 30, type: TypeSalle.laboratoire),
      Salle(id: 'info-2', nom: 'Salle Informatique 2', capacite: 30, type: TypeSalle.laboratoire),
    ];

    for (final salle in salles) {
      await infrastructureService.createSalle(salle);
    }

    // 3. Créer les facultés
    final facultéSciences = Faculte(
      id: 'fac-sciences',
      nom: 'Faculté des Sciences',
      doyen: 'Dr. Oumar Diallo',
    );
    final facultéLettres = Faculte(
      id: 'fac-lettres',
      nom: 'Faculté des Lettres et Sciences Humaines',
      doyen: 'Pr. Aminata Konaté',
    );

    await academiqueService.createFaculte(facultéSciences);
    await academiqueService.createFaculte(facultéLettres);

    // 4. Créer les départements
    final deptInfo = Departement(
      id: 'dept-info',
      nom: 'Département Informatique',
      chefDepartement: 'Dr. Mohamed Camara',
      faculte: facultéSciences,
    );
    final deptMaths = Departement(
      id: 'dept-maths',
      nom: 'Département Mathématiques',
      chefDepartement: 'Dr. Fatoumata Bâ',
      faculte: facultéSciences,
    );
    final deptLettres = Departement(
      id: 'dept-lettres',
      nom: 'Département Lettres',
      chefDepartement: 'Dr. Sékou Touré',
      faculte: facultéLettres,
    );

    await academiqueService.createDepartement(deptInfo);
    await academiqueService.createDepartement(deptMaths);
    await academiqueService.createDepartement(deptLettres);

    // 5. Créer les filières
    final filiereInfo = Filiere(
      id: 'fil-info',
      nom: 'Licence Informatique',
      departement: deptInfo,
    );
    final filiereMaths = Filiere(
      id: 'fil-maths',
      nom: 'Licence Mathématiques',
      departement: deptMaths,
    );
    final filiereLettres = Filiere(
      id: 'fil-lettres',
      nom: 'Licence Lettres Modernes',
      departement: deptLettres,
    );

    await academiqueService.createFiliere(filiereInfo);
    await academiqueService.createFiliere(filiereMaths);
    await academiqueService.createFiliere(filiereLettres);

    // 6. Créer les services universitaires
    final services = [
      ServiceAdministratif(
        id: 'serv-scolarite',
        nom: 'Service de Scolarité',
        responsable: 'M. Bakary Sidibé',
        contact: '+224 620 123 456',
        bloc: blocD,
      ),
      ServiceAdministratif(
        id: 'serv-examens',
        nom: 'Service des Examens',
        responsable: 'Mme. Aïssatou Baldé',
        contact: '+224 620 123 457',
        bloc: blocD,
      ),
      ServiceAdministratif(
        id: 'serv-biblio',
        nom: 'Bibliothèque Universitaire',
        responsable: 'M. Mamadou Bah',
        contact: '+224 620 123 458',
        bloc: blocD,
      ),
      ServiceAdministratif(
        id: 'serv-info',
        nom: 'Services Informatiques',
        responsable: 'M. Ousmane Diallo',
        contact: '+224 620 123 459',
        bloc: blocD,
      ),
      ServiceAdministratif(
        id: 'serv-finance',
        nom: 'Administration Financière',
        responsable: 'Mme. Mariam Touré',
        contact: '+224 620 123 460',
        bloc: blocA,
      ),
    ];

    for (final service in services) {
      await infrastructureService.createServiceAdministratif(service);
    }

    // 7. Créer des utilisateurs de test
    final admin = Administrateur(
      id: 'admin-1',
      nom: 'Admin Système',
      email: 'admin@campusconnect.com',
      motDePasse: 'admin123',
      telephone: '+224 620 000 001',
    );

    final enseignant = Enseignant(
      id: 'ens-1',
      nom: 'Dr. Ibrahim Konaté',
      email: 'i.konate@campusconnect.com',
      motDePasse: 'enseignant123',
      telephone: '+224 620 000 002',
      departement: deptInfo.id,
      grade: 'Maître de Conférences',
    );

    final etudiant = Etudiant(
      id: 'etu-1',
      nom: 'Mariam Camara',
      email: 'm.camara@campusconnect.com',
      motDePasse: 'etudiant123',
      telephone: '+224 620 000 003',
      matricule: '2024001',
      niveau: 'L2',
      filiere: filiereInfo.id,
    );

    await userService.createUtilisateur(admin);
    await userService.createUtilisateur(enseignant);
    await userService.createUtilisateur(etudiant);

    // 8. Créer des annonces de test
    final annonce1 = Annonce(
      id: 'annonce-1',
      titre: 'Réouverture des inscriptions',
      contenu: 'Les inscriptions pour le semestre 2 sont ouvertes jusqu\'au 31 janvier. Venez vous inscrire au service de scolarité.',
      datePublication: DateTime.now().subtract(const Duration(days: 2)),
      auteur: admin,
    );

    final annonce2 = Annonce(
      id: 'annonce-2',
      titre: 'Examen de Programmation Mobile',
      contenu: 'L\'examen de Programmation Mobile aura lieu le 15 février à 9h en amphi 1.',
      datePublication: DateTime.now().subtract(const Duration(days: 1)),
      auteur: enseignant,
    );

    await communicationService.createAnnonce(annonce1);
    await communicationService.createAnnonce(annonce2);

    // 9. Créer des notes de test
    final note1 = Note(
      id: 'note-1',
      valeur: 15.5,
      session: 'Semestre 1',
      matiere: 'Programmation Mobile',
      etudiant: etudiant,
    );

    final note2 = Note(
      id: 'note-2',
      valeur: 12.0,
      session: 'Semestre 1',
      matiere: 'Base de Données',
      etudiant: etudiant,
    );

    await academiqueService.createNote(note1);
    await academiqueService.createNote(note2);

    print('✅ Données de test initialisées avec succès');
  }
}
