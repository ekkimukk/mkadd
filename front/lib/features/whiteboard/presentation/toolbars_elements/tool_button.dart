// lib/features/whiteboard/presentation/widgets/toolbar/tool_button.dart
import 'package:flutter/material.dart';
import 'toolbar_controller.dart';

class ToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onPressed;

  const ToolButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = getActiveColor(context);
    final inactiveColor = getInactiveColor(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            width: kToolbarButtonSize,
            height: kToolbarButtonSize,
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(
                color: activeColor.withOpacity(0.3),
                width: 1,
              )
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}