import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/providers.dart';
import '../domain/environment.dart';
import 'environments_provider.dart';
import 'environment_detail_screen.dart';

class ContextSettingsScreen extends ConsumerWidget {
  const ContextSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environments = ref.watch(environmentsProvider);
    final locationService = ref.watch(locationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus Entornos'),
      ),
      body: Column(
        children: [
          _buildCurrentLocationStatus(locationService),
          const Divider(),
          Expanded(
            child: environments.isEmpty
                ? const Center(child: Text('Cargando entornos predefinidos...'))
                : ListView.builder(
                    itemCount: environments.length,
                    itemBuilder: (context, index) {
                      final env = environments[index];
                      final isConfigured = env.latitude != 0 && env.longitude != 0;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => EnvironmentDetailScreen(environment: env))
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isConfigured ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                            child: Icon(
                              _getIconData(env.iconName), 
                              color: isConfigured ? Colors.green : Colors.red
                            ),
                          ),
                          title: Text(env.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(isConfigured ? '🟢 Configurado' : '🔴 Sin ubicación'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEnvironmentDialog(context, ref, locationService),
        label: const Text('Añadir Nuevo'),
        icon: const Icon(Icons.add_location_alt),
      ),
    );
  }

  void _showAddEnvironmentDialog(BuildContext context, WidgetRef ref, locationService) async {
    final pos = await locationService.getCurrentLocation();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Entorno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre (Ej: Gimnasio, Universidad)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newEnv = VantageEnvironment(
                  id: 'custom_${const Uuid().v4()}',
                  name: nameController.text,
                  latitude: pos?.latitude ?? 0.0,
                  longitude: pos?.longitude ?? 0.0,
                  radiusInMeters: 100,
                  iconName: 'location_on',
                );
                ref.read(environmentsProvider.notifier).addEnvironment(newEnv);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    if (name == 'home') return Icons.home;
    if (name == 'business_center') return Icons.business_center;
    return Icons.location_on;
  }

  Widget _buildCurrentLocationStatus(locationService) {
    return FutureBuilder(
      future: locationService.checkPermission(),
      builder: (context, snapshot) {
        return ListTile(
          leading: const Icon(Icons.gps_fixed, color: Colors.cyanAccent),
          title: const Text('Estado del GPS'),
          subtitle: Text(snapshot.hasData ? 'Permiso concedido' : 'Comprobando...'),
        );
      },
    );
  }
}
