// import 'package:face_auth_tracking/model/user_model.dart';
// import 'package:flutter/material.dart';

// class AuthenticatedUserScreen extends StatelessWidget {
//   final UserModel user;
//   const AuthenticatedUserScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("Authenticated User"),
//         elevation: 0,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "Hey ${user.name} !",
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 26,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "You are Successfully Authenticated !",
//               style: TextStyle(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:student_monitoring_app/models/student.dart';
import 'package:student_monitoring_app/views/study_session_screens/face_tracking_screen.dart';

class AuthenticatedUserScreen extends StatelessWidget {
  final Student user;
  const AuthenticatedUserScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Authenticated User"),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hey ${user.name} !",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You are Successfully Authenticated !",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FaceTrackingScreen(user: user),
                  ),
                );
              },
              icon: const Icon(Icons.face),
              label: const Text("Start Face Tracking"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}