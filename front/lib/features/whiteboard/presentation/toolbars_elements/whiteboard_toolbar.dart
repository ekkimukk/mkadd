// lib/features/whiteboard/presentation/widgets/toolbar/whiteboard_toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/features/whiteboard/presentation/widgets/bord_ui_glass.dart';
import 'clear_button.dart'; // Относительный путь
import 'color_selector.dart'; // Относительный путь
import 'stroke_width_selector.dart'; // Относительный путь
import 'tool_button.dart'; // Относительный путь
import 'toolbar_controller.dart';
import 'package:miro_prototype/features/whiteboard/presentation/providers/tool_state_provider.dart';

class WhiteboardToolbar extends ConsumerWidget {
  final VoidCallback onClear;

  const WhiteboardToolbar({super.key, required this.onClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolState = ref.watch(toolStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UiGlassContainer(
      isDark: isDark,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Инструменты
          ToolButton(
            icon: Icons.pan_tool_outlined,
            tooltip: 'Перемещать',
            isActive: toolState.currentTool == DrawingTool.hand,
            onPressed: () => setTool(ref, DrawingTool.hand),
          ),
          const SizedBox(width: kToolbarSpacing),
          ToolButton(
            icon: Icons.brush_outlined,
            tooltip: 'Кисть',
            isActive: toolState.currentTool == DrawingTool.brush,
            onPressed: () => setTool(ref, DrawingTool.brush),
          ),
          const SizedBox(width: kToolbarSpacing),
          ToolButton(
            icon: Icons.text_fields,
            tooltip: 'Текст',
            isActive: toolState.currentTool == DrawingTool.text,
            onPressed: () => setTool(ref, DrawingTool.text),
          ),
          const SizedBox(width: kToolbarSpacing),
          ToolButton(
            icon: Icons.rectangle_outlined,
            tooltip: 'Фигура',
            isActive: toolState.currentTool == DrawingTool.shape,
            onPressed: () => setTool(ref, DrawingTool.shape),
          ),
          const SizedBox(width: kSectionSpacing),

          // Цвет кисти
          ColorSelector(isDark: isDark),
          const SizedBox(width: 16),

          // Толщина кисти
          const StrokeWidthSelector(),
          const SizedBox(width: kSectionSpacing),

          // Кнопка очистки
          ClearButton(onClear: onClear),
        ],
      ),
    );
  }
}