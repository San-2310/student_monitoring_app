import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateDummyStudySessions() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  const String studentId = "KBGvLNpcerfzAkIXkmZlL6l42T92";

  for (int i = 0; i < 3; i++) {
    // Generate random dates between 7 and 14 days ago
    DateTime now = DateTime.now();
    DateTime randomStart = now.subtract(Duration(
      days: 7 + (i * 2), // 7, 9, 11 days ago
      hours: 2,
    ));
    DateTime randomEnd = randomStart.add(const Duration(hours: 1, minutes: 30));

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

  print("✅ 3 dummy study sessions (7–14 days ago) added.");
}
