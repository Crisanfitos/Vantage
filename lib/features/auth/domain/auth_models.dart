class VantageUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  VantageUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}

abstract class IAuthService {
  Stream<VantageUser?> get authStateChanges;
  Future<VantageUser?> signInWithEmail(String email, String password);
  Future<VantageUser?> signUpWithEmail(String email, String password);
  Future<VantageUser?> signInWithGoogle();
  Future<void> signOut();
}
