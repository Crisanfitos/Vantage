import 'package:cloud_firestore/cloud_firestore.dart';

class VantageNote {
  final String id;
  final String content;
  final String? environmentId;
  final DateTime createdAt;

  VantageNote({
    required this.id,
    required this.content,
    this.environmentId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'environmentId': environmentId,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory VantageNote.fromJson(Map<String, dynamic> json, String id) => VantageNote(
    id: id,
    content: json['content'] ?? '',
    environmentId: json['environmentId'],
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );
}

class TimelineEvent {
  final String id;
  final String title;
  final int startHour;
  final int startMinute;
  final int? endHour;
  final int? endMinute;
  final bool isRecurring;
  final List<int>? daysOfWeek; 
  final String? environmentId;

  TimelineEvent({
    required this.id,
    required this.title,
    required this.startHour,
    required this.startMinute,
    this.endHour,
    this.endMinute,
    this.isRecurring = false,
    this.daysOfWeek,
    this.environmentId,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'startHour': startHour,
    'startMinute': startMinute,
    'endHour': endHour,
    'endMinute': endMinute,
    'isRecurring': isRecurring,
    'daysOfWeek': daysOfWeek,
    'environmentId': environmentId,
  };

  factory TimelineEvent.fromJson(Map<String, dynamic> json, String id) => TimelineEvent(
    id: id,
    title: json['title'] ?? '',
    startHour: json['startHour'] ?? 0,
    startMinute: json['startMinute'] ?? 0,
    endHour: json['endHour'],
    endMinute: json['endMinute'],
    isRecurring: json['isRecurring'] ?? false,
    daysOfWeek: json['daysOfWeek'] != null ? List<int>.from(json['daysOfWeek']) : null,
    environmentId: json['environmentId'],
  );
}
