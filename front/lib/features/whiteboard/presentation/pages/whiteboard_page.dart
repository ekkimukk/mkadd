// lib/features/whiteboard/presentation/pages/whiteboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

import 'package:miro_prototype/features/whiteboard/presentation/widgets/bord_ui_glass.dart';
import 'package:miro_prototype/features/whiteboard/presentation/widgets/bord_ui_background.dart';
import 'package:miro_prototype/features/whiteboard/presentation/widgets/bord_ui_drawer_background.dart';
import 'package:miro_prototype/core/widgets/animated_drawer_scaffold.dart';

import '../widgets/whiteboard_view.dart';
import '../toolbars_elements/whiteboard_toolbar.dart';
import '../../../../whiteboard_providers.dart';
import 'package:miro_prototype/features/registration/presentation/widgets_ui/ui_theme_toggle.dart';

class WhiteboardPage extends ConsumerStatefulWidget {
  final String? boardId;
  const WhiteboardPage({super.key, this.boardId});

  @override
  ConsumerState<WhiteboardPage> createState() => _WhiteboardPageState();
}

class _WhiteboardPageState extends ConsumerState<WhiteboardPage> {
  // 🔑 Ключ для управления кастомным дровером
  final GlobalKey<AnimatedDrawerScaffoldState> _drawerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // ✅ Правильно: ref — это поле класса
    final boardId =
        widget.boardId ?? 'local_${DateTime.now().microsecondsSinceEpoch}';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Используем ref здесь
    final ws = ref.watch(websocketServiceProvider(boardId));
    final camera = ref.watch(cameraProvider(boardId));
    final elements = ref.watch(elementsProvider(boardId));

    return AnimatedDrawerScaffold(
      key: _drawerKey,
      drawer: _buildDrawer(context, isDark),
      content: Stack(
        children: [
          UiBackground(isDark: isDark),
          WhiteboardView(boardId: boardId),
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: WhiteboardToolbar(
                onClear: () {
                  ref.read(elementsProvider(boardId).notifier).clear();
                  ref.read(websocketServiceProvider(boardId)).sendMessage({
                    'type': 'clear',
                    'data': {},
                    'timestamp': DateTime.now().toIso8601String(),
                  });
                },
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.black87),
              onPressed: () => _drawerKey.currentState?.toggleDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: SizedBox(
        width: 260,
        child: Stack(
          children: [
            Positioned.fill(child: UiDrawerBackground(isDark: isDark)),
            Positioned.fill(
              child: UiGlassContainer(
                isDark: isDark,
                child: _drawerContent(context, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerContent(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => _drawerKey.currentState?.toggleDrawer(),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.person,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            "Профиль",
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          onTap: () {
            _drawerKey.currentState?.toggleDrawer();
            Navigator.pushNamed(context, "/profile");
          },
        ),
        ListTile(
          leading: Icon(
            Icons.group,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            "Друзья",
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          onTap: () {
            _drawerKey.currentState?.toggleDrawer();
          },
        ),
        ListTile(
          leading: Icon(
            Icons.dashboard,
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: Text(
            "Мои доски",
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          onTap: () {
            _drawerKey.currentState?.toggleDrawer();
            Navigator.pushReplacementNamed(context, "/profile");
          },
        ),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: UiThemeToggle(),
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
          title: const Text("Выйти", style: TextStyle(color: Colors.redAccent)),
          onTap: () {
            _drawerKey.currentState?.toggleDrawer();
            Navigator.pushReplacementNamed(context, "/");
          },
        ),
      ],
    );
  }
}
