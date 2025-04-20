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
  final String entryId;
  final String title;
  final String subject;
  final String sessionType;
  final DateTime startTime; // includes date + time
  final DateTime endTime;
  final String target;
  final bool repeatWeekly;
  final bool done;

  TimetableEntry({
    required this.entryId,
    required this.title,
    required this.subject,
    required this.sessionType,
    required this.startTime,
    required this.endTime,
    required this.target,
    required this.repeatWeekly,
    required this.done,
  });

  factory TimetableEntry.fromMap(Map<String, dynamic> data) {
    return TimetableEntry(
      entryId: data['entryId'],
      title: data['title'],
      subject: data['subject'],
      sessionType: data['sessionType'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      target: data['target'],
      repeatWeekly: data['repeatWeekly'] ?? false,
      done: data['done'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "entryId": entryId,
      "title": title,
      "subject": subject,
      "sessionType": sessionType,
      "startTime": Timestamp.fromDate(startTime),
      "endTime": Timestamp.fromDate(endTime),
      "target": target,
      "repeatWeekly": repeatWeekly,
      "done": done,
    };
  }
}
