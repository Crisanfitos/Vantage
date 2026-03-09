import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/api/auth_providers.dart';
import '../../../core/api/finance_providers.dart';
import '../domain/finance_models.dart';
import 'finance_planning_screen.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(balanceProvider);
    final monthStats = ref.watch(currentMonthStatsProvider);
    final recordsAsync = ref.watch(financeRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('FINANZAS', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinancePlanningScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded ? const SizedBox.shrink() : _buildBalanceCard(balance, monthStats),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isExpanded ? 'Historial Completo' : 'Actividad Reciente', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                TextButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded), 
                  child: Text(_isExpanded ? 'Ocultar' : 'Ver todo')
                ),
              ],
            ),
          ),
          Expanded(
            child: recordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(child: Text('Sin movimientos todavía'));
                }
                
                final displayRecords = _isExpanded ? records : records.take(4).toList();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Padding inferior para el FAB
                  itemCount: displayRecords.length,
                  itemBuilder: (context, index) => _buildTransactionItem(displayRecords[index], ref),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(context, ref),
        label: const Text('Añadir Movimiento'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }

  Widget _buildBalanceCard(double balance, Map<String, double> monthStats) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          const Text('BALANCE TOTAL', style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(2)}€',
            style: GoogleFonts.montserrat(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text('ESTE MES', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _balanceStat('Ingresos', '+${monthStats['income']?.toStringAsFixed(2)}€', Icons.arrow_upward, Colors.greenAccent),
              Container(width: 1, height: 30, color: Colors.white24),
              _balanceStat('Gastos', '-${monthStats['expense']?.toStringAsFixed(2)}€', Icons.arrow_downward, Colors.orangeAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _balanceStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildTransactionItem(FinanceRecord record, WidgetRef ref) {
    final isExpense = record.type == TransactionType.expense;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(record.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                final user = ref.read(authStateProvider).value;
                if (user != null) {
                  ref.read(financeRepositoryProvider).deleteRecord(user.uid, record.id);
                }
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Borrar',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (isExpense ? Colors.redAccent : Colors.teal).withOpacity(0.1),
              child: Icon(
                _getCategoryIcon(record.category),
                color: isExpense ? Colors.redAccent : Colors.teal,
              ),
            ),
            title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat('dd MMM yyyy').format(record.date)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? "-" : "+"}${record.amount.toStringAsFixed(2)}€',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isExpense ? Colors.redAccent : Colors.tealAccent,
                  ),
                ),
                if (record.isRecurring)
                  const Icon(Icons.repeat, size: 12, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'comida': return Icons.restaurant;
      case 'ocio': return Icons.videogame_asset;
      case 'transporte': return Icons.directions_car;
      case 'nómina': return Icons.work;
      case 'alquiler': return Icons.home;
      default: return Icons.category;
    }
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    TransactionType selectedType = TransactionType.expense;
    String selectedCategory = 'Comida';
    bool isRecurring = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva Transacción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Gasto'), icon: Icon(Icons.remove_circle_outline)),
                  ButtonSegment(value: TransactionType.income, label: Text('Ingreso'), icon: Icon(Icons.add_circle_outline)),
                ],
                selected: {selectedType},
                onSelectionChanged: (val) => setState(() => selectedType = val.first),
              ),
              const SizedBox(height: 16),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Concepto (Ej: Bizum, Netflix)')),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Importe (€)'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Comida', 'Ocio', 'Transporte', 'Nómina', 'Alquiler', 'Otros'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => selectedCategory = v!,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              SwitchListTile(
                title: const Text('Transacción Recurrente'),
                subtitle: const Text('Se repetirá cada mes'),
                value: isRecurring,
                onChanged: (val) => setState(() => isRecurring = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(authStateProvider).value;
                if (user != null && titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  final record = FinanceRecord(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    amount: double.parse(amountController.text),
                    date: DateTime.now(),
                    type: selectedType,
                    category: selectedCategory,
                    isRecurring: isRecurring,
                  );
                  ref.read(financeRepositoryProvider).addRecord(user.uid, record);
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
