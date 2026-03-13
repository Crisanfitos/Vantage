import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/github_models.dart';

class GitHubRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveRepoNote(String userId, RepoNote note) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('repo_notes')
        .doc(note.id)
        .set({
      'repoId': note.repoId,
      'branchName': note.branchName,
      'content': note.content,
      'createdAt': Timestamp.fromDate(note.createdAt),
    });
  }

  Stream<List<RepoNote>> watchRepoNotes(String userId, String repoId, String branchName) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('repo_notes')
        .where('repoId', isEqualTo: repoId)
        .where('branchName', isEqualTo: branchName)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return RepoNote(
                id: doc.id,
                repoId: data['repoId'],
                branchName: data['branchName'],
                content: data['content'],
                createdAt: (data['createdAt'] as Timestamp).toDate(),
              );
            }).toList());
  }

  Future<void> deleteRepoNote(String userId, String noteId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('repo_notes')
        .doc(noteId)
        .delete();
  }
}
