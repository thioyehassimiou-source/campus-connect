import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/academique.dart';
import '../models/user.dart';
import '../models/infrastructure.dart';

class AcademiqueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Faculté
  Future<void> createFaculte(Faculte faculte) async {
    await _firestore.collection('facultes').doc(faculte.id).set(faculte.toMap());
  }

  Future<Faculte?> getFaculte(String id) async {
    final doc = await _firestore.collection('facultes').doc(id).get();
    if (!doc.exists) return null;
    return Faculte.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<List<Faculte>> getAllFacultes() async {
    final snapshot = await _firestore.collection('facultes').get();
    return snapshot.docs
        .map((doc) => Faculte.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Département
  Future<void> createDepartement(Departement departement) async {
    await _firestore.collection('departements').doc(departement.id).set(departement.toMap());
  }

  Future<Departement?> getDepartement(String id) async {
    final doc = await _firestore.collection('departements').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    final faculte = await getFaculte(data['faculteId']);
    if (faculte == null) return null;
    return Departement.fromMap(data, faculte);
  }

  Future<List<Departement>> getDepartementsByFaculte(String faculteId) async {
    final snapshot = await _firestore
        .collection('departements')
        .where('faculteId', isEqualTo: faculteId)
        .get();
    final faculte = await getFaculte(faculteId);
    if (faculte == null) return [];
    return snapshot.docs
        .map((doc) => Departement.fromMap(doc.data() as Map<String, dynamic>, faculte))
        .toList();
  }

  // Filière
  Future<void> createFiliere(Filiere filiere) async {
    await _firestore.collection('filieres').doc(filiere.id).set(filiere.toMap());
  }

  Future<Filiere?> getFiliere(String id) async {
    final doc = await _firestore.collection('filieres').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    final departement = await getDepartement(data['departementId']);
    if (departement == null) return null;
    return Filiere.fromMap(data, departement);
  }

  Future<List<Filiere>> getFilieresByDepartement(String departementId) async {
    final snapshot = await _firestore
        .collection('filieres')
        .where('departementId', isEqualTo: departementId)
        .get();
    final departement = await getDepartement(departementId);
    if (departement == null) return [];
    return snapshot.docs
        .map((doc) => Filiere.fromMap(doc.data() as Map<String, dynamic>, departement))
        .toList();
  }

  // Emploi du temps
  Future<void> createEmploiDuTemps(EmploiDuTemps emploi) async {
    await _firestore.collection('emploisDuTemps').doc(emploi.id).set(emploi.toMap());
  }

  Future<List<EmploiDuTemps>> getEmploisDuTempsByFiliere(String filiereId) async {
    final snapshot = await _firestore
        .collection('emploisDuTemps')
        .where('filiereId', isEqualTo: filiereId)
        .get();
    final results = <EmploiDuTemps>[];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final filiere = await getFiliere(data['filiereId']);
      final salle = await getSalle(data['salleId']);
      final enseignant = await getEnseignant(data['enseignantId']);
      if (filiere != null && salle != null && enseignant != null) {
        results.add(EmploiDuTemps.fromMap(data, filiere, salle, enseignant));
      }
    }
    return results;
  }

  // Notes
  Future<void> createNote(Note note) async {
    await _firestore.collection('notes').doc(note.id).set(note.toMap());
  }

  Future<List<Note>> getNotesByEtudiant(String etudiantId) async {
    final snapshot = await _firestore
        .collection('notes')
        .where('etudiantId', isEqualTo: etudiantId)
        .get();
    final results = <Note>[];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final etudiant = await getEtudiant(etudiantId);
      if (etudiant != null) {
        results.add(Note.fromMap(data, etudiant));
      }
    }
    return results;
  }

  Future<Salle?> getSalle(String id) async {
    final doc = await _firestore.collection('salles').doc(id).get();
    if (!doc.exists) return null;
    return Salle.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<Etudiant?> getEtudiant(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return Etudiant.fromMap(data);
  }

  Future<Enseignant?> getEnseignant(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return Enseignant.fromMap(data);
  }
}
