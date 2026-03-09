import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_models.dart';

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  VantageUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return VantageUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<VantageUser?> get authStateChanges =>
      _auth.authStateChanges().map(_mapFirebaseUser);

  @override
  Future<VantageUser?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _mapFirebaseUser(result.user);
  }

  @override
  Future<VantageUser?> signUpWithEmail(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return _mapFirebaseUser(result.user);
  }

  @override
  Future<VantageUser?> signInWithGoogle() async {
    // Implementación de Google Sign-In (requiere google_sign_in package)
    // Por ahora dejamos el stub
    throw UnimplementedError('Google Sign-In necesita configuración adicional');
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
