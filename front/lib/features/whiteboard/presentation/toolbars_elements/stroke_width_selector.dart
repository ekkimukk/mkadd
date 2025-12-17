import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/features/whiteboard/presentation/providers/tool_state_provider.dart';
import 'package:miro_prototype/features/whiteboard/presentation/widgets/bord_ui_glass.dart';
import 'toolbar_controller.dart';

class StrokeWidthSelector extends ConsumerWidget {
  const StrokeWidthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strokeWidth = ref.watch(
      toolStateProvider.select((state) => state.strokeWidth),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          "Толщина:",
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),

        const SizedBox(width: 10),

        // Текущее значение толщины
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: getBorderColor(context), width: 1),
          ),
          child: Center(
            child: Text(
              strokeWidth.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        IconButton(
          icon: Icon(
            Icons.tune,
            color: isDark ? Colors.white : Colors.black87,
            size: 22,
          ),
          onPressed: () => _showStrokeWidthPicker(context, ref),
        ),
      ],
    );
  }

  void _showStrokeWidthPicker(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = ref.read(toolStateProvider).strokeWidth;

    final controller = TextEditingController(
      text: current.toStringAsFixed(1).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), ''),
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          // Уменьшаем ширину диалога через insetPadding
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kDialogBorderRadius),
          ),
          child: Container(
            // Фиксируем ширину контейнера
            width: 320,
            child: UiGlassContainer(
              isDark: isDark,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              borderRadius: BorderRadius.circular(kDialogBorderRadius),
              child: _StrokeWidthSliderContent(
                controller: controller,
                isDark: isDark,
                ref: ref,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StrokeWidthSliderContent extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final WidgetRef ref;

  const _StrokeWidthSliderContent({
    required this.controller,
    required this.isDark,
    required this.ref,
  });

  @override
  State<_StrokeWidthSliderContent> createState() =>
      _StrokeWidthSliderContentState();
}

class _StrokeWidthSliderContentState extends State<_StrokeWidthSliderContent> {
  double sliderValue = 3.0;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    sliderValue = widget.ref.read(toolStateProvider).strokeWidth;
    widget.controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateInput);
    super.dispose();
  }

  void _validateInput() {
    final text = widget.controller.text;

    if (text.contains(RegExp(r'[^\d\.]'))) {
      widget.controller.value = TextEditingValue(
        text: text.replaceAll(RegExp(r'[^\d\.]'), ''),
        selection: widget.controller.selection,
      );
    }

    final parts = text.split('.');
    if (parts.length > 2) {
      widget.controller.value = TextEditingValue(
        text: parts[0] + '.' + parts[1],
        selection: TextSelection.collapsed(offset: parts[0].length + 1 + parts[1].length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Толщина линии",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: widget.isDark ? Colors.white : Colors.black54,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Уменьшаем высоту слайдера
        SizedBox(
          height: 44,
          child: Slider(
            min: 1,
            max: 40,
            divisions: 39,
            value: sliderValue,
            label: sliderValue.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                sliderValue = value;
                widget.controller.text = value.toStringAsFixed(1).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
                _errorText = null;
                setStrokeWidth(widget.ref, value);
              });
            },
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.isEmpty) return newValue;

              if (newValue.text.startsWith('.')) {
                return TextEditingValue(
                  text: '0${newValue.text}',
                  selection: TextSelection.collapsed(offset: newValue.text.length + 1),
                );
              }

              final value = double.tryParse(newValue.text) ?? 0.0;
              if (value > 40.0) {
                return TextEditingValue(
                  text: '40.0',
                  selection: TextSelection.collapsed(offset: 4),
                );
              }

              if (newValue.text.length > 1 &&
                  newValue.text.startsWith('0') &&
                  !newValue.text.startsWith('0.') &&
                  !newValue.text.startsWith('0,')) {
                return TextEditingValue(
                  text: newValue.text.substring(1),
                  selection: TextSelection.collapsed(offset: newValue.text.length - 1),
                );
              }

              return newValue;
            }),
          ],
          decoration: InputDecoration(
            labelText: "Введите толщину вручную",
            labelStyle: TextStyle(
              color: widget.isDark ? Colors.white70 : Colors.grey[700],
            ),
            suffixText: 'мм',
            suffixStyle: TextStyle(
              color: widget.isDark ? Colors.blueAccent : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.isDark ? Colors.white24 : Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: getActiveColor(context), width: 2),
            ),
            errorText: _errorText,
          ),
          onChanged: (text) {
            setState(() => _errorText = null);

            if (text.isEmpty) {
              setStrokeWidth(widget.ref, 1.0);
              return;
            }

            final value = double.tryParse(text) ?? 0.0;

            if (value <= 0) {
              setState(() => _errorText = 'Значение должно быть больше 0');
              return;
            }

            setState(() {
              sliderValue = value;
            });

            setStrokeWidth(widget.ref, value);
          },
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}