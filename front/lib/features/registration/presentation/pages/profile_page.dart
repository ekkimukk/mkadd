import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/providers/auth_provider.dart';
import 'package:miro_prototype/services/board_service.dart';

import '../widgets_profile/profile_top_bar.dart';
import '../widgets_profile/boards_grid.dart';
import '../widgets_profile/board_card.dart';
import '../widgets_profile/new_board_card.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  List<Map<String, dynamic>> boards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadBoards(); // ← Загружаем до анимации

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _offset = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  Future<void> _loadBoards() async {
    final token = ref.read(authProvider).token;
    if (token == null) {
      // Не должен происходить, но на всякий
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final loaded = await BoardService.fetchAllBoards(token);
    setState(() {
      boards = loaded;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildBoardCards(bool isDark) {
    final cards = [
      const NewBoardCard(),
      ...boards.map((b) {
        // Защита от null
        final id = b['ID']?.toString();
        final name = b['title']?.toString() ?? 'Без названия';
        if (id == null) return const SizedBox();
        return BoardCard(id: id, name: name);
      }).toList(),
    ];

    if (_isLoading) {
      cards.add(const Center(child: CircularProgressIndicator()));
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? Colors.black
          : Colors.grey.shade100.withOpacity(0.6),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const ProfileTopBar(),
          const SizedBox(height: 10),
          Text(
            "Мои доски",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BoardsGrid(
              opacity: _opacity,
              offset: _offset,
              children: _buildBoardCards(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
