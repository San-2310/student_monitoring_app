// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:student_monitoring_app/resources/face_monitoring_service.dart';

// import 'firebase_options.dart';
// import 'resources/student_provider.dart';
// import 'views/auth_screens/login_screen.dart';
// import 'views/main_layout_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider<StudentProvider>(
//           create: (_) => StudentProvider(),
//         ),
//         ChangeNotifierProvider(create: (_) => FaceMonitoringService()),
//       ],
//       child: Consumer<StudentProvider>(
//         builder: (context, studentProvider, _) {
//           if (!studentProvider.isDataLoaded) {
//             return const MaterialApp(
//               home: Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               ),
//             );
//           }

//           return MaterialApp(
//             title: 'Student Monitoring App',
//             debugShowCheckedModeBanner: false,
//             theme: ThemeData(
//               fontFamily: 'Poppins',
//               primarySwatch: Colors.blue,
//             ),
//             home: studentProvider.isAuthenticated
//                 ? const MainLayoutScreen()
//                 : const LoginScreen(),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:student_monitoring_app/resources/face_monitoring_service.dart';

import 'firebase_options.dart';
import 'resources/student_provider.dart';
import 'views/auth_screens/login_screen.dart';
import 'views/main_layout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await deleteDuplicateStudySessions();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StudentProvider>(
          create: (_) => StudentProvider()
            ..refreshStudentFromAuth(), // Auto-fetch student,
        ),
        ChangeNotifierProvider(create: (_) => FaceMonitoringService())
      ],
      child: Consumer<StudentProvider>(
        builder: (context, studentProvider, _) {
          return MaterialApp(
            title: 'Student Monitoring App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Poppins',
              primarySwatch: Colors.blue,
            ),
            home: studentProvider.isAuthenticated
                ? const MainLayoutScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}

Future<void> deleteDuplicateStudySessions() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference sessions = firestore.collection('study_sessions');

  // Target startTime (converted from IST to UTC)
  DateTime start = DateTime.utc(2025, 4, 22, 17, 17, 43); // 10:47:43 PM IST
  DateTime end = start.add(const Duration(seconds: 1)); // 1s range

  final querySnapshot = await sessions
      .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('startTime', isLessThan: Timestamp.fromDate(end))
      .get();

  final docs = querySnapshot.docs;

  if (docs.length <= 1) {
    print("Koi duplicate nahi mila ya sirf ek entry hai.");
    return;
  }

  // Pehla document chhod ke baaki delete karo
  for (int i = 1; i < docs.length; i++) {
    await sessions.doc(docs[i].id).delete();
    print("Deleted: ${docs[i].id}");
  }

  print("Duplicate entries clean ho gayi.");
}
