import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/studysession.dart';

class StudyAnalyticsScreen extends StatelessWidget {
  final String studentId;

  const StudyAnalyticsScreen({Key? key, required this.studentId})
      : super(key: key);

  Future<Map<String, dynamic>> fetchStudyData(String studentId) async {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));

    final snapshot = await FirebaseFirestore.instance
        .collection('study_sessions')
        .where('studentId', isEqualTo: studentId)
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(lastWeek))
        .get();

    final sessions =
        snapshot.docs.map((doc) => StudySession.fromFirestore(doc)).toList();

    Duration totalDuration = Duration.zero;
    int targetsMet = 0;
    int appSwitches = 0;
    double averageInFrames = 0;

    for (final session in sessions) {
      totalDuration +=
          session.endTime.toDate().difference(session.startTime.toDate());

      if (session.targetMet == true) {
        targetsMet++;
      }
      if (session.appSwitches > 0) {
        appSwitches += session.appSwitches;
      }
      if (session.inFrame > 0) {
        averageInFrames += session.inFrame;
      }
    }

    return {
      'totalDuration': totalDuration,
      'totalSessions': sessions.length,
      'targetsMet': targetsMet,
      'sessions': sessions,
      'appSwitches': appSwitches,
      'averageInFrames':
          double.parse((averageInFrames / sessions.length).toStringAsFixed(1)),
    };
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Study Analytics',
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: fetchStudyData(studentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No data available."));
            }

            final data = snapshot.data!;
            final Duration totalDuration = data['totalDuration'];
            final int totalSessions = data['totalSessions'];
            final int targetsMet = data['targetsMet'];
            //int totalTargets = data['totalTargets'];
            int appSwitches = data['appSwitches'];
            double averageInFrames = data['averageInFrames'];
            final List<StudySession> sessions = data['sessions'];

            final String formattedTime =
                "${totalDuration.inHours}h ${totalDuration.inMinutes.remainder(60)}m";
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // to prevent scroll inside scroll
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 10,
                      childAspectRatio:
                          4 / 3, // width : height ratio, tweak as needed
                      children: [
                        _buildAnalyticsCard(
                          'Total Study Time',
                          formattedTime,
                          '',
                        ),
                        _buildAnalyticsCard(
                          'Targets Met',
                          '$targetsMet / $totalSessions',
                          '',
                        ),
                        _buildAnalyticsCard(
                          'Average Presence',
                          '$averageInFrames',
                          '',
                        ),
                        _buildAnalyticsCard(
                          'App Switches',
                          '$appSwitches',
                          '',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Statistics',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          Expanded(child: _buildSimplePieChart(context)),
                          Expanded(child: _buildSimplePresenceChart(context)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Recent Study Sessions',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    _buildSessionCard('Physics', '8.5 hours', '90% presence'),
                    _buildSessionCard('Chemistry', '6.2 hours', '90% presence'),
                    _buildSessionCard(
                        'Mathematics', '7.8 hours', '90% presence'),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, String change) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(203, 224, 249, 0.33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color.fromRGBO(28, 27, 31, 1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(30, 58, 138, 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: change.contains('+')
                  ? const Color.fromRGBO(17, 108, 21, 1)
                  : const Color.fromRGBO(241, 42, 37, 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePieChart(BuildContext context) {
    // Define the data for the pie chart
    final List<Map<String, dynamic>> data = [
      {'subject': 'Physics', 'value': 30.0, 'color': Colors.red},
      {'subject': 'Maths', 'value': 25.0, 'color': Colors.green},
      {'subject': 'Chemistry', 'value': 20.0, 'color': Colors.blue},
      {'subject': 'Biology', 'value': 15.0, 'color': Colors.yellow},
      {'subject': 'English', 'value': 10.0, 'color': Colors.purple},
    ];

    return Card(
      elevation: 4,
      color: Color.fromRGBO(235, 247, 248, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: SimplePieChartPainter(data),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: data.map((item) => _buildLegendItem(item)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplePresenceChart(BuildContext context) {
    // Define the data for the presence chart
    final List<Map<String, dynamic>> data = [
      {'label': 'In Frame', 'value': 80.0, 'color': Colors.green},
      {'label': 'Out of Frame', 'value': 20.0, 'color': Colors.red},
    ];

    return Card(
      elevation: 4,
      color: Color.fromRGBO(235, 247, 248, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: SimplePieChartPainter(data),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.map((item) => _buildLegendItem(item)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Map<String, dynamic> item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item['color'],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          item['subject'] ?? item['label'] ?? '',
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSessionCard(String subject, String time, String presence) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(193, 202, 255, 0.28),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(subject,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(fontSize: 14)),
              Text(presence,
                  style: const TextStyle(fontSize: 14, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom pie chart painter to avoid fl_chart dependency issues
class SimplePieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  SimplePieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        size.width < size.height ? size.width / 2 - 16 : size.height / 2 - 16;

    // Calculate the total value
    double total = 0;
    for (var item in data) {
      total += item['value'] as double;
    }

    // Draw the pie sections
    double startAngle = 0;
    for (var item in data) {
      final sweepAngle = 2 * 3.14159 * (item['value'] as double) / total;
      final paint = Paint()
        ..color = item['color'] as Color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw a white circle in the center for a donut effect
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
