import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/providers/friend_provider.dart';

class FriendAddDialog extends ConsumerStatefulWidget {
  const FriendAddDialog({super.key});

  @override
  ConsumerState<FriendAddDialog> createState() => _FriendAddDialogState();
}

class _FriendAddDialogState extends ConsumerState<FriendAddDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.blue.shade900.withOpacity(0.45)
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Добавить друга",
                style: TextStyle(color: textColor, fontSize: 18)),
            const SizedBox(height: 14),

            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Никнейм",
                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                border: const OutlineInputBorder(),
              ),
              style: TextStyle(color: textColor),
            ),

            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _statusMessage!,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Отмена", style: TextStyle(color: textColor))),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final nickname = _controller.text.trim();

                    if (nickname.isEmpty) {
                      setState(() => _statusMessage = "Введите никнейм");
                      return;
                    }

                    final result = ref
                        .read(friendProvider.notifier)
                        .sendRequest(nickname);

                    /*if (result == null) {
                      setState(() => _statusMessage = "Пользователь не найден");
                    } else {
                      setState(() => _statusMessage = "Запрос отправлен");
                    }*/
                  },
                  child: const Text("Добавить"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
