import 'package:flutter/material.dart';

class UiBackground extends StatelessWidget {
  final bool isDark;

  const UiBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: isDark
                ? const Alignment(0, -1)
                : const Alignment(0, 1),
            radius: 1.5,
            colors: isDark
                ? [
              Colors.blue.shade900.withOpacity(0.4),
              Colors.transparent,
            ]
                : [
              Colors.yellow.shade200.withOpacity(0.5),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}