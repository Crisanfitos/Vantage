import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/auth_providers.dart';
import '../../../core/api/dashboard_providers.dart';
import '../domain/dashboard_models.dart';

class SchedulesScreen extends ConsumerStatefulWidget {
  const SchedulesScreen({super.key});

  @override
  ConsumerState<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends ConsumerState<SchedulesScreen> {
  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(timelineEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Horarios Periódicos')),
      body: eventsAsync.when(
        data: (events) {
          final recurring = events.where((e) => e.isRecurring).toList();
          return recurring.isEmpty
              ? const Center(child: Text('No tienes horarios configurados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recurring.length,
                  itemBuilder: (context, i) => _buildScheduleItem(recurring[i]),
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddScheduleDialog(context, ref),
        label: const Text('Nuevo Horario'),
        icon: const Icon(Icons.add_alarm),
      ),
    );
  }

  Widget _buildScheduleItem(TimelineEvent event) {
    final start = '${event.startHour.toString().padLeft(2, '0')}:${event.startMinute.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.repeat, color: Colors.deepPurpleAccent),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Empieza a las $start'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            final user = ref.read(authStateProvider).value;
            if (user != null) ref.read(dashboardRepositoryProvider).deleteEvent(user.uid, event.id);
          },
        ),
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo Horario Fijo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título (Ej: Entrada Trabajo)')),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Hora de inicio'),
                trailing: Text(selectedTime.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: selectedTime);
                  if (picked != null) setState(() => selectedTime = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final event = TimelineEvent(
                    id: 'recurring_${const Uuid().v4()}',
                    title: titleController.text,
                    startHour: selectedTime.hour,
                    startMinute: selectedTime.minute,
                    isRecurring: true,
                  );
                  final user = ref.read(authStateProvider).value;
                  if (user != null) ref.read(dashboardRepositoryProvider).saveEvent(user.uid, event);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
