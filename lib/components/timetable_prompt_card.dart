import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_monitoring_app/views/main_layout_screen.dart';

class TimetablePromptCard extends StatelessWidget {
  final String studentId;

  const TimetablePromptCard({super.key, required this.studentId});

  Future<bool> hasTimetable() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('timetables')
        .doc(studentId)
        .get();

    return docSnapshot.exists && (docSnapshot.data()?['days'] != null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: hasTimetable(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text('Error loading timetable.');
        }

        final timetableExists = snapshot.data ?? false;

        if (timetableExists) {
          return const SizedBox
              .shrink(); // Or return your actual timetable widget here
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 241, 245, 255),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 68, 202, 255)),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: Colors.blue, size: 40),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No Timetable Found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Create your weekly timetable to manage your sessions better.",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainLayoutScreen(
                        initialIndex: 2,
                      ),
                    ),
                  );
                },
                child: const Text("Create"),
              )
            ],
          ),
        );
      },
    );
  }
}
