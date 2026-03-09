import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/providers.dart';
import '../domain/environment.dart';
import 'environments_provider.dart';

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
                ? const Center(child: Text('Pulsa + para añadir tu ubicación actual'))
                : ListView.builder(
                    itemCount: environments.length,
                    itemBuilder: (context, index) {
                      final env = environments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getThemeColor(env.themeType),
                          child: Icon(_getIconData(env.iconName), color: Colors.white),
                        ),
                        title: Text(env.name),
                        subtitle: Text('Radio: ${env.radiusInMeters.toInt()}m'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => ref.read(environmentsProvider.notifier).removeEnvironment(env.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEnvironmentDialog(context, ref, locationService),
        label: const Text('Añadir Aquí'),
        icon: const Icon(Icons.add_location_alt),
      ),
    );
  }

  void _showAddEnvironmentDialog(BuildContext context, WidgetRef ref, locationService) async {
    final pos = await locationService.getCurrentLocation();
    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: GPS no disponible')));
      return;
    }

    final nameController = TextEditingController();
    VantageThemeType selectedTheme = VantageThemeType.midnight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Entorno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre (Ej: Casa, Trabajo)'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<VantageThemeType>(
              value: selectedTheme,
              decoration: const InputDecoration(labelText: 'Tema Visual'),
              items: VantageThemeType.values.map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.name.toUpperCase()),
              )).toList(),
              onChanged: (v) => selectedTheme = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newEnv = VantageEnvironment(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  latitude: pos.latitude,
                  longitude: pos.longitude,
                  radiusInMeters: 100, // Valor por defecto
                  themeType: selectedTheme,
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

  Color _getThemeColor(VantageThemeType type) {
    switch (type) {
      case VantageThemeType.midnight: return Colors.indigo;
      case VantageThemeType.neon: return Colors.pinkAccent;
      case VantageThemeType.forest: return Colors.green;
      case VantageThemeType.sunset: return Colors.orange;
      case VantageThemeType.ocean: return Colors.blue;
    }
  }

  IconData _getIconData(String name) {
    return Icons.location_on; // Simplificado para el MVP
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
