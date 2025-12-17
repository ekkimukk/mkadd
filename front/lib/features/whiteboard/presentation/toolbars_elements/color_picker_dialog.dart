import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'color_option.dart';
import 'toolbar_controller.dart';
import 'package:miro_prototype/features/whiteboard/presentation/providers/tool_state_provider.dart';
import 'package:miro_prototype/features/whiteboard/presentation/widgets/bord_ui_glass.dart';

class ColorPickerDialog extends ConsumerWidget {
  final bool isDark;

  const ColorPickerDialog({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColor = ref.watch(
      toolStateProvider.select((state) => state.brushColor),
    );

    return Dialog(
      // Увеличиваем ширину диалога
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      // Увеличиваем максимальную ширину
      constraints: const BoxConstraints(maxWidth: 420),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDialogBorderRadius),
      ),
      child: Container(
        // Увеличиваем ширину контейнера до 380px
        width: 380,
        child: UiGlassContainer(
          isDark: isDark,
          borderRadius: BorderRadius.circular(kDialogBorderRadius),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildColorPicker(ref, currentColor),
              const SizedBox(height: 16),
              _buildBasicColorsSection(ref, currentColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Выберите цвет',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            size: 24,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black54,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildColorPicker(WidgetRef ref, Color currentColor) {
    return SizedBox(
      // Увеличиваем высоту для лучшего отображения
      height: 265,
      child: ColorPicker(
        pickerColor: currentColor,
        onColorChanged: (color) => setBrushColor(ref, color),
        showLabel: false,
        pickerAreaHeightPercent: 0.5,
        // Увеличиваем ширину пикера до 360px
        colorPickerWidth: 360,
        enableAlpha: false,
        displayThumbColor: true,
        labelTypes: const [],
        portraitOnly: true,
      ),
    );
  }

  Widget _buildBasicColorsSection(
      WidgetRef ref,
      Color currentColor,
      bool isDark,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Основные цвета',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in getBasicColors())
              SizedBox(
                width: 36,
                height: 36,
                child: ColorOption(
                  color: color,
                  isSelected: color.value == currentColor.value,
                  isDark: isDark,
                  onTap: () => setBrushColor(ref, color),
                ),
              ),
          ],
        ),
      ],
    );
  }
}