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
    const bool isProd = bool.fromEnvironment('dart.vm.product');

    if (!isProd) {
      debugPrint("Some debug log");
    }
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
          // Wait for data to load
          if (!studentProvider.isDataLoaded) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

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
