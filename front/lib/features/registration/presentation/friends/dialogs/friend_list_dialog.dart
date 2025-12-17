import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/providers/friend_provider.dart';
import '../friend_model.dart';

class FriendListDialog extends ConsumerWidget {
  const FriendListDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // friends provider state contains current friends (mock)
    final friends = ref.watch(friendProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.blue.shade900.withOpacity(0.4) : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Text("Мои друзья", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: () => Navigator.pop(context),
              )
            ]),
            const SizedBox(height: 6),

            if (friends.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text("У вас пока нет друзей", style: TextStyle(color: textColor.withOpacity(0.7))),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: friends.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final Friend f = friends[idx];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: f.isOnline ? Colors.green : Colors.grey,
                        child: Text(f.username.isNotEmpty ? f.username[0] : "U"),
                      ),
                      title: Text(f.username, style: TextStyle(color: textColor)),
                      subtitle: f.isPendingIncoming
                          ? Text("Хочет добавить вас", style: TextStyle(color: Colors.orange.shade200))
                          : f.isPendingOutgoing
                          ? Text("Ожидает подтверждения", style: TextStyle(color: textColor.withOpacity(0.6)))
                          : Text(f.isOnline ? "Онлайн" : "Оффлайн", style: TextStyle(color: textColor.withOpacity(0.6))),
                      trailing: _actionsForFriend(ref, f, textColor),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),
            Align(alignment: Alignment.bottomRight, child: TextButton(onPressed: () => Navigator.pop(context), child: Text("Закрыть", style: TextStyle(color: textColor)))),
          ],
        ),
      ),
    );
  }

  Widget _actionsForFriend(WidgetRef ref, Friend f, Color textColor) {
    // incoming -> accept/decline
    if (f.isPendingIncoming) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        TextButton(onPressed: () => ref.read(friendProvider.notifier).accept(f.username), child: Text("Принять", style: TextStyle(color: textColor))),
        TextButton(onPressed: () => ref.read(friendProvider.notifier).decline(f.username), child: const Text("Отклонить", style: TextStyle(color: Colors.red))),
      ]);
    }

    // outgoing -> cancel (крестик)
    if (f.isPendingOutgoing) {
      return IconButton(onPressed: () => ref.read(friendProvider.notifier).cancelRequest(f.username), icon: const Icon(Icons.close, color: Colors.orange));
    }

    // normal friend - show message/send or nothing
    return const SizedBox.shrink();
  }
}
