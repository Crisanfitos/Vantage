enum MediaType { anime, manga, series, movie }

class VantageMedia {
  final String id;
  final String title;
  final String? imageUrl;
  final int currentChapter;
  final int? totalChapters;
  final MediaType type;
  final String? externalUrl; // Link donde lo ves/lees
  final DateTime? nextRelease; // Cuándo sale el próximo

  VantageMedia({
    required this.id,
    required this.title,
    this.imageUrl,
    this.currentChapter = 0,
    this.totalChapters,
    required this.type,
    this.externalUrl,
    this.nextRelease,
  });

  VantageMedia copyWith({
    int? currentChapter,
    DateTime? nextRelease,
    String? externalUrl,
  }) {
    return VantageMedia(
      id: id,
      title: title,
      imageUrl: imageUrl,
      currentChapter: currentChapter ?? this.currentChapter,
      totalChapters: totalChapters,
      type: type,
      externalUrl: externalUrl ?? this.externalUrl,
      nextRelease: nextRelease ?? this.nextRelease,
    );
  }
}
