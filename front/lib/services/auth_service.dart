import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://localhost:8080';

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Проверяем, что есть data и внутри — token
        if (json is Map && json.containsKey('data')) {
          final data = json['data'];
          if (data is Map && data.containsKey('token')) {
            return data['token'] as String?;
          }
        }
      }

      // Если статус не 200 или структура не та — возвращаем null
      return null;
    } catch (e) {
      print('Login exception: $e');
      return null;
    }
  }

  static Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      // Успешная регистрация = 200 + структура без ошибок
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json is Map && json['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Register exception: $e');
      return false;
    }
  }
}
