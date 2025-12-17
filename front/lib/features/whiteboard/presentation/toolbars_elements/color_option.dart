import 'package:flutter/material.dart';
import 'toolbar_controller.dart';

class ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const ColorOption({
    super.key,
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
        ),
      ),
    );
  }
}