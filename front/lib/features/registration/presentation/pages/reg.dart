
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const FutureRegisterApp());
}

class FutureRegisterApp extends StatefulWidget {
  const FutureRegisterApp({super.key});

  @override
  State<FutureRegisterApp> createState() => _FutureRegisterAppState();
}

class _FutureRegisterAppState extends State<FutureRegisterApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Register',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF5f9fd2),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFF5f9fd2),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0f0c29),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF0f0c29),
      ),
      home: RegisterScreen(
        onToggleTheme: () {
          setState(() {
            _themeMode =
            _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          });
        },
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const RegisterScreen({super.key, required this.onToggleTheme});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _offsetAnim =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          /// Фон
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: isDark
                      ? const Alignment(0, -1)
                      : const Alignment(0, 1),
                  radius: 1.5,
                  colors: isDark
                      ? [Colors.blue.shade900.withOpacity(0.4), Colors.transparent]
                      : [Colors.yellow.shade200.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),

          /// Форма
          Center(
            child: SlideTransition(
              position: _offsetAnim,
              child: FadeTransition(
                opacity: _opacityAnim,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 340,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white70.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.blue.shade200.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Регистрация",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1a2d45),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInput("Имя", false, isDark),
                            _buildInput("Email", false, isDark,
                                inputType: TextInputType.emailAddress),
                            _buildInput("Пароль", true, isDark),
                            const SizedBox(height: 20),

                            /// ✅ Обновлённая кнопка
                            _FancyButton(
                              text: "Зарегистрироваться",
                              isDark: isDark,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('✅ Регистрация успешна!')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Кнопка переключения темы
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: widget.onToggleTheme,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.white.withOpacity(0.15),
                ),
                shape: MaterialStateProperty.all(const CircleBorder()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, bool isPassword, bool isDark,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        obscureText: isPassword,
        keyboardType: inputType,
        validator: (value) => value!.isEmpty ? "Введите $label" : null,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color:
              isDark ? Colors.white24 : Colors.blueGrey.shade200,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.blueAccent.withOpacity(0.5)
                  : const Color(0xFF031FFF),
              width: 2.0,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// 💎 Обновлённая кнопка с 3D, тенью и подсветкой
class _FancyButton extends StatefulWidget {
  final String text;
  final bool isDark;
  final VoidCallback onPressed;

  const _FancyButton({
    required this.text,
    required this.isDark,
    required this.onPressed,
  });

  @override
  State<_FancyButton> createState() => _FancyButtonState();
}

class _FancyButtonState extends State<_FancyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDark
                ? [const Color(0x0D102FFF), const Color(0x0E2050FF)]
                : [const Color(0x9DBCB2FF), const Color(0x6092B4FF)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _pressed
              ? []
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../widgets/ui_background.dart';
// import '../widgets/ui_glass_container.dart';
// import '../widgets/ui_input_field.dart';
// import '../widgets/ui_primary_button.dart';
// import '../widgets/ui_page_entrance_anim.dart';
// import '../widgets/ui_theme_toggle.dart';
//
// class RegisterScreen extends ConsumerStatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends ConsumerState<RegisterScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _opacityAnim;
//   late Animation<Offset> _offsetAnim;
//
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
//
//     _opacityAnim = Tween(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//
//     _offsetAnim = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//
//     Future.delayed(const Duration(milliseconds: 300), _controller.forward);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textTheme = GoogleFonts.interTextTheme();
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           UiBackground(isDark: isDark),
//
//           Center(
//             child: UiPageEntranceAnim(
//               opacity: _opacityAnim,
//               offset: _offsetAnim,
//               child: UiGlassContainer(
//                 isDark: isDark,
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         "Регистрация",
//                         style: textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: isDark ? Colors.white : const Color(0xFF1a2d45),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//
//                       UiInputField(label: "Имя", isPassword: false, isDark: isDark),
//                       UiInputField(label: "Email", isPassword: false, isDark: isDark, inputType: TextInputType.emailAddress),
//                       UiInputField(label: "Пароль", isPassword: true, isDark: isDark),
//
//                       const SizedBox(height: 20),
//                       UiPrimaryButton(
//                         text: "Зарегистрироваться",
//                         isDark: isDark,
//                         onPressed: () {
//                           if (_formKey.currentState?.validate() ?? false) {
//                             Navigator.pushReplacementNamed(context, "/whiteboard");
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           const UiThemeToggle(),
//         ],
//       ),
//     );
//   }
// }

