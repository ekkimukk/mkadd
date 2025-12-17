import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'color_picker_dialog.dart';
import 'toolbar_controller.dart';
import 'package:miro_prototype/features/whiteboard/presentation/providers/tool_state_provider.dart';

class ColorSelector extends ConsumerWidget {
  final bool isDark;

  const ColorSelector({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColor = ref.watch(
      toolStateProvider.select((state) => state.brushColor),
    );

    return Row(
      children: [
        Text(
          'Цвет:',
          style: TextStyle(
            fontSize: 12, // Уменьшаем размер шрифта
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: currentColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: getBorderColor(context),
              width: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 18,
          onPressed: () => _showColorPicker(context, ref, isDark),
          icon: Icon(
            Icons.palette,
            size: 20, // Уменьшаем иконку
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(isDark: isDark),
    );
  }
}