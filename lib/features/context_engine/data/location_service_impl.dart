import 'package:geolocator/geolocator.dart';
import '../domain/location_service_interface.dart';

class LocationService implements ILocationService {
  @override
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Future<bool> isLocationServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() => Geolocator.requestPermission();
}
