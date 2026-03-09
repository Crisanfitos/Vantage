import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/context_engine/data/environment_repository_impl.dart';
import '../../features/context_engine/domain/environment_repository_interface.dart';

final environmentRepositoryProvider = Provider<IEnvironmentRepository>((ref) {
  return FirestoreEnvironmentRepository();
});
