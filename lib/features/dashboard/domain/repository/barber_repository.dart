abstract class BarberRepository {
  // Future<int> signupUser(User user);
  Future<List<Map<String, dynamic>>> fetchChatHistory(String email);
}
