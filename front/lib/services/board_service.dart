// services/board_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class BoardService {
  // Замени на твой реальный URL бэкенда
  static const String _baseUrl = 'http://localhost:8080';

  static Future<String?> createBoard(
    String token, {
    String title = 'Новая доска',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/whiteboards'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'title': title}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return (data['ID'] ?? data['id'])?.toString();
      }
      return null;
    } catch (e) {
      print('Create board error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllBoards(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/whiteboards'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Проверяем, что ответ — Map с полем 'data'
        if (json is Map && json.containsKey('data')) {
          final data = json['data'];
          if (data is Map && data.containsKey('whiteboards')) {
            final whiteboards = data['whiteboards'];
            if (whiteboards is List) {
              return List<Map<String, dynamic>>.from(whiteboards);
            }
          }
        }
      }

      print('Unexpected response format: ${response.body}');
      return [];
    } catch (e) {
      print('Fetch boards error: $e');
      return [];
    }
  }
}
