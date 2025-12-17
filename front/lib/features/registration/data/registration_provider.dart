import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/core/api/api_client.dart';
import 'package:miro_prototype/core/api/api_routes.dart';

final registrationProvider = Provider<RegistrationRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return RegistrationRepository(api);
});

class RegistrationRepository {
  final ApiClient _api;

  RegistrationRepository(this._api);

  Future<void> register(String name, String email, String password) async {
    await _api.post(
      ApiRoutes.register,
      body: {'name': name, 'email': email, 'password': password},
    );
  }
}
