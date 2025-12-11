import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors:
              colors ??
              [
                const Color(0xFF1B5E20), // Deep green
                const Color(0xFF2E7D32), // Medium green
                const Color(0xFF00695C), // Teal
                const Color(0xFF00897B), // Light teal
              ],
        ),
      ),
      child: child,
    );
  }
}
