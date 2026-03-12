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
  final String iconName;
  final String? imagePath;
  
  // Nuevos campos de personalización
  final int colorSeedValue; // Color ARGB para el tema
  final String? preferredDashboardStyle; // grid, cards, timeline
  final List<String> visibleModules; // ['finance', 'tasks', 'github', 'media', 'notes']

  VantageEnvironment({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusInMeters,
    required this.iconName,
    this.imagePath,
    this.colorSeedValue = 0xFF673AB7, // Purple por defecto
    this.preferredDashboardStyle,
    this.visibleModules = const ['finance', 'tasks', 'github', 'media', 'notes'],
  });

  VantageEnvironment copyWith({
    String? name,
    double? latitude,
    double? longitude,
    double? radiusInMeters,
    String? iconName,
    String? imagePath,
    int? colorSeedValue,
    String? preferredDashboardStyle,
    List<String>? visibleModules,
  }) {
    return VantageEnvironment(
      id: id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusInMeters: radiusInMeters ?? this.radiusInMeters,
      iconName: iconName ?? this.iconName,
      imagePath: imagePath ?? this.imagePath,
      colorSeedValue: colorSeedValue ?? this.colorSeedValue,
      preferredDashboardStyle: preferredDashboardStyle ?? this.preferredDashboardStyle,
      visibleModules: visibleModules ?? this.visibleModules,
    );
  }
}
