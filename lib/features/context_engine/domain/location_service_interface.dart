import 'package:geolocator/geolocator.dart';

/// Contrato para el servicio de ubicación.
/// Define qué puede hacer la app con el GPS sin depender de una librería específica.
abstract class ILocationService {
  Future<Position?> getCurrentLocation();
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
}
