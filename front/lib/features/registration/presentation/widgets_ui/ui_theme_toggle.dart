import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';
import '../../data/registration_provider.dart';

// ✅ Чистый, переиспользуемый виджет
class UiThemeToggle extends ConsumerWidget {
  const UiThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
          isDark ? Icons.wb_sunny : Icons.nightlight_round,
          color: isDark? Colors.yellow : Colors.blue,
      ),
      onPressed: () {
        final current = ref.read(themeModeProvider);
        ref.read(themeModeProvider.notifier).state =
        current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.15)),
        shape: MaterialStateProperty.all(const CircleBorder()),
      ),
    );
  }
}
