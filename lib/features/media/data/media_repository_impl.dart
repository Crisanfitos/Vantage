import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/media_models.dart';

abstract class IMediaRepository {
  Future<void> saveMediaItem(String userId, VantageMedia media);
  Future<void> deleteMediaItem(String userId, String mediaId);
  Stream<List<VantageMedia>> watchMediaItems(String userId);
}

class FirestoreMediaRepository implements IMediaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveMediaItem(String userId, VantageMedia media) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('media_items')
        .doc(media.id)
        .set({
      'externalId': media.externalId,
      'source': media.source,
      'type': media.type.name,
      'title': media.title,
      'imageUrl': media.imageUrl,
      'bannerUrl': media.bannerUrl,
      'description': media.description,
      'currentUnit': media.currentUnit,
      'totalUnits': media.totalUnits,
      'externalUrl': media.externalUrl,
      'nextRelease': media.nextRelease != null ? Timestamp.fromDate(media.nextRelease!) : null,
      'genres': media.genres,
      'authors': media.authors,
      'characters': media.characters,
    });
  }

  @override
  Future<void> deleteMediaItem(String userId, String mediaId) async {
    await _firestore.collection('users').doc(userId).collection('media_items').doc(mediaId).delete();
  }

  @override
  Stream<List<VantageMedia>> watchMediaItems(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('media_items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return VantageMedia(
                id: doc.id,
                externalId: data['externalId'],
                source: data['source'],
                title: data['title'] ?? '',
                imageUrl: data['imageUrl'],
                bannerUrl: data['bannerUrl'],
                description: data['description'],
                currentUnit: data['currentUnit'] ?? 0,
                totalUnits: data['totalUnits'],
                type: MediaType.values.firstWhere((e) => e.name == data['type']),
                externalUrl: data['externalUrl'],
                nextRelease: (data['nextRelease'] as Timestamp?)?.toDate(),
                genres: data['genres'] != null ? List<String>.from(data['genres']) : null,
                authors: data['authors'] != null ? List<String>.from(data['authors']) : null,
                characters: data['characters'] != null ? List<Map<String, dynamic>>.from(data['characters']) : null,
              );
            }).toList());
  }
}
