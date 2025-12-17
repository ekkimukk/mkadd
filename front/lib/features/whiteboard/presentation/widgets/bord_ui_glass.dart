import 'dart:ui';
import 'package:flutter/material.dart';

class UiGlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const UiGlassContainer({
    super.key,
    required this.child,
    required this.isDark,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black87.withOpacity(0.4)
                : Colors.white.withOpacity(0.45),
            border: Border.all(
              width: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.blue.shade200.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
