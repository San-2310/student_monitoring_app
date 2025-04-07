import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateDummyStudySessions() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String studentId = "KBGvLNpcerfzAkIXkmZlL6l42T92";

  for (int i = 0; i < 3; i++) {
    // Generate random start and end times within the last week
    DateTime now = DateTime.now();
    DateTime randomStart = now.subtract(Duration(
      days: i * 2 + 1,
      hours: 2,
    ));
    DateTime randomEnd = randomStart.add(Duration(hours: 1, minutes: 30));

    final session = {
      "studentId": studentId,
      "timetableEntryId": null,
      "subject": "Math - Session ${i + 1}",
      "startTime": Timestamp.fromDate(randomStart),
      "endTime": Timestamp.fromDate(randomEnd),
      "inFrame": 0.85 + i * 0.05, // e.g. 0.85, 0.90, 0.95
      "appSwitches": 1 + i,
      "mcqsCompleted": 5 + i * 2,
      "pagesRead": 10 + i * 3,
      "targetMet": i % 2 == 0,
      "reasonForAbsence": "",
      "reasonForAppSwitch": "Checking notes",
    };

    await firestore.collection("study_sessions").add(session);
  }

  print("✅ 3 dummy study sessions added.");
}
