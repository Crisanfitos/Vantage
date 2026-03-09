import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/environment.dart';
import '../domain/environment_repository_interface.dart';
import 'environment_model.dart';

class FirestoreEnvironmentRepository implements IEnvironmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveEnvironment(String userId, VantageEnvironment environment) async {
    final model = EnvironmentModel.fromEntity(environment);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('environments')
        .doc(model.id)
        .set(model.toJson());
  }

  @override
  Future<void> deleteEnvironment(String userId, String environmentId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('environments')
        .doc(environmentId)
        .delete();
  }

  @override
  Stream<List<VantageEnvironment>> watchEnvironments(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('environments')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EnvironmentModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }
}
