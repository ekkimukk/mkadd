import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/registration/presentation/friends/friend_service.dart';
import 'package:miro_prototype/features/registration/presentation/friends/friend_service.dart';
import 'package:miro_prototype/features/registration/presentation/friends/friend_model.dart';

final friendStreamProvider =
StreamProvider<List<Friend>>((ref) => FriendService.friendStream);

class FriendNotifier extends StateNotifier<List<Friend>> {
  FriendNotifier() : super(FriendService.mockFriends);

  List<Friend> search(String query) {
    return FriendService.search(query);
  }

  void sendRequest(String username) {
    final result = FriendService.sendRequest(username);

    if (result == null) {
      // user not found
      // ничего не обновляем
      return;
    }

    state = [...state];
  }

  void cancelRequest(String username) {
    FriendService.cancelRequest(username);
    state = [...state];
  }

  void accept(String username) {
    FriendService.accept(username);
    state = [...state];
  }

  void decline(String username) {
    FriendService.decline(username);
    state = [...state];
  }
}

final friendProvider =
StateNotifierProvider<FriendNotifier, List<Friend>>((ref) {
  return FriendNotifier();
});
