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
  bool _isManualMode = false;
  bool _isGettingLocation = false;

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ubicación capturada con éxito'))
          );
        }
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
            decoration: const InputDecoration(
              labelText: 'Nombre del Entorno', 
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit_location_alt),
            ),
          ),
          const SizedBox(height: 32),
          
          _buildStatusHeader(hasLocation),
          
          const SizedBox(height: 24),
          
          if (!_isManualMode && !hasLocation)
            ElevatedButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: _isGettingLocation 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
                : const Icon(Icons.my_location),
              label: Text(_isGettingLocation ? 'CALCULANDO...' : 'OBTENER UBICACIÓN ACTUAL'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.deepPurpleAccent.withOpacity(_isGettingLocation ? 0.4 : 1.0),
                foregroundColor: Colors.white,
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitud', 
                      hintText: 'Ej: 40.4167',
                      border: OutlineInputBorder()
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitud', 
                      hintText: 'Ej: -3.7033',
                      border: OutlineInputBorder()
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: _isGettingLocation 
                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, size: 16),
              label: const Text('Recalcular con GPS'),
            ),
          ],

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          
          Text('Radio de detección: ${_radius.toInt()} metros', 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text('Define qué tan cerca debes estar para activar este modo.', 
            style: TextStyle(fontSize: 12, color: Colors.grey)),
          Slider(
            value: _radius,
            min: 10,
            max: 100,
            divisions: 9,
            label: '${_radius.toInt()}m',
            onChanged: (v) => setState(() => _radius = v),
          ),
          
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
            child: const Text('GUARDAR CONFIGURACIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          
          if (hasLocation || _isManualMode)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _isManualMode = !_isManualMode),
                child: Text(_isManualMode ? 'Ocultar campos manuales' : 'Editar coordenadas manualmente'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(bool hasLocation) {
    return Column(
      children: [
        Icon(
          hasLocation ? Icons.location_on : Icons.location_off, 
          color: hasLocation ? Colors.greenAccent : Colors.redAccent, 
          size: 48
        ),
        const SizedBox(height: 8),
        Text(
          hasLocation ? 'LISTO PARA DETECTAR' : 'UBICACIÓN PENDIENTE',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: hasLocation ? Colors.greenAccent : Colors.redAccent,
            letterSpacing: 1.1
          ),
        ),
      ],
    );
  }
}
