import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/enums.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUtilisateur(Utilisateur utilisateur) async {
    await _firestore.collection('users').doc(utilisateur.id).set(utilisateur.toMap());
  }

  Future<Utilisateur?> getUtilisateur(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    final role = Role.values.firstWhere((r) => r.name == data['role']);
    return Utilisateur.fromMap(data, role);
  }

  Future<List<Utilisateur>> getAllUtilisateurs() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final role = Role.values.firstWhere((r) => r.name == data['role']);
      return Utilisateur.fromMap(data, role);
    }).toList();
  }

  Future<void> updateUtilisateur(Utilisateur utilisateur) async {
    await _firestore.collection('users').doc(utilisateur.id).update(utilisateur.toMap());
  }

  Future<void> deleteUtilisateur(String id) async {
    await _firestore.collection('users').doc(id).delete();
  }

  // Méthodes spécialisées
  Future<List<Etudiant>> getEtudiantsByFiliere(String filiereId) async {
    final snapshot = await _firestore.collection('users')
        .where('role', isEqualTo: Role.student.name)
        .where('filiere', isEqualTo: filiereId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Etudiant.fromMap(data);
    }).toList();
  }

  Future<List<Enseignant>> getEnseignantsByDepartement(String departementId) async {
    final snapshot = await _firestore.collection('users')
        .where('role', isEqualTo: Role.teacher.name)
        .where('departement', isEqualTo: departementId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Enseignant.fromMap(data);
    }).toList();
  }

  Stream<List<Utilisateur>> streamAllUtilisateurs() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final role = Role.values.firstWhere((r) => r.name == data['role']);
        return Utilisateur.fromMap(data, role);
      }).toList();
    });
  }
}
