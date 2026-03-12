import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/api/auth_providers.dart';
import '../../../core/api/providers.dart';
import '../domain/environment.dart';
import 'environments_provider.dart';
import 'context_banner_overlay.dart';

/// Notificador que vigila la ubicación y gestiona el entorno activo
class ContextWatcherNotifier extends AutoDisposeNotifier<void> {
  Timer? _timer;

  @override
  void build() {
    // Iniciar vigilancia cada minuto cuando la app está abierta
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkContext();
    });

    ref.onDispose(() => _timer?.cancel());
    
    // Ejecutar una primera comprobación al iniciar
    Future.delayed(Duration.zero, _checkContext);
  }

  Future<void> _checkContext() async {
    final user = ref.read(userProfileProvider).value;
    final environments = ref.read(environmentsProvider);
    final locationService = ref.read(locationServiceProvider);

    if (user == null || environments.isEmpty) return;

    final Position? currentPos = await locationService.getCurrentLocation();
    if (currentPos == null) return;

    VantageEnvironment? detectedEnv;

    // Lógica Sistemática de Geofencing
    for (final env in environments) {
      if (env.latitude == 0 || env.longitude == 0) continue;

      // Calcular distancia en metros entre posición actual y el centro del entorno
      final double distance = Geolocator.distanceBetween(
        currentPos.latitude,
        currentPos.longitude,
        env.latitude,
        env.longitude,
      );

      // Si la distancia es menor o igual al radio, hemos detectado el entorno
      if (distance <= env.radiusInMeters) {
        detectedEnv = env;
        break; // Priorizamos el primero encontrado (normalmente solo habrá uno solapado)
      }
    }

    // Si no hay nada detectado y tenemos un entorno llamado 'Casa', lo ponemos como base
    if (detectedEnv == null) {
      try {
        detectedEnv = environments.firstWhere((e) => e.name.toLowerCase() == 'casa');
      } catch (_) {
        // Si no hay 'Casa', se queda en null (Modo Calle)
      }
    }

    final currentActive = ref.read(currentActiveEnvironmentProvider);

    // Si el entorno detectado es diferente al actual, actuamos según el Modo de Actuación
    if (detectedEnv?.id != currentActive?.id) {
      _handleContextChange(user.actionModeId, detectedEnv);
    }
  }

  void _handleContextChange(String modeId, VantageEnvironment? newEnv) {
    switch (modeId) {
      case 'automatic':
        // Cambio instantáneo sin preguntar
        ref.read(currentActiveEnvironmentProvider.notifier).state = newEnv;
        break;
      case 'suggested':
        // Mostrar el banner personalizado (Toast) para que el usuario elija
        if (newEnv != null) {
          ref.read(activeBannerProvider.notifier).state = newEnv;
        }
        break;
      case 'manual':
        // No hace nada, solo detecta (puedes añadir un log o indicador discreto)
        break;
    }
  }
}

/// Proveedor para activar el vigilante en cualquier parte de la app
final contextWatcherProvider = NotifierProvider.autoDispose<ContextWatcherNotifier, void>(
  ContextWatcherNotifier.new,
);
