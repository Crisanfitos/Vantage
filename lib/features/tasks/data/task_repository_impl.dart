import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/task_models.dart';

class TaskModel extends VantageTask {
  TaskModel({
    required super.id,
    required super.title,
    super.description,
    super.isCompleted,
    super.priority,
    super.environmentId,
    required super.createdAt,
  });

  factory TaskModel.fromEntity(VantageTask entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      priority: entity.priority,
      environmentId: entity.environmentId,
      createdAt: entity.createdAt,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    return TaskModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      environmentId: json['environmentId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'environmentId': environmentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

abstract class ITaskRepository {
  Future<void> saveTask(String userId, VantageTask task);
  Future<void> deleteTask(String userId, String taskId);
  Stream<List<VantageTask>> watchTasks(String userId);
}

class FirestoreTaskRepository implements ITaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveTask(String userId, VantageTask task) async {
    final model = TaskModel.fromEntity(task);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(model.id)
        .set(model.toJson());
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  @override
  Stream<List<VantageTask>> watchTasks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
