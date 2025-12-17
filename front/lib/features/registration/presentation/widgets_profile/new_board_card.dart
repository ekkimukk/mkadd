import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/providers/auth_provider.dart';
import 'package:miro_prototype/services/board_service.dart';
import '../widgets_ui/ui_glass_container.dart';

class NewBoardCard extends ConsumerWidget {
  const NewBoardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UiGlassContainer(
      isDark: isDark,
      child: InkWell(
        onTap: () async {
          // 1. Показываем диалог для ввода названия
          final title = await _showCreateBoardDialog(context);
          if (title == null || title.trim().isEmpty) return;

          final token = ref.read(authProvider).token;
          String? boardId;

          if (token != null) {
            boardId = await BoardService.createBoard(
              token,
              title: title.trim(),
            );
          }

          if (boardId == null) {
            boardId = 'local_${DateTime.now().microsecondsSinceEpoch}';
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Работаем в офлайн-режиме...'),
                duration: Duration(seconds: 3),
              ),
            );
          }

          Navigator.pushReplacementNamed(
            context,
            '/whiteboard',
            arguments: boardId,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 48,
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black87.withOpacity(0.9),
            ),
            const SizedBox(height: 12),
            Text(
              "Создать доску",
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.9)
                    : Colors.black87.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showCreateBoardDialog(BuildContext context) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Название доски'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Введите название',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.of(ctx).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('Создать'),
            ),
          ],
        );
      },
    );
  }
}
