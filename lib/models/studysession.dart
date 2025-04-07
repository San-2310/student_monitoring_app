import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  final String id;
  final String studentId;
  final String? timetableEntryId;
  final String subject;
  final Timestamp startTime; // <-- changed from String to Timestamp
  final Timestamp endTime; // <-- changed from String to Timestamp
  final double inFrame;
  final int appSwitches;
  final int mcqsCompleted;
  final int pagesRead;
  final bool targetMet;
  final String reasonForAbsence;
  final String reasonForAppSwitch;

  StudySession({
    required this.id,
    required this.studentId,
    this.timetableEntryId,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.inFrame,
    required this.appSwitches,
    required this.mcqsCompleted,
    required this.pagesRead,
    required this.targetMet,
    required this.reasonForAbsence,
    required this.reasonForAppSwitch,
  });

  factory StudySession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StudySession(
      id: doc.id,
      studentId: data['studentId'],
      timetableEntryId: data['timetableEntryId'],
      subject: data['subject'],
      startTime: data['startTime'], // Firestore Timestamp
      endTime: data['endTime'], // Firestore Timestamp
      inFrame: data['inFrame'],
      appSwitches: data['appSwitches'],
      mcqsCompleted: data['mcqsCompleted'],
      pagesRead: data['pagesRead'],
      targetMet: data['targetMet'],
      reasonForAbsence: data['reasonForAbsence'],
      reasonForAppSwitch: data['reasonForAppSwitch'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "studentId": studentId,
      "timetableEntryId": timetableEntryId,
      "subject": subject,
      "startTime": startTime, // Timestamp value
      "endTime": endTime, // Timestamp value
      "inFrame": inFrame,
      "appSwitches": appSwitches,
      "mcqsCompleted": mcqsCompleted,
      "pagesRead": pagesRead,
      "targetMet": targetMet,
      "reasonForAbsence": reasonForAbsence,
      "reasonForAppSwitch": reasonForAppSwitch,
    };
  }
}
