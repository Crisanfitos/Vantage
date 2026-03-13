enum MediaType { anime, manga, series, movie, book }

class VantageMedia {
  final String id;
  final String title;
  final String? imageUrl;
  final String? bannerUrl;
  final String? description;
  final int currentUnit;
  final int? totalUnits;
  final MediaType type;
  final String? externalUrl;
  final DateTime? nextRelease;
  final String? externalId;
  final String? source;
  
  // Datos de Lore / Metadatos
  final List<Map<String, dynamic>>? characters;
  final List<String>? authors;
  final List<String>? genres;

  VantageMedia({
    required this.id,
    required this.title,
    this.imageUrl,
    this.bannerUrl,
    this.description,
    this.currentUnit = 0,
    this.totalUnits,
    required this.type,
    this.externalUrl,
    this.nextRelease,
    this.externalId,
    this.source,
    this.characters,
    this.authors,
    this.genres,
  });

  VantageMedia copyWith({
    int? currentUnit,
    DateTime? nextRelease,
    String? externalUrl,
  }) {
    return VantageMedia(
      id: id,
      title: title,
      imageUrl: imageUrl,
      bannerUrl: bannerUrl,
      description: description,
      currentUnit: currentUnit ?? this.currentUnit,
      totalUnits: totalUnits,
      type: type,
      externalUrl: externalUrl ?? this.externalUrl,
      nextRelease: nextRelease ?? this.nextRelease,
      externalId: externalId,
      source: source,
      characters: characters,
      authors: authors,
      genres: genres,
    );
  }
}
