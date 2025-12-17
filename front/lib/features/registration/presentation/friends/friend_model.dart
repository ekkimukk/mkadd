class Friend {
  final String username;
  final bool isOnline;
  final bool isPendingIncoming;
  final bool isPendingOutgoing;

  Friend({
    required this.username,
    this.isOnline = false,
    this.isPendingIncoming = false,
    this.isPendingOutgoing = false,
  });

  Friend copyWith({
    String? username,
    bool? isOnline,
    bool? isPendingIncoming,
    bool? isPendingOutgoing,
  }) {
    return Friend(
      username: username ?? this.username,
      isOnline: isOnline ?? this.isOnline,
      isPendingIncoming: isPendingIncoming ?? this.isPendingIncoming,
      isPendingOutgoing: isPendingOutgoing ?? this.isPendingOutgoing,
    );
  }
}
