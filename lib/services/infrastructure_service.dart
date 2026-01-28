import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/infrastructure.dart';
import '../models/communication.dart';

class InfrastructureService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Bloc Batiment
  Future<void> createBlocBatiment(BlocBatiment bloc) async {
    await _firestore.collection('blocs').doc(bloc.id).set(bloc.toMap());
  }

  Future<BlocBatiment?> getBlocBatiment(String id) async {
    final doc = await _firestore.collection('blocs').doc(id).get();
    if (!doc.exists) return null;
    return BlocBatiment.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<List<BlocBatiment>> getAllBlocsBatiments() async {
    final snapshot = await _firestore.collection('blocs').get();
    return snapshot.docs
        .map((doc) => BlocBatiment.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Salle
  Future<void> createSalle(Salle salle) async {
    await _firestore.collection('salles').doc(salle.id).set(salle.toMap());
  }

  Future<Salle?> getSalle(String id) async {
    final doc = await _firestore.collection('salles').doc(id).get();
    if (!doc.exists) return null;
    return Salle.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<List<Salle>> getSallesByBloc(String blocId) async {
    // Note: This assumes you store blocId in salle documents, adjust if needed
    final snapshot = await _firestore.collection('salles').get();
    return snapshot.docs
        .map((doc) => Salle.fromMap(doc.data() as Map<String, dynamic>))
        .where((salle) => salle.id.startsWith(blocId)) // Exemple simple
        .toList();
  }

  // Service Administratif
  Future<void> createServiceAdministratif(ServiceAdministratif service) async {
    await _firestore.collection('services').doc(service.id).set(service.toMap());
  }

  Future<ServiceAdministratif?> getServiceAdministratif(String id) async {
    final doc = await _firestore.collection('services').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    final blocBatiment = await getBlocBatiment(data['blocId']);
    if (blocBatiment == null) return null;
    return ServiceAdministratif.fromMap(data, blocBatiment);
  }

  Future<List<ServiceAdministratif>> getServicesByBloc(String blocId) async {
    final snapshot = await _firestore
        .collection('services')
        .where('blocId', isEqualTo: blocId)
        .get();
    final blocBatiment = await getBlocBatiment(blocId);
    if (blocBatiment == null) return [];
    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ServiceAdministratif.fromMap(data, blocBatiment);
        })
        .toList();
  }
}
