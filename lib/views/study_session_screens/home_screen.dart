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
      body: Center(
        child: studentProvider.isDataLoaded
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AuthenticateScreen(),
                        ),
                      );
                    },
                    child: const Text('Authenticate User'),
                  ),
                ],
              )
            : const CircularProgressIndicator(), // Optional loading state
      ),
    );
  }
}
