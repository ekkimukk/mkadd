class ApiRoutes {
  static const String baseUrl = 'https://your-server.com/api';

  // Auth
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';

  // Whiteboard
  static const String createBoard = '$baseUrl/whiteboard/create';
  static const String getBoards = '$baseUrl/whiteboard/list';
  static String boardById(String id) => '$baseUrl/whiteboard/$id';
}
