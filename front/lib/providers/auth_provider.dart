import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final String? token;
  final bool isLoading;

  AuthState({this.token, this.isLoading = false});

  bool get isLoggedIn => token != null;

  AuthState copyWith({String? token, bool? isLoading}) {
    return AuthState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    state = state.copyWith(token: token);
  }

  Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    state = state.copyWith(token: token, isLoading: false);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = AuthState();
  }

  Future<void> setLoginLoading() async {
    state = state.copyWith(isLoading: true);
  }

  Future<void> clearLoading() async {
    state = state.copyWith(isLoading: false);
  }
}
