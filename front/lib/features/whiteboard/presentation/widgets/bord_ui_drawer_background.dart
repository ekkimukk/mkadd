import 'package:flutter/material.dart';

class UiDrawerBackground extends StatelessWidget {
  final bool isDark;

  const UiDrawerBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: isDark ? const Alignment(0, -0.7) : const Alignment(0, 0.7),
          radius: 1.3,
          colors: isDark
              ? [
            Colors.blueAccent.shade100.withOpacity(0.9),
            Colors.transparent,
          ]
              : [
            Colors.lightBlueAccent.shade200.withOpacity(0.9),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
