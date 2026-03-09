import 'finance_models.dart';

class RecurringTemplate {
  final String id;
  final String title;
  final double amount;
  final int dayOfMonth;
  final TransactionType type;
  final String category;

  RecurringTemplate({
    required this.id,
    required this.title,
    required this.amount,
    required this.dayOfMonth,
    required this.type,
    required this.category,
  });

  // Convertir plantilla a un registro real para un mes/año específico
  FinanceRecord toRecord(String recordId, int year, int month) {
    return FinanceRecord(
      id: recordId,
      title: title,
      amount: amount,
      date: DateTime(year, month, dayOfMonth),
      type: type,
      category: category,
      isRecurring: true,
    );
  }
}
