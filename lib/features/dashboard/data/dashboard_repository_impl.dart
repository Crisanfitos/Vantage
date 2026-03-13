import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/dashboard_models.dart';

abstract class IDashboardRepository {
  // Notas
  Future<void> saveNote(String userId, VantageNote note);
  Future<void> deleteNote(String userId, String noteId);
  Stream<List<VantageNote>> watchNotes(String userId);

  // Eventos Timeline
  Future<void> saveEvent(String userId, TimelineEvent event);
  Future<void> deleteEvent(String userId, String eventId);
  Stream<List<TimelineEvent>> watchEvents(String userId);
}

class FirestoreDashboardRepository implements IDashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveNote(String userId, VantageNote note) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(note.id)
        .set(note.toJson());
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  @override
  Stream<List<VantageNote>> watchNotes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => VantageNote.fromJson(d.data(), d.id)).toList());
  }

  @override
  Stream<List<TimelineEvent>> watchEvents(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('timeline_events')
        .snapshots()
        .map((s) => s.docs.map((d) => TimelineEvent.fromJson(d.data(), d.id)).toList());
  }

  @override
  Future<void> saveEvent(String userId, TimelineEvent event) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('timeline_events')
        .doc(event.id)
        .set(event.toJson());
  }

  @override
  Future<void> deleteEvent(String userId, String eventId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('timeline_events')
        .doc(eventId)
        .delete();
  }
}
