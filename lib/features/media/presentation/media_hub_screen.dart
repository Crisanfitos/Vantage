import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/auth_providers.dart';
import '../../../core/api/media_providers.dart';
import '../domain/media_models.dart';
import 'media_search_screen.dart';
import 'media_detail_screen.dart';

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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final myMediaAsync = ref.watch(myMediaItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('MEDIA HUB', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'ANIME', icon: Icon(Icons.animation)),
            Tab(text: 'MANGA', icon: Icon(Icons.menu_book)),
            Tab(text: 'LIBROS', icon: Icon(Icons.book)),
            Tab(text: 'SERIES', icon: Icon(Icons.tv)),
            Tab(text: 'PELIS', icon: Icon(Icons.movie)),
          ],
        ),
      ),
      body: myMediaAsync.when(
        data: (items) => TabBarView(
          controller: _tabController,
          children: [
            _buildMediaGrid(items, MediaType.anime),
            _buildMediaGrid(items, MediaType.manga),
            _buildMediaGrid(items, MediaType.book),
            _buildMediaGrid(items, MediaType.series),
            _buildMediaGrid(items, MediaType.movie),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaSearchScreen())),
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }

  Widget _buildMediaGrid(List<VantageMedia> allItems, MediaType type) {
    final items = allItems.where((m) => m.type == type).toList();

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
    final isUnitary = media.type == MediaType.book || media.type == MediaType.movie;

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaDetailScreen(media: media))),
      onLongPress: () => _confirmDelete(context, media),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: media.imageUrl != null 
            ? DecorationImage(image: NetworkImage(media.imageUrl!), fit: BoxFit.cover)
            : null,
          color: Colors.grey[900],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
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
                    _getUnitLabel(media),
                    style: TextStyle(
                      color: isUnitary ? _getStatusColor(media.currentUnit) : Colors.redAccent, 
                      fontWeight: FontWeight.w600, 
                      fontSize: 11
                    ),
                  ),
                  if (isUnitary)
                    Icon(_getStatusIcon(media.currentUnit), size: 18, color: _getStatusColor(media.currentUnit))
                  else
                    GestureDetector(
                      onTap: () => _incrementProgress(media),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
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
      ),
    );
  }

  String _getUnitLabel(VantageMedia media) {
    if (media.type == MediaType.book || media.type == MediaType.movie) {
      switch (media.currentUnit) {
        case 1: return 'EN CURSO';
        case 2: return 'COMPLETADO';
        default: return 'PENDIENTE';
      }
    }
    if (media.type == MediaType.manga) return 'Cap. ${media.currentUnit}';
    return 'Ep. ${media.currentUnit}';
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 1: return Icons.play_circle_outline;
      case 2: return Icons.check_circle_outline;
      default: return Icons.hourglass_empty;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: return Colors.cyanAccent;
      case 2: return Colors.greenAccent;
      default: return Colors.white38;
    }
  }

  Future<void> _incrementProgress(VantageMedia media) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final updated = media.copyWith(currentUnit: media.currentUnit + 1);
      await ref.read(mediaRepositoryProvider).saveMediaItem(user.uid, updated);
    }
  }

  void _confirmDelete(BuildContext context, VantageMedia media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar elemento?'),
        content: Text('¿Quieres quitar "${media.title}" de tu lista?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              final user = ref.read(authStateProvider).value;
              if (user != null) {
                await ref.read(mediaRepositoryProvider).deleteMediaItem(user.uid, media.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
