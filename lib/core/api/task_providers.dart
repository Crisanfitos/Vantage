import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/tasks/data/task_repository_impl.dart';
import '../../features/tasks/domain/task_models.dart';
import 'auth_providers.dart';

final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  return FirestoreTaskRepository();
});

/// Provee todas las tareas del usuario en tiempo real
final allTasksProvider = StreamProvider<List<VantageTask>>((ref) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(taskRepositoryProvider).watchTasks(user.id);
});

/// Provee las tareas filtradas por un entorno específico (o nulo para "Calle")
final filteredTasksProvider = Provider.family<List<VantageTask>, String?>((ref, envId) {
  final tasks = ref.watch(allTasksProvider).value ?? [];
  return tasks.where((t) => t.environmentId == envId).toList();
});
