import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../friends/dialogs/friend_search_dialog.dart';
import '../friends/dialogs/friend_add_dialog.dart';
import '../friends/dialogs/friend_list_dialog.dart';
import '../widgets_ui/ui_theme_toggle.dart';

class ProfileTopBar extends ConsumerWidget {
  const ProfileTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // friends button widget built inline
          PopupMenuButton<String>(
            color: isDark ? Colors.transparent : Colors.blue.shade900.withOpacity(0.2),
            offset: const Offset(0, 40),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group,
                color: isDark ? Colors.white : Colors.black,
                size: 24,
              ),
            ),
            onSelected: (value) {
              if (value == "search") {
                showDialog(context: context, builder: (_) => const FriendSearchDialog());
              }
              if (value == "add") {
                showDialog(context: context, builder: (_) => const FriendAddDialog());
              }
              if (value == "list") {
                showDialog(context: context, builder: (_) => const FriendListDialog());
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "search", child: Text("Поиск друзей")),
              PopupMenuItem(value: "add", child: Text("Добавить друга")),
              PopupMenuItem(value: "list", child: Text("Мои друзья / запросы")),
            ],
          ),

          const SizedBox(width: 12),

          PopupMenuButton<String>(
            color: isDark ? Colors.transparent : Colors.blue.shade900.withOpacity(0.2),
            offset: const Offset(0, 40),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: isDark ? Colors.white : Colors.black,
                size: 24,
              ),
            ),
            onSelected: (value) {
              if (value == "profile") {
                // TODO profile page
              }
              if (value == "settings") {
                // TODO settings
              }
              if (value == "logout") {
                Navigator.pushReplacementNamed(context, "/");
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "profile", child: Text("Профиль")),
              PopupMenuItem(value: "settings", child: Text("Настройки")),
              PopupMenuItem(value: "logout", child: Text("Выйти", style: TextStyle(color: Colors.red))),
            ],
          ),

          const SizedBox(width: 8),
          const UiThemeToggle(),
        ],
      ),
    );
  }
}
