import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_service_impl.dart';
import '../../features/auth/domain/auth_models.dart';

final authServiceProvider = Provider<IAuthService>((ref) {
  return FirebaseAuthService();
});

final authStateProvider = StreamProvider<VantageUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
