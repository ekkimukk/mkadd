import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/providers/auth_provider.dart';
import 'package:miro_prototype/services/auth_service.dart';

import '../../presentation/widgets_ui/ui_background.dart';
import '../../presentation/widgets_ui/ui_glass_container.dart';
import '../../presentation/widgets_ui/ui_input_field.dart';
import '../../presentation/widgets_ui/ui_primary_button.dart';
import '../../presentation/widgets_ui/ui_page_entrance_anim.dart';
import '../../presentation/widgets_ui/ui_theme_toggle.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _rememberMe = false;

  final _formLogin = GlobalKey<FormState>();
  final _formRegister = GlobalKey<FormState>();

  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regPass2Ctrl = TextEditingController();

  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacity = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _offset = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          UiBackground(isDark: isDark),

          Center(
            child: UiPageEntranceAnim(
              opacity: _opacity,
              offset: _offset,
              child: UiGlassContainer(
                isDark: isDark,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isLogin
                      ? _buildLoginForm(isDark)
                      : _buildRegisterForm(isDark),
                ),
              ),
            ),
          ),

          Positioned(top: 40, right: 20, child: const UiThemeToggle()),
        ],
      ),
    );
  }

  // ---------------- LOGIN FORM ----------------
  Widget _buildLoginForm(bool isDark) {
    return Form(
      key: _formLogin,
      child: Column(
        key: const ValueKey('login'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Вход',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          // --- Login field ---
          TextFormField(
            controller: _loginCtrl,
            validator: (v) => v == null || v.isEmpty ? "Введите логин" : null,
            decoration: const InputDecoration(labelText: "Email / Username"),
          ),

          const SizedBox(height: 12),

          // --- Password field ---
          TextFormField(
            controller: _passwordCtrl,
            obscureText: true,
            validator: (v) => v == null || v.isEmpty ? "Введите пароль" : null,
            decoration: const InputDecoration(labelText: "Пароль"),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v ?? false),
              ),
              const Text(
                "Запомнить меня",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 12),

          UiPrimaryButton(
            text: "Войти",
            isDark: isDark,
            onPressed: () async {
              if (_formLogin.currentState?.validate() ?? false) {
                final email = _loginCtrl.text.trim();
                final password = _passwordCtrl.text;

                // Уведомляем провайдер о загрузке
                ref.read(authProvider.notifier).setLoginLoading();

                final token = await AuthService.login(
                  email: email,
                  password: password,
                );

                if (token != null) {
                  await ref.read(authProvider.notifier).login(token);
                  Navigator.pushReplacementNamed(context, "/profile");
                } else {
                  ref.read(authProvider.notifier).clearLoading();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Неверный логин или пароль")),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 14),

          UiPrimaryButton(
            text: "Создать аккаунт",
            isDark: isDark,
            onPressed: () => setState(() => _isLogin = false),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ---------------- REGISTER FORM ----------------
  Widget _buildRegisterForm(bool isDark) {
    return Form(
      key: _formRegister,
      child: Column(
        key: const ValueKey('register'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Регистрация',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: _regNameCtrl,
            validator: (v) => v == null || v.isEmpty ? "Введите имя" : null,
            decoration: const InputDecoration(labelText: "Имя"),
          ),

          const SizedBox(height: 12),
          TextFormField(
            controller: _regEmailCtrl,
            validator: (v) => v == null || v.isEmpty ? "Введите email" : null,
            decoration: const InputDecoration(labelText: "Email"),
          ),

          const SizedBox(height: 12),
          TextFormField(
            controller: _regPassCtrl,
            obscureText: true,
            validator: (v) => v == null || v.isEmpty ? "Введите пароль" : null,
            decoration: const InputDecoration(labelText: "Пароль"),
          ),

          const SizedBox(height: 12),
          TextFormField(
            controller: _regPass2Ctrl,
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return "Повторите пароль";
              if (v != _regPassCtrl.text) return "Пароли не совпадают";
              return null;
            },
            decoration: const InputDecoration(labelText: "Повторите пароль"),
          ),

          const SizedBox(height: 16),

          UiPrimaryButton(
            text: "Зарегистрироваться",
            isDark: isDark,
            onPressed: () async {
              if (_formRegister.currentState?.validate() ?? false) {
                final success = await AuthService.register(
                  username: _regNameCtrl.text.trim(),
                  email: _regEmailCtrl.text.trim(),
                  password: _regPassCtrl.text,
                );

                if (success) {
                  // После регистрации — можно сразу логиниться или просить войти
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Регистрация успешна! Войдите в аккаунт."),
                    ),
                  );
                  setState(() => _isLogin = true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ошибка регистрации")),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 14),

          UiPrimaryButton(
            text: "Вернутся ко входу",
            isDark: isDark,
            onPressed: () => setState(() => _isLogin = true),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
