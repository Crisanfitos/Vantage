import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/environment.dart';

class EnvironmentNotifier extends StateNotifier<List<VantageEnvironment>> {
  EnvironmentNotifier() : super([]);

  void addEnvironment(VantageEnvironment environment) {
    state = [...state, environment];
  }

  void removeEnvironment(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  void updateEnvironment(VantageEnvironment environment) {
    state = [
      for (final e in state)
        if (e.id == environment.id) environment else e
    ];
  }
}

final environmentsProvider = StateNotifierProvider<EnvironmentNotifier, List<VantageEnvironment>>((ref) {
  return EnvironmentNotifier();
});
