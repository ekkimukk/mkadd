import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../friends/dialogs/friend_search_dialog.dart';
import '../friends/dialogs/friend_add_dialog.dart';
import '../friends/dialogs/friend_list_dialog.dart';

class FriendsButton extends ConsumerWidget {
  const FriendsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<String>(
      color: isDark ? Colors.transparent : Colors.blue.shade900.withOpacity(0.2),
      offset: const Offset(0, 40),
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(Icons.group, color: isDark ? Colors.white : Colors.black, size: 24),
      ),
      onSelected: (value) {
        if (value == "search") showDialog(context: context, builder: (_) => const FriendSearchDialog());
        if (value == "add") showDialog(context: context, builder: (_) => const FriendAddDialog());
        if (value == "list") showDialog(context: context, builder: (_) => const FriendListDialog());
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: "search", child: Text("Поиск друзей")),
        PopupMenuItem(value: "add", child: Text("Добавить друга")),
        PopupMenuItem(value: "list", child: Text("Мои друзья / запросы")),
      ],
    );
  }
}
