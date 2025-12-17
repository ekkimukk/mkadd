import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miro_prototype/features/whiteboard/presentation/pages/whiteboard_page.dart';
import 'package:miro_prototype/features/registration/presentation/pages/profile_page.dart';
import 'features/registration/presentation/pages/auth_screen.dart';

// Глобальный провайдер темы
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Miro Clone',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF5f9fd2),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFF5f9fd2),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0f0c29),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF0f0c29),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      routes: {
        '/': (context) => const AuthScreen(),
        '/profile': (context) => const ProfilePage(),
        '/whiteboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is String) {
            return WhiteboardPage(boardId: args);
          }
          return const WhiteboardPage(); // fallback
        },
      },
    );
  }
}
