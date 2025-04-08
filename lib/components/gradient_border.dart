import 'package:flutter/material.dart';

class GradientBorder extends StatelessWidget {
  final Widget child;

  const GradientBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(20, 184, 129, 1),
            Color.fromRGBO(222, 249, 196, 1),
            Color.fromRGBO(222, 249, 196, 1),
            Color.fromRGBO(20, 184, 129, 1),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2), // Border thickness
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            child: child,
          ),
        ),
      ),
    );
  }
}
