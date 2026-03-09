import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/finance_models.dart';

class FinanceRecordModel extends FinanceRecord {
  FinanceRecordModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.type,
    required super.category,
    super.isRecurring,
  });

  factory FinanceRecordModel.fromEntity(FinanceRecord entity) {
    return FinanceRecordModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      type: entity.type,
      category: entity.category,
      isRecurring: entity.isRecurring,
    );
  }

  factory FinanceRecordModel.fromJson(Map<String, dynamic> json, String id) {
    return FinanceRecordModel(
      id: id,
      title: json['title'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      date: (json['date'] as Timestamp).toDate(),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      category: json['category'] ?? '',
      isRecurring: json['isRecurring'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'type': type.name,
      'category': category,
      'isRecurring': isRecurring,
    };
  }
}

abstract class IFinanceRepository {
  Future<void> addRecord(String userId, FinanceRecord record);
  Future<void> deleteRecord(String userId, String recordId);
  Stream<List<FinanceRecord>> watchRecords(String userId);
}

class FirestoreFinanceRepository implements IFinanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addRecord(String userId, FinanceRecord record) async {
    final model = FinanceRecordModel.fromEntity(record);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('finance_records')
        .doc(model.id)
        .set(model.toJson());
  }

  @override
  Future<void> deleteRecord(String userId, String recordId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('finance_records')
        .doc(recordId)
        .delete();
  }

  @override
  Stream<List<FinanceRecord>> watchRecords(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('finance_records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinanceRecordModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
