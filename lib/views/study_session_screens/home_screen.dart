import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_monitoring_app/views/study_session_screens/authenticate_screen.dart';
import 'package:student_monitoring_app/views/study_session_screens/register_screen.dart';

import '../../resources/student_provider.dart';

class StudySessionHomeScreen extends StatelessWidget {
  const StudySessionHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.getStudent;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Authentication"),
      ),
      body: studentProvider.isDataLoaded
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: student != null
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    RegisterScreen(student: student),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Register User'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AuthenticateScreen(),
                        ),
                      );
                    },
                    child: const Text('Authenticate User'),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.30,
                            child: Text(
                              "If you haven’t registered your face yet, start by tapping the “Register” button and capture your photo in a well-lit environment. Once registered, you can authenticate yourself and begin a study session. During the session, your camera stream will monitor your presence in the frame and track app switches. When you’re done, tap “End Session” and complete a short questionnaire to submit your data.",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
