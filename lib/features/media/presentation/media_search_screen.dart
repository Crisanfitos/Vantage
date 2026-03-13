import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/auth_providers.dart';
import '../../../core/api/media_providers.dart';
import '../domain/media_models.dart';

class MediaSearchScreen extends ConsumerStatefulWidget {
  const MediaSearchScreen({super.key});

  @override
  ConsumerState<MediaSearchScreen> createState() => _MediaSearchScreenState();
}

class _MediaSearchScreenState extends ConsumerState<MediaSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Refrescar para mostrar/ocultar el botón 'X'
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(mediaSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Buscar anime, manga, libros...',
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onSubmitted: (val) => setState(() => _query = val),
          ),
        ),
      ),
      body: _query.isEmpty
          ? const Center(child: Text('Escribe algo para buscar'))
          : searchResults.when(
              data: (list) => list.isEmpty
                  ? const Center(child: Text('No se encontraron resultados'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (context, i) => _buildResultItem(list[i]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
    );
  }

  Widget _buildResultItem(VantageMedia media) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: media.imageUrl != null 
              ? Image.network(media.imageUrl!, width: 45, fit: BoxFit.cover)
              : Container(width: 45, color: Colors.grey, child: const Icon(Icons.movie)),
        ),
        title: Text(media.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(media.type.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.redAccent)),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.cyanAccent),
          onPressed: () => _addMedia(media),
        ),
      ),
    );
  }

  Future<void> _addMedia(VantageMedia media) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      VantageMedia mediaToSave = media;
      
      // Si es de OMDB, traemos el detalle completo (actores, plot largo) antes de guardar
      if (media.source == 'omdb') {
        final fullDetails = await ref.read(mediaDiscoveryServiceProvider).fetchFullOMDBDetails(media);
        if (fullDetails != null) mediaToSave = fullDetails;
      }

      await ref.read(mediaRepositoryProvider).saveMediaItem(user.uid, mediaToSave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${media.title}" añadido a tu lista')),
        );
        Navigator.pop(context);
      }
    }
  }
}
