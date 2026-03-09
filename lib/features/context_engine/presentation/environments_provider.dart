import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/environment.dart';

class EnvironmentsNotifier extends Notifier<List<VantageEnvironment>> {
  @override
  List<VantageEnvironment> build() {
    return []; // Estado inicial
  }

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

final environmentsProvider = NotifierProvider<EnvironmentsNotifier, List<VantageEnvironment>>(
  EnvironmentsNotifier.new,
);
