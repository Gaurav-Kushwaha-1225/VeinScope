import 'package:Casca/features/dashboard/domain/repository/barber_repository.dart';

class FetchChatHistory {
  final BarberRepository repository;

  FetchChatHistory(this.repository);

  Future<List<Map<String, dynamic>>> getHistory(String email) {
    return repository.fetchChatHistory(email);
  }
}
