
import 'package:Casca/features/dashboard/domain/entities/chat_entity.dart';
import 'package:Casca/features/dashboard/domain/repository/chat_repository.dart';

class FetchChatHistory {
  final ChatRepository repository;

  FetchChatHistory(this.repository);

  Future<List<ChatEntity>> getHistory(String email) async {
    return await repository.fetchChatHistory(email);
  }
}
