import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/media_models.dart';

class MediaHubScreen extends ConsumerStatefulWidget {
  const MediaHubScreen({super.key});

  @override
  ConsumerState<MediaHubScreen> createState() => _MediaHubScreenState();
}

class _MediaHubScreenState extends ConsumerState<MediaHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MEDIA HUB', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'ANIME', icon: Icon(Icons.animation)),
            Tab(text: 'MANGA', icon: Icon(Icons.menu_book)),
            Tab(text: 'SERIES', icon: Icon(Icons.tv)),
            Tab(text: 'PELIS', icon: Icon(Icons.movie)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMediaGrid(MediaType.anime),
          _buildMediaGrid(MediaType.manga),
          _buildMediaGrid(MediaType.series),
          _buildMediaGrid(MediaType.movie),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // TODO: Abrir buscador de AniList
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }

  Widget _buildMediaGrid(MediaType type) {
    // Mock data temporal
    final List<VantageMedia> items = [
      VantageMedia(id: '1', title: 'One Piece', type: MediaType.anime, currentChapter: 1090, imageUrl: 'https://via.placeholder.com/150x220'),
      VantageMedia(id: '2', title: 'Solo Leveling', type: MediaType.manga, currentChapter: 12, imageUrl: 'https://via.placeholder.com/150x220'),
    ].where((m) => m.type == type).toList();

    if (items.isEmpty) {
      return const Center(child: Text('No hay nada en esta lista todavía.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildMediaCard(items[index]),
    );
  }

  Widget _buildMediaCard(VantageMedia media) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(media.imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              media.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cap. ${media.currentChapter}',
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () {}, // TODO: Incrementar capitulo
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
