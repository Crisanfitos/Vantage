import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/context_engine/data/location_service_impl.dart';
import '../../features/context_engine/domain/location_service_interface.dart';

/// Proveedor global para el servicio de ubicación.
final locationServiceProvider = Provider<ILocationService>((ref) {
  return LocationService();
});
