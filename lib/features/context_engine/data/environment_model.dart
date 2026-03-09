import '../domain/environment.dart';

class EnvironmentModel extends VantageEnvironment {
  EnvironmentModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.radiusInMeters,
    required super.themeType,
    required super.iconName,
    super.imagePath,
  });

  factory EnvironmentModel.fromEntity(VantageEnvironment entity) {
    return EnvironmentModel(
      id: entity.id,
      name: entity.name,
      latitude: entity.latitude,
      longitude: entity.longitude,
      radiusInMeters: entity.radiusInMeters,
      themeType: entity.themeType,
      iconName: entity.iconName,
      imagePath: entity.imagePath,
    );
  }

  factory EnvironmentModel.fromJson(Map<String, dynamic> json, String id) {
    return EnvironmentModel(
      id: id,
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusInMeters: (json['radius'] as num).toDouble(),
      themeType: VantageThemeType.values.firstWhere(
        (e) => e.name == json['themeType'],
        orElse: () => VantageThemeType.midnight,
      ),
      iconName: json['iconName'] ?? 'location_on',
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radiusInMeters,
      'themeType': themeType.name,
      'iconName': iconName,
      'imagePath': imagePath,
    };
  }
}
