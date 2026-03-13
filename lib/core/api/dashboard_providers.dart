import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/data/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/dashboard_models.dart';
import '../../features/context_engine/presentation/context_banner_overlay.dart';
import 'auth_providers.dart';

final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) {
  return FirestoreDashboardRepository();
});

/// Todas las notas del usuario
final allNotesProvider = StreamProvider<List<VantageNote>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(dashboardRepositoryProvider).watchNotes(user.uid);
});

/// Notas filtradas por el entorno ACTIVO actual
final contextualNotesProvider = Provider<List<VantageNote>>((ref) {
  final notes = ref.watch(allNotesProvider).value ?? [];
  final activeEnv = ref.watch(currentActiveEnvironmentProvider);
  
  if (activeEnv == null) return notes; // Opcional: mostrar todas o solo generales
  return notes.where((n) => n.environmentId == activeEnv.id).toList();
});

/// Eventos del timeline
final timelineEventsProvider = StreamProvider<List<TimelineEvent>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(dashboardRepositoryProvider).watchEvents(user.uid);
});
