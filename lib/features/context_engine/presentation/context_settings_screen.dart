import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/providers.dart';
import 'environments_provider.dart';

class ContextSettingsScreen extends ConsumerWidget {
  const ContextSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environments = ref.watch(environmentsProvider);
    final locationService = ref.watch(locationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Entornos'),
      ),
      body: Column(
        children: [
          _buildCurrentLocationStatus(locationService),
          const Divider(),
          Expanded(
            child: environments.isEmpty
                ? const Center(child: Text('No hay entornos configurados'))
                : ListView.builder(
                    itemCount: environments.length,
                    itemBuilder: (context, index) {
                      final env = environments[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(env.name),
                        subtitle: Text('${env.latitude.toStringAsFixed(4)}, ${env.longitude.toStringAsFixed(4)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => ref.read(environmentsProvider.notifier).removeEnvironment(env.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final pos = await locationService.getCurrentLocation();
          if (pos != null) {
            // Aquí añadiremos un diálogo para poner nombre y elegir tema
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ubicación capturada: ${pos.latitude}, ${pos.longitude}')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo obtener la ubicación')),
            );
          }
        },
        label: const Text('Guardar Punto Actual'),
        icon: const Icon(Icons.add_location_alt),
      ),
    );
  }

  Widget _buildCurrentLocationStatus(locationService) {
    return FutureBuilder(
      future: locationService.checkPermission(),
      builder: (context, snapshot) {
        return ListTile(
          leading: const Icon(Icons.gps_fixed),
          title: const Text('Estado del GPS'),
          subtitle: Text(snapshot.hasData ? 'Permiso: ${snapshot.data}' : 'Comprobando...'),
        );
      },
    );
  }
}
