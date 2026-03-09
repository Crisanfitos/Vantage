import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/api/auth_providers.dart';
import '../../../core/api/repository_providers.dart';
import '../domain/environment.dart';

class EnvironmentsNotifier extends AutoDisposeNotifier<List<VantageEnvironment>> {
  StreamSubscription? _subscription;

  @override
  List<VantageEnvironment> build() {
    // Escuchar el estado de autenticación
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    if (user == null) return [];

    // Escuchar cambios en Firestore
    _subscription?.cancel();
    _subscription = ref
        .read(environmentRepositoryProvider)
        .watchEnvironments(user.id)
        .listen((envs) {
      state = envs;
    });

    ref.onDispose(() => _subscription?.cancel());

    return [];
  }

  Future<void> addEnvironment(VantageEnvironment environment) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(environmentRepositoryProvider).saveEnvironment(user.id, environment);
  }

  Future<void> removeEnvironment(String id) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(environmentRepositoryProvider).deleteEnvironment(user.id, id);
  }
}

final environmentsProvider = NotifierProvider.autoDispose<EnvironmentsNotifier, List<VantageEnvironment>>(
  EnvironmentsNotifier.new,
);
