import 'package:file_picker/file_picker.dart';

import '../entities/chat_entity.dart';
import '../repository/chat_repository.dart';

class AddChat {
  final ChatRepository repository;
  AddChat(this.repository);
  Future<ChatEntity?> call(
    String chatId,
    String user,
    String prompt,
    FilePickerResult promptImage,
    String response,
    FilePickerResult responseImage,
    DateTime timestamp,
    List<List<int>>? promptVector,
  ) async {
    return await repository.addChat(
      chatId,
      user,
      prompt,
      promptImage,
      response,
      responseImage,
      timestamp.toIso8601String(),
      promptVector,
    );
  }
}
