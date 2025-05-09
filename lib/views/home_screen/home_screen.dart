import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_monitoring_app/views/main_layout_screen.dart';

import '../../components/efficiency_indicator.dart';
import '../../components/timetable_prompt_card.dart';
import '../../models/student.dart';
import '../../models/studysession.dart';
import '../../models/timetable.dart';
import '../../resources/student_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<List<TimetableEntry>> getTodaySessions(String studentId) async {
    final timetableSnap = await FirebaseFirestore.instance
        .collection('timetables')
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();

    if (timetableSnap.docs.isEmpty) return [];

    final timetable = Timetable.fromFirestore(timetableSnap.docs.first);
    final today = DateTime.now();

    return timetable.entries.where((entry) {
      final entryDate = entry.startTime;
      final sameDay = entryDate.year == today.year &&
          entryDate.month == today.month &&
          entryDate.day == today.day;
      return sameDay || entry.repeatWeekly;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<Student?> getStudentFromCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        return Student.fromFirestore(doc);
      }
    } catch (e) {
      print('Error fetching student from Firestore: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student Monitoring App",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, studentProvider, _) {
          Student? student = studentProvider.getStudent;

          if (student == null) {
            // Show a loader or a future fetch
            return FutureBuilder<Student?>(
              future: getStudentFromCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                student = snapshot.data;
                final studentName = student?.name ?? "Guest";
                final studentId = student?.id.trim() ?? "";

                return Center(
                  child: Text("Welcome, $studentName (ID: $studentId)"),
                );
              },
            );
          }

          final studentName = student.name;
          final studentId = student.id.trim();

          return FutureBuilder<List<TimetableEntry>>(
            future: getTodaySessions(studentId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final todaySessions = snapshot.data!;
              final today = DateTime.now();

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('study_sessions')
                    .where('studentId'.trim(), isEqualTo: studentId.trim())
                    .get(),
                builder: (context, studySnapshot) {
                  if (!studySnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allStudySessions = studySnapshot.data!.docs
                      .map((doc) => StudySession.fromFirestore(doc))
                      .toList();

                  // Filter today's study sessions
                  final todayStudySessions = allStudySessions.where((session) {
                    final date = session.startTime.toDate();
                    return date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;
                  }).toList();

                  final sessionCount = todayStudySessions.length;
                  print(sessionCount);

                  // Efficiency: Average inFrame %
                  double averageInFrame = todayStudySessions.isEmpty
                      ? 70.0
                      : todayStudySessions
                              .map((s) => s.inFrame)
                              .reduce((a, b) => a + b) /
                          todayStudySessions.length;
                  print(averageInFrame);
                  // Target Time (in hours): from timetable entries
                  double totalMinutes = 0;
                  for (var entry in todaySessions) {
                    totalMinutes +=
                        entry.endTime.difference(entry.startTime).inMinutes;
                  }
                  final totalHours =
                      (totalMinutes / 60).round(); // rounded to nearest hour

                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, $studentName",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Updated Efficiency + Target Card
                          Container(
                            width: double.infinity,
                            height: h / 3.5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromRGBO(137, 204, 205, .21),
                            ),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Today's",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    sessionCount == 0
                                        ? SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: const Text(
                                              "No sessions completed today",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                          )
                                        : EfficiencyIndicator(
                                            efficiency: double.parse(
                                                (averageInFrame * 100)
                                                    .toStringAsFixed(2))),
                                    Container(
                                      height: h / 7,
                                      width: 1,
                                      color: Colors.grey,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "$totalHours",
                                              style: const TextStyle(
                                                fontSize: 80,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            const Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 24),
                                              child: Text(
                                                "hrs",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Text(
                                          "Target",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // If no sessions in timetable
                          if (todaySessions.isEmpty)
                            TimetablePromptCard(studentId: studentId),

                          // Else list session cards
                          if (todaySessions.isNotEmpty)
                            ...todaySessions.map(
                              (entry) => SessionCard(
                                entry: entry,
                                studentId: studentId,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  final TimetableEntry entry;
  final String studentId;

  const SessionCard({super.key, required this.entry, required this.studentId});

  Future<bool> isSessionDone() async {
    final snap = await FirebaseFirestore.instance
        .collection('study_sessions')
        .where('studentId', isEqualTo: studentId)
        .where('timetableEntryId', isEqualTo: entry.entryId)
        .get();

    return snap.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat =
        "${TimeOfDay.fromDateTime(entry.startTime).format(context)} - ${TimeOfDay.fromDateTime(entry.endTime).format(context)}";

    return FutureBuilder<bool>(
      future: isSessionDone(),
      builder: (context, snapshot) {
        final isDone = snapshot.data ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isDone
              ? const Color.fromRGBO(218, 234, 248, 1)
              : const Color.fromRGBO(182, 216, 226, 1),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.27,
                  child: Text(
                    "${entry.title} - ${entry.subject}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                const SizedBox(
                  width: 1,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Text(
                    timeFormat,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                ElevatedButton(
                  onPressed: isDone
                      ? null
                      : () {
                          // print("Start pressed for ${entry.title}");
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainLayoutScreen(
                                initialIndex:
                                    3, // This will set the initial index of your screen
                              ),
                            ),
                            (route) =>
                                false, // Removes all the previous routes until the new one
                          );
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isDone
                          ? const Color.fromRGBO(103, 158, 48, 0.83)
                          : const Color.fromARGB(255, 248, 183, 86),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                  child: Text(
                    isDone ? "Done" : "Start",
                    style: isDone
                        ? const TextStyle(fontSize: 12, color: Colors.white)
                        : const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
