import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/core/api/api_client.dart';
import 'package:miro_prototype/core/api/api_routes.dart';
import 'package:miro_prototype/core/api/auth_state_provider.dart';

final loginProvider = Provider<LoginRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  final auth = ref.read(authStateProvider.notifier);
  return LoginRepository(api, auth);
});

class LoginRepository {
  final ApiClient _api;
  final AuthStateNotifier _auth;

  LoginRepository(this._api, this._auth);

  Future<void> login(String email, String password) async {
    final res = await _api.post(
      ApiRoutes.login,
      body: {'email': email, 'password': password},
    );
    final token = res['token'];
    await _auth.saveToken(token);
  }
}
