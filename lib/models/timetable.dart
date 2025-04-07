import 'package:cloud_firestore/cloud_firestore.dart';

class Timetable {
  final String id;
  final String studentId;
  final List<TimetableEntry> entries;

  Timetable({required this.id, required this.studentId, required this.entries});

  factory Timetable.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Timetable(
      id: doc.id,
      studentId: data['studentId'],
      entries: (data['entries'] as List)
          .map((e) => TimetableEntry.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "studentId": studentId,
      "entries": entries.map((e) => e.toMap()).toList(),
    };
  }
}

class TimetableEntry {
  final String entryId; // unique id for this entry
  final String subject;
  final String startTime;
  final String endTime;
  final String sessionType; // "theory" or "practice"
  final int target; // Pages or MCQs

  TimetableEntry({
    required this.entryId,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.sessionType,
    required this.target,
  });

  factory TimetableEntry.fromMap(Map<String, dynamic> data) {
    return TimetableEntry(
      entryId: data['entryId'],
      subject: data['subject'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      sessionType: data['sessionType'],
      target: data['target'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "entryId": entryId,
      "subject": subject,
      "startTime": startTime,
      "endTime": endTime,
      "sessionType": sessionType,
      "target": target,
    };
  }
}
