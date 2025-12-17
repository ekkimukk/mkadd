// lib/features/whiteboard/presentation/widgets/toolbar/clear_button.dart
import 'package:flutter/material.dart';
import 'toolbar_controller.dart';

class ClearButton extends StatelessWidget {
  final VoidCallback onClear;

  const ClearButton({super.key, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.redAccent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: 'Очистить доску',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onClear,
          child: Container(
            width: kToolbarButtonSize,
            height: kToolbarButtonSize,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.delete_outline,
              color: iconColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}