import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../domain/auth_models.dart';

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VantageUser _mapDocumentToUser(String uid, String email, Map<String, dynamic> data) {
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
      actionModeId: data['actionModeId'] ?? 'suggested',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      dashboardStyle: DashboardStyle.values.firstWhere(
        (e) => e.name == data['dashboardStyle'],
        orElse: () => DashboardStyle.cards,
      ),
    );
  }

  Future<VantageUser?> _getUserFromFirestore(String uid, String email) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return VantageUser(id: uid, email: email);
    return _mapDocumentToUser(uid, email, doc.data()!);
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

    // 1. Inicializar documento raíz del usuario
    final userData = {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate) : null,
      'jobTitle': jobTitle,
      'createdAt': FieldValue.serverTimestamp(),
      'dashboardStyle': 'cards',
      'actionModeId': 'suggested',
      'notificationsEnabled': true,
      'salaryAmount': 0.0,
      'salaryDay': 25,
      'monthlySavingsGoal': 0.0,
    };
    await _firestore.collection('users').doc(uid).set(userData);

    // 2. Crear entornos por defecto
    final defaultEnvs = [
      {
        'id': 'home_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Casa',
        'iconName': 'home',
        'latitude': 0.0,
        'longitude': 0.0,
        'radius': 20.0,
        'colorSeedValue': 0xFF4CAF50,
        'preferredDashboardStyle': 'cards',
        'visibleModules': ['finance', 'tasks', 'media', 'notes'],
      },
      {
        'id': 'work_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Trabajo',
        'iconName': 'business_center',
        'latitude': 0.0,
        'longitude': 0.0,
        'radius': 20.0,
        'colorSeedValue': 0xFF2196F3,
        'preferredDashboardStyle': 'grid',
        'visibleModules': ['tasks', 'github', 'notes'],
      },
    ];

    for (var env in defaultEnvs) {
      await _firestore.collection('users').doc(uid).collection('environments').doc(env['id'] as String).set(env);
    }

    // 3. Inicializar sub-colecciones con un documento "Seed" o simplemente dejarlas listas
    // En Firestore las colecciones no existen físicamente hasta que tienen un documento.
    // Si el email es el de prueba, inyectaremos datos reales.
    if (email == 'test@vantage.app') {
      await _injectTestData(uid);
    }

    return await _getUserFromFirestore(uid, email);
  }

  Future<void> _injectTestData(String uid) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(uid);

    // Tarea de ejemplo
    final taskRef = userRef.collection('tasks').doc('test_task_1');
    batch.set(taskRef, {
      'title': 'Configurar mi primera ubicación',
      'description': 'Usa la varita mágica para guardar tu posición actual',
      'isCompleted': false,
      'priority': 'high',
      'environmentId': null,
      'createdAt': Timestamp.now(),
    });

    // Registro financiero de ejemplo
    final financeRef = userRef.collection('finance_records').doc('test_finance_1');
    batch.set(financeRef, {
      'title': 'Compra de Bienvenida',
      'amount': 5.50,
      'date': Timestamp.now(),
      'type': 'expense',
      'category': 'Otros',
      'isRecurring': false,
    });

    // Nota de ejemplo
    final noteRef = userRef.collection('notes').doc('test_note_1');
    batch.set(noteRef, {
      'content': 'Recuerda que Vantage se adapta a ti. ¡Prueba a cambiar de modo!',
      'environmentId': null,
      'createdAt': Timestamp.now(),
    });

    // Evento Timeline
    final eventRef = userRef.collection('timeline_events').doc('test_event_1');
    batch.set(eventRef, {
      'title': 'Explorar Vantage',
      'startHour': DateTime.now().hour,
      'startMinute': DateTime.now().minute,
      'isRecurring': false,
    });

    await batch.commit();
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
      final uid = user.uid;
      final subCollections = ['environments', 'finance_records', 'recurring_templates', 'tasks', 'notes', 'timeline_events'];
      for (final coll in subCollections) {
        final docs = await _firestore.collection('users').doc(uid).collection(coll).get();
        for (final doc in docs.docs) {
          await doc.reference.delete();
        }
      }
      await _firestore.collection('users').doc(uid).delete();
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
      return _mapDocumentToUser(uid, _auth.currentUser?.email ?? '', doc.data()!);
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
