import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../../features/finance/data/finance_repository_impl.dart';
import '../../features/finance/data/recurring_repository_impl.dart';
import '../../features/finance/domain/finance_models.dart';
import '../../features/finance/domain/recurring_models.dart';
import 'auth_providers.dart';

final financeRepositoryProvider = Provider<IFinanceRepository>((ref) {
  return FirestoreFinanceRepository();
});

final recurringRepositoryProvider = Provider<IRecurringRepository>((ref) {
  return FirestoreRecurringRepository();
});

/// Provee las plantillas recurrentes
final recurringTemplatesProvider = StreamProvider<List<RecurringTemplate>>((ref) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(recurringRepositoryProvider).watchTemplates(user.id);
});

/// Provee la lista de registros y ejecuta la AUTOMATIZACIÓN TOTAL
final financeRecordsProvider = StreamProvider<List<FinanceRecord>>((ref) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return Stream.value([]);
  
  final repo = ref.watch(financeRepositoryProvider);
  final templates = ref.watch(recurringTemplatesProvider).value ?? [];
  final stream = repo.watchRecords(user.id);
  
  // MOTOR DE AUTOMATIZACIÓN (Check-in)
  stream.listen((records) {
    final now = DateTime.now();
    
    // 1. Procesar todas las plantillas recurrentes (Netflix, Alquiler, etc.)
    for (final template in templates) {
      if (now.day >= template.dayOfMonth) {
        final alreadyProcessed = records.any((r) => 
          r.title == template.title && 
          r.date.year == now.year && 
          r.date.month == now.month
        );
        
        if (!alreadyProcessed) {
          repo.addRecord(user.id, template.toRecord(const Uuid().v4(), now.year, now.month));
        }
      }
    }

    // 2. Procesar Nómina Maestro (Si está configurada en perfil)
    if (user.salaryDay != null && user.salaryAmount != null && user.salaryAmount! > 0) {
      if (now.day >= user.salaryDay!) {
        final alreadyPaid = records.any((r) => 
          r.category == 'Nómina' && r.date.year == now.year && r.date.month == now.month
        );
        
        if (!alreadyPaid) {
          repo.addRecord(user.id, FinanceRecord(
            id: const Uuid().v4(),
            title: 'Ingreso Nómina',
            amount: user.salaryAmount!,
            date: DateTime(now.year, now.month, user.salaryDay!),
            type: TransactionType.income,
            category: 'Nómina',
            isRecurring: true,
          ));
        }
      }
    }
  });

  return stream;
});

final balanceProvider = Provider<double>((ref) {
  final records = ref.watch(financeRecordsProvider).value ?? [];
  return records.fold(0.0, (sum, item) => item.type == TransactionType.income ? sum + item.amount : sum - item.amount);
});

final currentMonthStatsProvider = Provider<Map<String, double>>((ref) {
  final records = ref.watch(financeRecordsProvider).value ?? [];
  final now = DateTime.now();
  double income = 0;
  double expense = 0;
  for (var r in records) {
    if (r.date.year == now.year && r.date.month == now.month) {
      r.type == TransactionType.income ? income += r.amount : expense += r.amount;
    }
  }
  return {'income': income, 'expense': expense};
});
