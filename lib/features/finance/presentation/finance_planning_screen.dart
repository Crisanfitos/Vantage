import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/auth_providers.dart';
import '../../../core/api/finance_providers.dart';
import '../domain/finance_models.dart';
import '../domain/recurring_models.dart';

class FinancePlanningScreen extends ConsumerStatefulWidget {
  const FinancePlanningScreen({super.key});

  @override
  ConsumerState<FinancePlanningScreen> createState() => _FinancePlanningScreenState();
}

class _FinancePlanningScreenState extends ConsumerState<FinancePlanningScreen> {
  late TextEditingController _amountController;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider).value;
    _amountController = TextEditingController(text: user?.salaryAmount?.toString() ?? '');
    _selectedDay = user?.salaryDay ?? 25;
  }

  Future<void> _saveSalary() async {
    final user = ref.read(userProfileProvider).value;
    if (user != null) {
      await ref.read(authServiceProvider).updateUserPreference(user.id, {
        'salaryAmount': double.tryParse(_amountController.text) ?? 0.0,
        'salaryDay': _selectedDay,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nómina actualizada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(recurringTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Planificación Mensual')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSalarySection(),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Suscripciones y Recurrencia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.tealAccent),
                onPressed: () => _showAddTemplateDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),
          templatesAsync.when(
            data: (templates) => templates.isEmpty 
              ? const Text('No tienes suscripciones configuradas', style: TextStyle(color: Colors.grey))
              : Column(children: templates.map((t) => _buildTemplateItem(t, ref)).toList()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildSalarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configuración de Nómina', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          decoration: const InputDecoration(labelText: 'Importe Neto (€)', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          onSubmitted: (_) => _saveSalary(),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _selectedDay,
          decoration: const InputDecoration(labelText: 'Día de Cobro', border: OutlineInputBorder()),
          items: List.generate(31, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text('Día $d'))).toList(),
          onChanged: (v) {
            setState(() => _selectedDay = v!);
            _saveSalary();
          },
        ),
      ],
    );
  }

  Widget _buildTemplateItem(RecurringTemplate t, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.repeat, color: Colors.grey),
      title: Text(t.title),
      subtitle: Text('Día ${t.dayOfMonth} - ${t.amount}€'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: () {
          final user = ref.read(userProfileProvider).value;
          if (user != null) ref.read(recurringRepositoryProvider).deleteTemplate(user.id, t.id);
        },
      ),
    );
  }

  void _showAddTemplateDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    int day = 1;
    String category = 'Ocio';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva Suscripción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Nombre (Ej: Netflix)')),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Importe (€)'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: day,
                items: List.generate(31, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text('Día $d'))).toList(),
                onChanged: (v) => setState(() => day = v!),
                decoration: const InputDecoration(labelText: 'Día de cargo'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(userProfileProvider).value;
                if (user != null && titleController.text.isNotEmpty) {
                  final template = RecurringTemplate(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    amount: double.parse(amountController.text),
                    dayOfMonth: day,
                    type: TransactionType.expense,
                    category: category,
                  );
                  ref.read(recurringRepositoryProvider).saveTemplate(user.id, template);
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
