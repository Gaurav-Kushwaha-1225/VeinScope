class ChatModel {
  final String chatId;
  final String user;
  final String prompt;
  final List<String> promptImage;
  final String response;
  final List<String> responseImage;
  final DateTime timestamp;

  ChatModel({
    required this.chatId,
    required this.user,
    required this.prompt,
    required this.promptImage,
    required this.response,
    required this.responseImage,
    required this.timestamp,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    List<String> _toStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      } else if (value is String) {
        return [value];
      }
      return [];
    }
    return ChatModel(
      chatId: map['chatId'],
      user: map['user'],
      prompt: map['prompt'],
      promptImage: _toStringList(map['promptImage']),
      response: map['response'],
      responseImage: _toStringList(map['responseImage']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'user': user,
      'prompt': prompt,
      'promptImage': promptImage,
      'response': response,
      'responseImage': responseImage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}