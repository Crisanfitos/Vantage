import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/api/providers.dart';
import '../domain/environment.dart';
import 'environments_provider.dart';

class EnvironmentDetailScreen extends ConsumerStatefulWidget {
  final VantageEnvironment environment;
  const EnvironmentDetailScreen({super.key, required this.environment});

  @override
  ConsumerState<EnvironmentDetailScreen> createState() => _EnvironmentDetailScreenState();
}

class _EnvironmentDetailScreenState extends ConsumerState<EnvironmentDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late double _radius;
  late List<String> _visibleModules;
  bool _isManualMode = false;
  bool _isGettingLocation = false;

  final Map<String, String> _moduleNames = {
    'finance': 'Finanzas',
    'tasks': 'Tareas',
    'github': 'DevHub (GitHub)',
    'media': 'Media Hub',
    'notes': 'Notas Contextuales',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.environment.name);
    _latController = TextEditingController(
      text: widget.environment.latitude != 0 ? widget.environment.latitude.toString() : ''
    );
    _lngController = TextEditingController(
      text: widget.environment.longitude != 0 ? widget.environment.longitude.toString() : ''
    );
    _radius = widget.environment.radiusInMeters;
    _visibleModules = List.from(widget.environment.visibleModules);
  }

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);
    final locationService = ref.read(locationServiceProvider);
    try {
      final pos = await locationService.getCurrentLocation();
      if (pos != null) {
        setState(() {
          _latController.text = pos.latitude.toString();
          _lngController.text = pos.longitude.toString();
          _isManualMode = true; 
        });
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _save() async {
    final lat = double.tryParse(_latController.text) ?? 0.0;
    final lng = double.tryParse(_lngController.text) ?? 0.0;

    final updated = widget.environment.copyWith(
      name: _nameController.text,
      radiusInMeters: _radius,
      latitude: lat,
      longitude: lng,
      visibleModules: _visibleModules,
    );
    
    await ref.read(environmentsProvider.notifier).addEnvironment(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = (double.tryParse(_latController.text) ?? 0) != 0;

    return Scaffold(
      appBar: AppBar(title: Text('Editar ${widget.environment.name}')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 32),
          _buildStatusHeader(hasLocation),
          const SizedBox(height: 24),
          
          if (!_isManualMode && !hasLocation)
            ElevatedButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: _isGettingLocation 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
              label: Text(_isGettingLocation ? 'CALCULANDO...' : 'OBTENER UBICACIÓN ACTUAL'),
            )
          else ...[
            Row(
              children: [
                Expanded(child: TextField(controller: _latController, decoration: const InputDecoration(labelText: 'Latitud', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _lngController, decoration: const InputDecoration(labelText: 'Longitud', border: OutlineInputBorder()))),
              ],
            ),
          ],

          const SizedBox(height: 32),
          const Text('Módulos Visibles en este Entorno', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text('Marca qué quieres ver cuando estés aquí.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          ..._moduleNames.entries.map((entry) => CheckboxListTile(
            title: Text(entry.value),
            value: _visibleModules.contains(entry.key),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _visibleModules.add(entry.key);
                } else {
                  _visibleModules.remove(entry.key);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          )),

          const SizedBox(height: 32),
          Text('Radio de detección: ${_radius.toInt()}m', style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _radius, min: 10, max: 100, divisions: 9,
            onChanged: (v) => setState(() => _radius = v),
          ),
          
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
            child: const Text('GUARDAR CONFIGURACIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(bool hasLocation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(hasLocation ? Icons.location_on : Icons.location_off, color: hasLocation ? Colors.greenAccent : Colors.redAccent),
        const SizedBox(width: 8),
        Text(hasLocation ? 'LISTO' : 'PENDIENTE', style: TextStyle(fontWeight: FontWeight.bold, color: hasLocation ? Colors.greenAccent : Colors.redAccent)),
      ],
    );
  }
}
