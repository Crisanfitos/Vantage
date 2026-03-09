enum VantageThemeType {
  midnight,
  neon,
  forest,
  sunset,
  ocean,
}

class VantageEnvironment {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusInMeters;
  final VantageThemeType themeType;
  final String iconName;
  final String? imagePath;

  VantageEnvironment({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusInMeters,
    required this.themeType,
    required this.iconName,
    this.imagePath,
  });

  // Copia con cambios (útil para el gestor de estado)
  VantageEnvironment copyWith({
    String? name,
    double? latitude,
    double? longitude,
    double? radiusInMeters,
    VantageThemeType? themeType,
    String? iconName,
    String? imagePath,
  }) {
    return VantageEnvironment(
      id: id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusInMeters: radiusInMeters ?? this.radiusInMeters,
      themeType: themeType ?? this.themeType,
      iconName: iconName ?? this.iconName,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
