// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:student_monitoring_app/views/study_analytics_screen.dart/study_analytics_screen.dart';
// import 'package:student_monitoring_app/views/study_session_screens/home_screen.dart';
// import 'package:student_monitoring_app/views/timetable_screens/calendar_view.dart';

// import '../resources/student_provider.dart';
// import 'home_screen/home_screen.dart';

// class MainLayoutScreen extends StatefulWidget {
//   const MainLayoutScreen({super.key});

//   @override
//   _MainLayoutScreenState createState() => _MainLayoutScreenState();
// }

// class _MainLayoutScreenState extends State<MainLayoutScreen> {
//   int _selectedIndex = 0;

//   // Function to handle item selection
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final studentProvider = Provider.of<StudentProvider>(context);
//     final student = studentProvider.getStudent;

//     // Show loader while data is being fetched
//     if (!studentProvider.isDataLoaded) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final List<Widget> pages = [
//       const HomeScreen(),
//       StudyAnalyticsScreen(
//           studentId: student?.id ?? ''), // <-- Pass userId here
//       CalendarScreenApp(), // Lifestyle (placeholder)
//       const StudySessionHomeScreen(), // Profile (placeholder)
//     ];

//     return Scaffold(
//       body: pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: const Color.fromRGBO(18, 158, 158, .47),
//         selectedItemColor: const Color.fromRGBO(55, 27, 52, 1),
//         unselectedItemColor: const Color.fromRGBO(205, 208, 227, 1),
//         currentIndex: _selectedIndex,
//         elevation: 10,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.bar_chart),
//             label: 'Analytics',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.punch_clock_sharp),
//             label: 'Timetable',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.video_camera_front),
//             label: 'Session',
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_monitoring_app/views/profile_screen/profile_screen.dart';
import 'package:student_monitoring_app/views/study_analytics_screen.dart/study_analytics_screen.dart';
import 'package:student_monitoring_app/views/study_session_screens/study_session_home_screen.dart';
import 'package:student_monitoring_app/views/timetable_screens/calendar_view.dart';

import '../resources/student_provider.dart';
import 'home_screen/home_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  final int initialIndex;
  const MainLayoutScreen({super.key, this.initialIndex = 0}); // 👈 added

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
    _selectedIndex = widget.initialIndex; // 👈 using the passed value
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _loadStudentData();
  // }

  Future<void> _loadStudentData() async {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    await studentProvider.refreshStudent();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.getStudent;

    // if (!studentProvider.isDataLoaded) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }

    final List<Widget> pages = [
      const HomeScreen(),
      StudyAnalyticsScreen(studentId: student?.id ?? ''),
      const CalendarScreenApp(),
      const StudySessionHomeScreen(),
      const ProfileScreen(), // 👈 Add your ProfileScreen here
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () => _onTabTapped(0),
          backgroundColor: _selectedIndex == 0
              ? const Color.fromARGB(210, 57, 115, 116)
              : const Color.fromARGB(177, 86, 139, 140),
          shape: const CircleBorder(),
          child: Icon(
            Icons.home,
            color: _selectedIndex == 0 ? Colors.black : Colors.white,
            size: 30,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(18, 158, 158, 0.5),
        elevation: 1,
        notchMargin: 6,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 50, // <- Set your desired height here
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton("Analytics", Icons.bar_chart, 1),
              _buildTabButton("Timetable", Icons.punch_clock, 2),
              const SizedBox(width: 40), // For FAB space
              _buildTabButton("Session", Icons.video_camera_front, 3),
              _buildTabButton("Profile", Icons.person, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, int index) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 0), // ← controls top-bottom spacing
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black : Colors.white,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
