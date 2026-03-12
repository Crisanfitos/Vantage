import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/auth_providers.dart';
import '../domain/environment.dart';

/// Proveedor para controlar la visibilidad del banner global
final activeBannerProvider = StateProvider<VantageEnvironment?>((ref) => null);

/// Proveedor para el entorno seleccionado actualmente por el usuario (Manualmente o Auto)
final currentActiveEnvironmentProvider = StateProvider<VantageEnvironment?>((ref) => null);

class ContextBannerOverlay extends ConsumerWidget {
  final Widget child;
  const ContextBannerOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedEnv = ref.watch(activeBannerProvider);
    final user = ref.watch(userProfileProvider).value;

    return Stack(
      children: [
        child,
        if (suggestedEnv != null && user != null && user.actionModeId != 'automatic')
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.deepPurpleAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('¿Estás en ${suggestedEnv.name}?', 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const Text('Toca para adaptar Vantage', 
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(currentActiveEnvironmentProvider.notifier).state = suggestedEnv;
                        ref.read(activeBannerProvider.notifier).state = null;
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.cyanAccent),
                      child: const Text('CAMBIAR'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                      onPressed: () => ref.read(activeBannerProvider.notifier).state = null,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
