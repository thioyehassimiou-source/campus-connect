import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/communication.dart';
import '../models/user.dart';
import '../models/academique.dart';
import '../models/enums.dart';

class CommunicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Annonce
  Future<void> createAnnonce(Annonce annonce) async {
    await _firestore.collection('annonces').doc(annonce.id).set(annonce.toMap());
  }

  Future<Annonce?> getAnnonce(String id) async {
    final doc = await _firestore.collection('annonces').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    final auteur = await getUtilisateur(data['auteurId']);
    if (auteur == null) return null;
    return Annonce.fromMap(data, auteur);
  }

  Future<List<Annonce>> getAllAnnonces() async {
    final snapshot = await _firestore.collection('annonces').orderBy('datePublication', descending: true).get();
    final results = <Annonce>[];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final auteur = await getUtilisateur(data['auteurId']);
      if (auteur != null) {
        results.add(Annonce.fromMap(data, auteur));
      }
    }
    return results;
  }

  Stream<List<Annonce>> streamAnnonces() {
    return _firestore
        .collection('annonces')
        .orderBy('datePublication', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final results = <Annonce>[];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final auteur = await getUtilisateur(data['auteurId']);
        if (auteur != null) {
          results.add(Annonce.fromMap(data, auteur));
        }
      }
      return results;
    });
  }

  // Document
  Future<void> createDocument(Document document) async {
    await _firestore.collection('documents').doc(document.id).set(document.toMap());
  }

  Future<Document?> getDocument(String id) async {
    final doc = await _firestore.collection('documents').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    final enseignant = await getEnseignant(data['enseignantId']);
    final filiere = await getFiliere(data['filiereId']);
    if (enseignant == null || filiere == null) return null;
    return Document.fromMap(data, enseignant, filiere);
  }

  Future<List<Document>> getDocumentsByFiliere(String filiereId) async {
    final snapshot = await _firestore
        .collection('documents')
        .where('filiereId', isEqualTo: filiereId)
        .get();
    final results = <Document>[];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final enseignant = await getEnseignant(data['enseignantId']);
      final filiere = await getFiliere(data['filiereId']);
      if (enseignant != null && filiere != null) {
        results.add(Document.fromMap(data, enseignant, filiere));
      }
    }
    return results;
  }

  Future<List<Document>> getDocumentsByEnseignant(String enseignantId) async {
    final snapshot = await _firestore
        .collection('documents')
        .where('enseignantId', isEqualTo: enseignantId)
        .get();
    final results = <Document>[];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final enseignant = await getEnseignant(data['enseignantId']);
      final filiere = await getFiliere(data['filiereId']);
      if (enseignant != null && filiere != null) {
        results.add(Document.fromMap(data, enseignant, filiere));
      }
    }
    return results;
  }

  // Helpers
  Future<Utilisateur?> getUtilisateur(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    final role = Role.values.firstWhere((r) => r.name == data['role']);
    return Utilisateur.fromMap(data, role);
  }

  Future<Enseignant?> getEnseignant(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return Enseignant.fromMap(data);
  }

  Future<Filiere?> getFiliere(String id) async {
    final doc = await _firestore.collection('filieres').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    final departement = await getDepartement(data['departementId']);
    if (departement == null) return null;
    return Filiere.fromMap(data, departement);
  }

  Future<Departement?> getDepartement(String id) async {
    final doc = await _firestore.collection('departements').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    final faculte = await getFaculte(data['faculteId']);
    if (faculte == null) return null;
    return Departement.fromMap(data, faculte);
  }

  Future<Faculte?> getFaculte(String id) async {
    final doc = await _firestore.collection('facultes').doc(id).get();
    if (!doc.exists) return null;
    return Faculte.fromMap(doc.data() as Map<String, dynamic>);
  }
}
