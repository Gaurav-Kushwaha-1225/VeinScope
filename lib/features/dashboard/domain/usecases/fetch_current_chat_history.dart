import '../entities/chat_entity.dart';
import '../repository/chat_repository.dart';

class FetchCurrentChatHistory {
  final ChatRepository repository;
  FetchCurrentChatHistory(this.repository);
  Future<List<ChatEntity>> call(String chatId) => repository.fetchChatHistoryByChatId(chatId);
}
