// chat_item.dart
class ChatItem {
  final String avatarUrl;
  final String name;
  final String lastMessage;
  final String dateLabel;
  final bool myTurn;

  const ChatItem({
    required this.avatarUrl,
    required this.name,
    required this.lastMessage,
    required this.dateLabel,
    required this.myTurn,
  });
}
