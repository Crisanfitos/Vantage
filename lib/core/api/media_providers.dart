import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/media/data/media_repository_impl.dart';
import '../../features/media/data/media_discovery_service.dart';
import '../../features/media/domain/media_models.dart';
import 'auth_providers.dart';

final mediaRepositoryProvider = Provider<IMediaRepository>((ref) {
  return FirestoreMediaRepository();
});

final mediaDiscoveryServiceProvider = Provider<MediaDiscoveryService>((ref) {
  return MediaDiscoveryService();
});

/// Búsqueda de medios (Anime, Manga, Libros...)
final mediaSearchProvider = FutureProvider.family<List<VantageMedia>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return ref.watch(mediaDiscoveryServiceProvider).searchMedia(query);
});

/// Mi lista personal de medios desde Firestore
final myMediaItemsProvider = StreamProvider<List<VantageMedia>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(mediaRepositoryProvider).watchMediaItems(user.uid);
});

/// Observador de un único elemento de media para el detalle
final mediaItemProvider = StreamProvider.family<VantageMedia?, String>((ref, mediaId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  
  return ref.watch(mediaRepositoryProvider).watchMediaItems(user.uid).map(
    (items) {
      final results = items.where((m) => m.id == mediaId);
      return results.isEmpty ? null : results.first;
    },
  );
});
