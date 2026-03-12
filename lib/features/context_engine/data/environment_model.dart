import '../domain/environment.dart';

class EnvironmentModel extends VantageEnvironment {
  EnvironmentModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.radiusInMeters,
    required super.iconName,
    super.imagePath,
    super.colorSeedValue,
    super.preferredDashboardStyle,
    super.visibleModules,
  });

  factory EnvironmentModel.fromEntity(VantageEnvironment entity) {
    return EnvironmentModel(
      id: entity.id,
      name: entity.name,
      latitude: entity.latitude,
      longitude: entity.longitude,
      radiusInMeters: entity.radiusInMeters,
      iconName: entity.iconName,
      imagePath: entity.imagePath,
      colorSeedValue: entity.colorSeedValue,
      preferredDashboardStyle: entity.preferredDashboardStyle,
      visibleModules: entity.visibleModules,
    );
  }

  factory EnvironmentModel.fromJson(Map<String, dynamic> json, String id) {
    return EnvironmentModel(
      id: id,
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusInMeters: (json['radius'] as num).toDouble(),
      iconName: json['iconName'] ?? 'location_on',
      imagePath: json['imagePath'],
      colorSeedValue: json['colorSeedValue'] ?? 0xFF673AB7,
      preferredDashboardStyle: json['preferredDashboardStyle'],
      visibleModules: List<String>.from(json['visibleModules'] ?? ['finance', 'tasks', 'github', 'media', 'notes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radiusInMeters,
      'iconName': iconName,
      'imagePath': imagePath,
      'colorSeedValue': colorSeedValue,
      'preferredDashboardStyle': preferredDashboardStyle,
      'visibleModules': visibleModules,
    };
  }
}
