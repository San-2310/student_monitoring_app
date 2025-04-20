import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_monitoring_app/views/main_layout_screen.dart';

import '../../components/app_colors.dart';

class QuestionnaireScreen extends StatefulWidget {
  final String studentId;
  final Timestamp startTime;
  final Timestamp endTime;
  final double inFrame;
  final int appSwitches;

  const QuestionnaireScreen({
    Key? key,
    required this.studentId,
    required this.startTime,
    required this.endTime,
    required this.inFrame,
    required this.appSwitches,
  }) : super(key: key);

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  String? selectedTimetableEntryId;
  List<Map<String, dynamic>> todayEntries = [];

  final TextEditingController mcqController = TextEditingController();
  final TextEditingController pagesController = TextEditingController();
  final TextEditingController reasonAbsenceController = TextEditingController();
  final TextEditingController reasonAppSwitchController =
      TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  bool targetMet = false;

  @override
  void initState() {
    super.initState();
    _loadTodayTimetableEntries();
  }

  Future<void> _loadTodayTimetableEntries() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    print(widget.studentId);
    final snapshot = await FirebaseFirestore.instance
        .collection('timetables')
        .where('studentId'.trim(), isEqualTo: widget.studentId.trim())
        .get();

    // print(snapshot.docs[1]);
    List<Map<String, dynamic>> entries = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timetableEntries = (data['entries'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .where((e) =>
              !(e['done'] ?? false) &&
              (e['startTime'] as Timestamp).toDate().isAfter(startOfDay) &&
              (e['startTime'] as Timestamp).toDate().isBefore(endOfDay))
          .toList();

      entries.addAll(timetableEntries);
    }

    setState(() {
      todayEntries = entries;
    });
  }

  Future<void> _submitSession() async {
    final session = {
      "studentId": widget.studentId.trim(),
      "timetableEntryId": selectedTimetableEntryId,
      "title": titleController.text.trim(),
      "subject": subjectController.text.trim(),
      "startTime": widget.startTime,
      "endTime": widget.endTime,
      "inFrame": widget.inFrame,
      "appSwitches": widget.appSwitches,
      "mcqsCompleted": int.tryParse(mcqController.text) ?? 0,
      "pagesRead": int.tryParse(pagesController.text) ?? 0,
      "targetMet": targetMet,
      "reasonForAbsence": reasonAbsenceController.text.trim(),
      "reasonForAppSwitch": reasonAppSwitchController.text.trim(),
    };

    await FirebaseFirestore.instance.collection('study_sessions').add(session);

    if (selectedTimetableEntryId != null) {
      // Mark the timetable entry as done
      final snapshot = await FirebaseFirestore.instance
          .collection('timetables')
          .where('studentId'.trim(), isEqualTo: widget.studentId.trim())
          .get();

      for (var doc in snapshot.docs) {
        final entries = (doc['entries'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        final index =
            entries.indexWhere((e) => e['entryId'] == selectedTimetableEntryId);
        if (index != -1) {
          entries[index]['done'] = true;

          await FirebaseFirestore.instance
              .collection('timetables')
              .doc(doc.id)
              .update({'entries': entries});
          break;
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Study session recorded!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainLayoutScreen(
            initialIndex: 0,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Post-Session Questionnaire",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (todayEntries.isNotEmpty) ...[
              const Text("Select associated timetable entry:"),
              DropdownButton<String>(
                value: selectedTimetableEntryId,
                hint: const Text("Select Timetable Entry"),
                isExpanded: true,
                items: [
                  ...todayEntries.map<DropdownMenuItem<String>>((entry) {
                    return DropdownMenuItem<String>(
                      value: entry['entryId'],
                      child: Text("${entry['subject']} - ${entry['title']}"),
                    );
                  }).toList(),
                  const DropdownMenuItem<String>(
                    value: 'other',
                    child: Text("Other"),
                  ),
                ],
                onChanged: (value) {
                  if (value == 'other') {
                    setState(() {
                      selectedTimetableEntryId = null;
                      subjectController.text = '';
                      titleController.text = '';
                    });
                  } else {
                    final selectedEntry = todayEntries.firstWhere(
                      (entry) => entry['entryId'] == value,
                      orElse: () => {},
                    );

                    setState(() {
                      selectedTimetableEntryId = value!;
                      subjectController.text = selectedEntry['subject'] ?? '';
                      titleController.text = selectedEntry['title'] ?? '';
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
            Text("Subject:"),
            TextField(
              controller: subjectController,
              enabled: selectedTimetableEntryId ==
                  null, // editable only if not selected
              decoration: InputDecoration(
                hintText: "Enter Subject",
                hintStyle: const TextStyle(color: AppColors.mediumGray),
                filled: true,
                fillColor: const Color.fromARGB(204, 240, 247, 255),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(20, 184, 129, 1), width: 1),
                ),
              ),
              style: const TextStyle(color: AppColors.mediumGray),
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Title:"),
            TextField(
              controller: titleController,
              enabled: selectedTimetableEntryId ==
                  null, // editable only if not selected
              decoration: InputDecoration(
                hintText: "Enter Title",
                hintStyle: const TextStyle(color: AppColors.mediumGray),
                filled: true,
                fillColor: const Color.fromARGB(204, 240, 247, 255),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(20, 184, 129, 1), width: 1),
                ),
              ),
              style: const TextStyle(color: AppColors.mediumGray),
            ),
            const SizedBox(
              height: 10,
            ),
            Text("MCQs completed:"),
            TextField(
              controller: mcqController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter No. of MCQs completed",
                hintStyle: const TextStyle(color: AppColors.mediumGray),
                filled: true,
                fillColor: const Color.fromARGB(204, 240, 247, 255),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(20, 184, 129, 1), width: 1),
                ),
              ),
              style: const TextStyle(color: AppColors.mediumGray),

              //const InputDecoration(labelText: "MCQs completed"),
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Pages read:"),
            TextField(
              controller: pagesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter no. of pages read",
                hintStyle: const TextStyle(color: AppColors.mediumGray),
                filled: true,
                fillColor: const Color.fromARGB(204, 240, 247, 255),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(20, 184, 129, 1), width: 1),
                ),
              ),
              style: const TextStyle(color: AppColors.mediumGray),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Target Met: "),
                Checkbox(
                  value: targetMet,
                  onChanged: (val) {
                    setState(() {
                      targetMet = val ?? false;
                    });
                  },
                )
              ],
            ),
            TextField(
              controller: reasonAbsenceController,
              decoration: const InputDecoration(
                labelText: "Reason for absence (if any)",
              ),
            ),
            TextField(
              controller: reasonAppSwitchController,
              decoration: const InputDecoration(
                labelText: "Reason for app switches (if any)",
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _submitSession,
              child: Container(
                width: 240,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [
                    Color.fromRGBO(91, 202, 191, 1),
                    Color.fromRGBO(222, 249, 196, 1)
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: _submitSession,
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(vertical: 14),
            //     backgroundColor: Colors.blueAccent,
            //   ),
            //   child: const Text("Submit", style: TextStyle(fontSize: 16)),
            // ),
          ],
        ),
      ),
    );
  }
}
