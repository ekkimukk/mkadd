import 'dart:async';
import 'friend_model.dart';

class FriendService {
  static List<Friend> mockFriends = [
    Friend(username: "Alice", isOnline: true),
    Friend(username: "Bob", isOnline: false),
  ];

  static List<Friend> pendingIncoming = [];
  static List<Friend> pendingOutgoing = [];

  // Симуляция real-time обновлений
  static Stream<List<Friend>> get friendStream async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield mockFriends;
    }
  }

  static List<Friend> search(String query) {
    return mockFriends
        .where((f) => f.username.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static String? sendRequest(String username) {
    final exists = mockFriends.any((f) => f.username == username);

    if (!exists) return null;

    pendingOutgoing.add(Friend(username: username, isPendingOutgoing: true));
    return username;
  }

  static void cancelRequest(String username) {
    pendingOutgoing.removeWhere((f) => f.username == username);
  }

  static void accept(String username) {
    mockFriends.add(Friend(username: username));
    pendingIncoming.removeWhere((f) => f.username == username);
  }

  static void decline(String username) {
    pendingIncoming.removeWhere((f) => f.username == username);
  }
}
