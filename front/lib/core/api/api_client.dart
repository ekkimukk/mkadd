import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_prototype/core/api/auth_state_provider.dart';
import 'api_exceptions.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final auth = ref.watch(authStateProvider);
  return ApiClient(auth.token);
});

class ApiClient {
  final String? token;
  final _client = http.Client();

  ApiClient(this.token);

  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<dynamic> get(String url) async {
    final response = await _client.get(Uri.parse(url), headers: _headers());
    return _handleResponse(response);
  }

  Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String url, {Map<String, dynamic>? body}) async {
    final response = await _client.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String url) async {
    final response = await _client.delete(Uri.parse(url));
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return data;
      case 400:
        throw BadRequestException(data['message'] ?? 'Bad Request');
      case 401:
        throw UnauthorizedException(data['message'] ?? 'Unauthorized');
      case 404:
        throw NotFoundException(data['message'] ?? 'Not Found');
      case 500:
      default:
        throw ServerException('Server error: ${response.statusCode}');
    }
  }
}
