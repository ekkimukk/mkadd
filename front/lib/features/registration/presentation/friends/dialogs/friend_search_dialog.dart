import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/providers/friend_provider.dart';
import '../friend_model.dart';

class FriendSearchDialog extends ConsumerStatefulWidget {
  const FriendSearchDialog({super.key});

  @override
  ConsumerState<FriendSearchDialog> createState() =>
      _FriendSearchDialogState();
}

class _FriendSearchDialogState
    extends ConsumerState<FriendSearchDialog> {

  String query = "";

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(friendProvider.notifier).search(query);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.blue.shade900.withOpacity(0.4)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Поиск друзей"),
            const SizedBox(height: 10),

            TextField(
              decoration: const InputDecoration(labelText: "Никнейм..."),
              onChanged: (v) => setState(() => query = v),
            ),

            const SizedBox(height: 10),

            if (query.isNotEmpty)
              if (results.isEmpty)
                Text("Пользователь не найден")
              else
                Column(
                  children: results.map((Friend f) {
                    return ListTile(
                      title: Text(f.username),
                      subtitle: Text(f.isOnline ? "Онлайн" : "Оффлайн"),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          ref
                              .read(friendProvider.notifier)
                              .sendRequest(f.username);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
                ),

            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Закрыть"),
            )
          ],
        ),
      ),
    );
  }
}
