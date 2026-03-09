import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/auth_models.dart';

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<VantageUser?> _getUserFromFirestore(String uid, String email) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return VantageUser(id: uid, email: email);
    
    final data = doc.data()!;
    return VantageUser(
      id: uid,
      email: email,
      firstName: data['firstName'],
      lastName: data['lastName'],
      birthDate: data['birthDate'] != null ? (data['birthDate'] as Timestamp).toDate() : null,
      jobTitle: data['jobTitle'],
      photoUrl: data['photoUrl'],
      monthlySavingsGoal: (data['monthlySavingsGoal'] as num?)?.toDouble(),
      salaryAmount: (data['salaryAmount'] as num?)?.toDouble(),
      salaryDay: data['salaryDay'] as int?,
      dashboardStyle: DashboardStyle.values.firstWhere(
        (e) => e.name == data['dashboardStyle'],
        orElse: () => DashboardStyle.cards,
      ),
    );
  }

  @override
  Stream<VantageUser?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        return await _getUserFromFirestore(user.uid, user.email ?? '');
      });

  @override
  Future<VantageUser?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return await _getUserFromFirestore(result.user!.uid, email);
  }

  @override
  Future<VantageUser?> signUpWithEmail(String email, String password, {
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? jobTitle,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = result.user!.uid;

    final userData = {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate) : null,
      'jobTitle': jobTitle,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(uid).set(userData);
    return await _getUserFromFirestore(uid, email);
  }

  @override
  Future<VantageUser?> signInWithGoogle() async {
    throw UnimplementedError('Google Sign-In necesita configuración adicional');
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).delete();
      final envs = await _firestore.collection('users').doc(user.uid).collection('environments').get();
      for (var doc in envs.docs) {
        await doc.reference.delete();
      }
      await user.delete();
    }
  }

  @override
  Future<void> updateUserPreference(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  @override
  Stream<VantageUser?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return VantageUser(id: uid, email: _auth.currentUser?.email ?? '');
      final data = doc.data()!;
      return VantageUser(
        id: uid,
        email: _auth.currentUser?.email ?? '',
        firstName: data['firstName'],
        lastName: data['lastName'],
        birthDate: data['birthDate'] != null ? (data['birthDate'] as Timestamp).toDate() : null,
        jobTitle: data['jobTitle'],
        photoUrl: data['photoUrl'],
        monthlySavingsGoal: (data['monthlySavingsGoal'] as num?)?.toDouble(),
        dashboardStyle: DashboardStyle.values.firstWhere(
          (e) => e.name == data['dashboardStyle'],
          orElse: () => DashboardStyle.cards,
        ),
      );
    });
  }
}

abstract class IAuthService {
  Stream<VantageUser?> get authStateChanges;
  Future<VantageUser?> signInWithEmail(String email, String password);
  Future<VantageUser?> signUpWithEmail(String email, String password, {
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? jobTitle,
  });
  Future<VantageUser?> signInWithGoogle();
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<void> updateUserPreference(String uid, Map<String, dynamic> data);
  Stream<VantageUser?> watchUserProfile(String uid);
}
