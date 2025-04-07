import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/efficiency_indicator.dart';
import '../../components/timetable_prompt_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student App"),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, studentProvider, _) {
          final student = studentProvider.getStudent;
          final studentName = student?.name ?? "Guest";
          final studentId = student?.id ?? "";

          if (student == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<List<TimetableEntry>>(
            future: getTodaySessions(studentId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final todaySessions = snapshot.data!;

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

                      // Efficiency + Target
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const EfficiencyIndicator(efficiency: 70),
                                Container(
                                  height: h / 7,
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "10",
                                          style: TextStyle(
                                            fontSize: 80,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              0, 0, 0, 24.0),
                                          child: Text(
                                            "hrs",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
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

                      // Show prompt if no timetable
                      if (todaySessions.isEmpty)
                        TimetablePromptCard(studentId: studentId),

                      // Show sessions
                      if (todaySessions.isNotEmpty)
                        ...todaySessions
                            .map((entry) => SessionCard(entry: entry)),
                    ],
                  ),
                ),
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

  const SessionCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final timeFormat = TimeOfDay.fromDateTime(entry.startTime).format(context) +
        " - " +
        TimeOfDay.fromDateTime(entry.endTime).format(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Subject: ${entry.subject}"),
            Text("Session: ${entry.sessionType}"),
            Text("Time: $timeFormat"),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  print("Start pressed for ${entry.title}");
                  // TODO: navigate to session screen or start timer
                },
                child: const Text("Start"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
