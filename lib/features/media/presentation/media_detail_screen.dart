import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/auth_providers.dart';
import '../../../core/api/media_providers.dart';
import '../domain/media_models.dart';

class MediaDetailScreen extends ConsumerStatefulWidget {
  final VantageMedia media;
  const MediaDetailScreen({super.key, required this.media});

  @override
  ConsumerState<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends ConsumerState<MediaDetailScreen> {
  late TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _unitController = TextEditingController(text: widget.media.currentUnit.toString());
  }

  Future<void> _updateProgress(VantageMedia currentMedia, int newUnit) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final updated = currentMedia.copyWith(currentUnit: newUnit);
      await ref.read(mediaRepositoryProvider).saveMediaItem(user.uid, updated);
      // No actualizamos el controller aquí, dejamos que el Stream lo haga para mantener consistencia
    }
  }

  Future<void> _updateType(VantageMedia currentMedia, MediaType newType) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final updated = VantageMedia(
        id: currentMedia.id,
        title: currentMedia.title,
        imageUrl: currentMedia.imageUrl,
        bannerUrl: currentMedia.bannerUrl,
        description: currentMedia.description,
        currentUnit: currentMedia.currentUnit,
        totalUnits: currentMedia.totalUnits,
        type: newType,
        externalUrl: currentMedia.externalUrl,
        nextRelease: currentMedia.nextRelease,
        externalId: currentMedia.externalId,
        source: currentMedia.source,
        characters: currentMedia.characters,
        authors: currentMedia.authors,
        genres: currentMedia.genres,
      );
      await ref.read(mediaRepositoryProvider).saveMediaItem(user.uid, updated);
      // Si cambia de tipo (ej: Anime -> Peli), salimos para evitar confusión de UI
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteItem(VantageMedia currentMedia) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await ref.read(mediaRepositoryProvider).deleteMediaItem(user.uid, currentMedia.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vigilamos el elemento específico en tiempo real
    final mediaAsync = ref.watch(mediaItemProvider(widget.media.id));

    return mediaAsync.when(
      // Usamos el dato de Firestore si existe, si no el inicial del constructor (fallback)
      data: (liveMedia) => _buildDetail(liveMedia ?? widget.media),
      loading: () => _buildDetail(widget.media), // Mientras carga mostramos el inicial
      error: (e, _) => _buildDetail(widget.media),
    );
  }

  Widget _buildDetail(VantageMedia media) {
    // Sincronizamos el controller con el valor real de DB si no se está editando activamente
    if (_unitController.text != media.currentUnit.toString()) {
      _unitController.text = media.currentUnit.toString();
    }

    final isSerial = media.type == MediaType.series || 
                     media.type == MediaType.anime || 
                     media.type == MediaType.manga;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, media),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSerial) _buildSerialProgressControl(media) else _buildUnitaryStatusControl(media),
                  const SizedBox(height: 32),
                  if (media.type == MediaType.anime) _buildAnimeTypeToggle(media),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Sinopsis'),
                  const SizedBox(height: 12),
                  Text(
                    media.description?.replaceAll(RegExp(r'<[^>]*>'), '') ?? 'Sin descripción disponible',
                    style: GoogleFonts.notoSans(color: Colors.white.withValues(alpha: 0.7), height: 1.6, fontSize: 15),
                  ),
                  if (media.characters != null && media.characters!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildSectionTitle('Reparto / Personajes'),
                    const SizedBox(height: 16),
                    _buildCharacterList(media),
                  ],
                  if (media.authors != null && media.authors!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildSectionTitle('Autores'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: media.authors!.map((a) => Chip(
                        label: Text(a, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.white10,
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, VantageMedia media) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: Colors.black,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
        child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, media),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        title: Text(media.title, 
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: media.bannerUrl != null || media.imageUrl != null
                ? Image.network(media.bannerUrl ?? media.imageUrl!, fit: BoxFit.cover)
                : Container(color: Colors.grey[900]),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                    Colors.black,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSerialProgressControl(VantageMedia media) {
    final label = media.type == MediaType.manga ? 'Capítulo' : 'Episodio';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey)),
              Text('${media.currentUnit} / ${media.totalUnits ?? "?"}', 
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleActionBtn(Icons.remove, () => _updateProgress(media, media.currentUnit - 1)),
              const SizedBox(width: 16),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: TextField(
                    controller: _unitController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.montserrat(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white),
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    onSubmitted: (val) => _updateProgress(media, int.tryParse(val) ?? media.currentUnit),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _circleActionBtn(Icons.add, () => _updateProgress(media, media.currentUnit + 1), isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitaryStatusControl(VantageMedia media) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Text('ESTADO DE LA MISIÓN', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statusButton(media, 'PENDIENTE', 0, Icons.hourglass_empty),
              _statusButton(media, 'EN CURSO', 1, Icons.play_arrow),
              _statusButton(media, 'COMPLETADO', 2, Icons.check_circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(VantageMedia media, String label, int value, IconData icon) {
    final isSelected = media.currentUnit == value;
    final color = isSelected ? Colors.cyanAccent : Colors.white24;
    
    return InkWell(
      onTap: () => _updateProgress(media, value),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAnimeTypeToggle(VantageMedia media) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.cyanAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('¿ES UNA PELÍCULA?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Switch(
            value: false,
            activeColor: Colors.cyanAccent,
            onChanged: (val) {
              if (val) _updateType(media, MediaType.movie);
            },
          ),
        ],
      ),
    );
  }

  Widget _circleActionBtn(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary ? Colors.redAccent : Colors.white.withValues(alpha: 0.05),
          border: isPrimary ? null : Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, 
      style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.cyanAccent));
  }

  Widget _buildCharacterList(VantageMedia media) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: media.characters!.length,
        itemBuilder: (context, i) {
          final char = media.characters![i];
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: char['imageUrl'] != null && char['imageUrl'] != ''
                    ? Image.network(char['imageUrl'], height: 80, width: 80, fit: BoxFit.cover)
                    : Container(height: 80, width: 80, color: Colors.white10, child: const Icon(Icons.person, color: Colors.white24)),
                ),
                const SizedBox(height: 8),
                Text(char['name'], 
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 10, color: Colors.white70, overflow: TextOverflow.ellipsis)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, VantageMedia media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar de tu lista?'),
        content: Text('Se borrará tu progreso en "${media.title}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteItem(media);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
