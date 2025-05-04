import 'package:file_picker/file_picker.dart';

import '../../domain/entities/chat_entity.dart';
import '../../domain/repository/chat_repository.dart';
import '../data_sources/chats_database.dart';
import '../models/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final CascaVeinScopeDB db;
  ChatRepositoryImpl(this.db);

  @override
  Future<List<ChatEntity>> fetchChatHistory(String user) async {
    final data = await db.fetchChatHistory(user);
    List<ChatEntity> chatHistory = [];
    for (var chat in data) {
      final chatModel = ChatModel.fromMap(chat);
      chatHistory.add(ChatEntity(
        chatId: chatModel.chatId,
        user: chatModel.user,
        prompt: chatModel.prompt,
        promptImage: chatModel.promptImage.isNotEmpty
            ? chatModel.promptImage.first
            : '',
        response: chatModel.response,
        responseImage: chatModel.responseImage.isNotEmpty
            ? chatModel.responseImage.first
            : '',
        timestamp: chatModel.timestamp,
      ));
    }
    return chatHistory;
  }

  @override
  Future<List<ChatEntity>> fetchChatHistoryByChatId(String chatId) async {
    final data = await db.fetchChatHistoryByChatId(chatId);
    List<ChatEntity> chatidHistory = [];
    for (var chat in data) {
      final chatModel = ChatModel.fromMap(chat);
      chatidHistory.add(ChatEntity(
        chatId: chatModel.chatId,
        user: chatModel.user,
        prompt: chatModel.prompt,
        promptImage: chatModel.promptImage.isNotEmpty
            ? chatModel.promptImage.first
            : '',
        response: chatModel.response,
        responseImage: chatModel.responseImage.isNotEmpty
            ? chatModel.responseImage.first
            : '',
        timestamp: chatModel.timestamp,
      ));
    }
    return chatidHistory;
  }

  @override
  Future<ChatEntity?> addChat(
    String chatId,
    String user,
    String prompt,
    FilePickerResult promptImage,
    String response,
    FilePickerResult responseImage,
    String timestamp,
    List<List<int>>? promptVector,
  ) async {
    final data = await db.addChatToHistory(
      chatId,
      user,
      prompt,
      promptImage,
      response,
      responseImage,
      timestamp,
      promptVector,
    );
    if (data != null) {
      return ChatEntity(
        chatId: data.chatId,
        user: data.user,
        prompt: data.prompt,
        promptImage: data.promptImage.isNotEmpty 
            ? data.promptImage.first
            : '',
        response: data.response,
        responseImage: data.responseImage.isNotEmpty
            ? data.responseImage.first
            : '',
        timestamp: data.timestamp,
      );
    } else {
      return null;
    }
  }
}
