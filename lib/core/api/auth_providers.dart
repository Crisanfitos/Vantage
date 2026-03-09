import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/auth_service_impl.dart';
import '../../features/auth/domain/auth_models.dart';

final authServiceProvider = Provider<IAuthService>((ref) {
  return FirebaseAuthService();
});

/// Escucha cambios en la sesión de Firebase Auth (Login/Logout)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Escucha los datos del perfil en Firestore en TIEMPO REAL
final userProfileProvider = StreamProvider<VantageUser?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);
  
  return ref.watch(authServiceProvider).watchUserProfile(authUser.uid);
});
