// lib/features/whiteboard/presentation/widgets/toolbar/toolbar_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/features/whiteboard/presentation/providers/tool_state_provider.dart';

// Общие константы
const kToolbarButtonSize = 44.0;
const kToolbarSpacing = 8.0;
const kSectionSpacing = 24.0;
const kDialogBorderRadius = 24.0;
const kColorOptionSize = 36.0;
const kStrokePreviewWidth = 40.0;

// Общие функции
List<Color> getBasicColors() => [
  Colors.black,
  Colors.blue.shade700,
  Colors.red.shade600,
  Colors.green.shade700,
  Colors.purple.shade600,
  Colors.orange.shade700,
  Colors.pink.shade500,
  Colors.brown.shade700,
  Colors.grey.shade700,
  Colors.yellow.shade700,
  Colors.cyan.shade700,
  Colors.teal.shade700,
];

// Хелперы для тем
Color getActiveColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.blueAccent : Colors.blue;
}

Color getInactiveColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.white70 : Colors.grey[600]!;
}

Color getBorderColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1);
}

// Riverpod хелперы
void setTool(WidgetRef ref, DrawingTool tool) {
  ref.read(toolStateProvider.notifier).setTool(tool);
}

void setBrushColor(WidgetRef ref, Color color) {
  ref.read(toolStateProvider.notifier).setBrushColor(color);
}

void setStrokeWidth(WidgetRef ref, double width) {
  ref.read(toolStateProvider.notifier).setStrokeWidth(width);
}
