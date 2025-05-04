import 'package:file_picker/file_picker.dart';

import '../entities/chat_entity.dart';

abstract class ChatRepository {
  Future<List<ChatEntity>> fetchChatHistory(String user);
  Future<List<ChatEntity>> fetchChatHistoryByChatId(String chatId);
  Future<ChatEntity?> addChat(
    String chatId,
    String user,
    String prompt,
    FilePickerResult promptImage,
    String response,
    FilePickerResult responseImage,
    String timestamp,
    List<List<int>>? promptVector,
  );
}
