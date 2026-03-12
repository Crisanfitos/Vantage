enum TaskPriority { low, medium, high }

class VantageTask {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final TaskPriority priority;
  final String? environmentId; // ID del entorno vinculado (Casa, Trabajo, etc.)
  final DateTime createdAt;

  VantageTask({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.environmentId,
    required this.createdAt,
  });

  VantageTask copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    String? environmentId,
  }) {
    return VantageTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      environmentId: environmentId ?? this.environmentId,
      createdAt: createdAt,
    );
  }
}
