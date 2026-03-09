enum TransactionType { income, expense }

class FinanceRecord {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category; // Ej: Alquiler, Comida, Nómina, Ocio
  final bool isRecurring;

  FinanceRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.isRecurring = false,
  });

  FinanceRecord copyWith({
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? category,
    bool? isRecurring,
  }) {
    return FinanceRecord(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}
