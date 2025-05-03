import 'package:file_picker/file_picker.dart';

class ChatEntity {
  final String chatId;
  final String user;
  final String prompt;
  final String promptImage;
  final String response;
  final String responseImage;
  final DateTime timestamp;

  ChatEntity({
    required this.chatId,
    required this.user,
    required this.prompt,
    required this.promptImage,
    required this.response,
    required this.responseImage,
    required this.timestamp,
  });

  factory ChatEntity.fromMap(Map<String, dynamic> map) {
    return ChatEntity(
      chatId: map['chatId'],
      user: map['user'],
      prompt: map['prompt'],
      promptImage: map['promptImage'] ?? '',
      response: map['response'],
      responseImage: map['responseImage'] ?? '',
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