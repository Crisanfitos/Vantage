import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/api/auth_providers.dart';
import '../../../core/api/task_providers.dart';
import '../../context_engine/presentation/environments_provider.dart';
import '../domain/task_models.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String? _selectedEnvId; // Null significa "Calle/General"

  @override
  Widget build(BuildContext context) {
    final environments = ref.watch(environmentsProvider);
    final tasks = ref.watch(filteredTasksProvider(_selectedEnvId));

    // Si no hay entorno seleccionado y hay entornos disponibles,
    // podríamos seleccionar el primero por defecto o dejarlo en Calle (null).

    return Scaffold(
      appBar: AppBar(
        title: Text('TAREAS', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildContextSelector(environments),
          Expanded(
            child: tasks.isEmpty 
              ? const Center(child: Text('Nada pendiente en este contexto'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => _buildTaskItem(tasks[index]),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add_task, color: Colors.black87),
      ),
    );
  }

  Widget _buildContextSelector(environments) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _contextChip(null, 'Calle', Icons.directions_walk),
          ...environments.map((env) => _contextChip(env.id, env.name, Icons.location_on)),
        ],
      ),
    );
  }

  Widget _contextChip(String? id, String label, IconData icon) {
    final isSelected = _selectedEnvId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.black : Colors.grey),
        selected: isSelected,
        onSelected: (val) => setState(() => _selectedEnvId = id),
        selectedColor: Colors.amber,
      ),
    );
  }

  Widget _buildTaskItem(VantageTask task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(task.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) {
                final user = ref.read(userProfileProvider).value;
                if (user != null) {
                  ref.read(taskRepositoryProvider).saveTask(
                    user.id, 
                    task.copyWith(isCompleted: !task.isCompleted)
                  );
                }
              },
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black87,
              icon: task.isCompleted ? Icons.undo : Icons.check_circle_outline,
              label: task.isCompleted ? 'Deshacer' : 'Hecho',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) {
                final user = ref.read(userProfileProvider).value;
                if (user != null) ref.read(taskRepositoryProvider).deleteTask(user.id, task.id);
              },
              backgroundColor: Colors.redAccent,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias, // Evita que el contenido se salga de los bordes redondeados
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            title: Text(
              task.title, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              task.priority.name.toUpperCase(), 
              style: TextStyle(
                color: _getPriorityColor(task.priority).withOpacity(task.isCompleted ? 0.5 : 1),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: task.isCompleted 
              ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20) 
              : null,
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high: return Colors.redAccent;
      case TaskPriority.medium: return Colors.orangeAccent;
      case TaskPriority.low: return Colors.blueAccent;
    }
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    TaskPriority priority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva Tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: '¿Qué hay que hacer?')),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: priority,
                items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => priority = v!),
                decoration: const InputDecoration(labelText: 'Prioridad'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(userProfileProvider).value;
                if (user != null && titleController.text.isNotEmpty) {
                  final task = VantageTask(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    priority: priority,
                    environmentId: _selectedEnvId, // Se añade al contexto actual
                    createdAt: DateTime.now(),
                  );
                  ref.read(taskRepositoryProvider).saveTask(user.id, task);
                  Navigator.pop(context);
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        ),
      ),
    );
  }
}
