import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class EfficiencyIndicator extends StatelessWidget {
  final double efficiency;

  const EfficiencyIndicator({super.key, required this.efficiency});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularPercentIndicator(
        radius: 60,
        lineWidth: 12,
        percent: efficiency / 100,
        animation: true,
        animationDuration: 1200,
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: Colors.teal.shade100,
        progressColor: Colors.teal,
        center: Text(
          "${efficiency.toInt()}%",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        footer: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            "Efficiency",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
