import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/finance_models.dart';
import '../domain/recurring_models.dart';

abstract class IRecurringRepository {
  Future<void> saveTemplate(String userId, RecurringTemplate template);
  Future<void> deleteTemplate(String userId, String templateId);
  Stream<List<RecurringTemplate>> watchTemplates(String userId);
}

class FirestoreRecurringRepository implements IRecurringRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveTemplate(String userId, RecurringTemplate template) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_templates')
        .doc(template.id)
        .set({
      'title': template.title,
      'amount': template.amount,
      'dayOfMonth': template.dayOfMonth,
      'type': template.type.name,
      'category': template.category,
    });
  }

  @override
  Future<void> deleteTemplate(String userId, String templateId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_templates')
        .doc(templateId)
        .delete();
  }

  @override
  Stream<List<RecurringTemplate>> watchTemplates(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_templates')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return RecurringTemplate(
                id: doc.id,
                title: data['title'],
                amount: (data['amount'] as num).toDouble(),
                dayOfMonth: data['dayOfMonth'],
                type: TransactionType.values.firstWhere((e) => e.name == data['type']),
                category: data['category'],
              );
            }).toList());
  }
}
