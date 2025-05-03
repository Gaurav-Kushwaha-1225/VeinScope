import 'dart:developer';

import 'package:Casca/features/dashboard/domain/entities/chat_entity.dart';
import 'package:Casca/features/dashboard/domain/usecases/add_chat.dart';
import 'package:Casca/features/dashboard/domain/usecases/fetch_chat_history.dart';
import 'package:Casca/features/dashboard/domain/usecases/fetch_current_chat_history.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../data/data_sources/chats_database.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AddChat addChat;
  final FetchChatHistory fetchChatHistory;
  final FetchCurrentChatHistory fetchCurrentChatHistory;

  HomeBloc({required this.addChat, required this.fetchChatHistory, required this.fetchCurrentChatHistory}) : super(HomeInitial()) {
    on<FetchChatHistoryEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final chats = await fetchChatHistory.getHistory(event.user);
        emit(ChatHistoryLoaded(chatHistory: chats));
      } catch (e) {
        emit(HomeError(message: "Failed to load chat history"));
      }
    });
    on<FetchCurrentChatHistoryEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final chats = await fetchCurrentChatHistory.call(event.chatId);
        emit(ChatHistoryLoaded(chatHistory: chats));
      } catch (e) {
        emit(HomeError(message: "Failed to load current chat history"));
      }
    });
    on<AddChatEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        // // Save user prompt first
        // await addChat(event.chat);
        // Call DeepSeek API for response
        final responseText = await _getDeepSeekResponse(event.prompt, event.promptVector);
        // final responseChat = {
        //   'chatId': event.chatId,
        //   'user': event.user,
        //   'prompt': event.prompt,
        //   'promptImage': event.promptImage,
        //   'response': responseText,
        //   'responseImage': FilePickerResult([]),
        //   'timestamp': DateTime.now().toIso8601String(),
        // };
        ChatEntity? chatEntity = await addChat.call(
          event.chatId,
          event.user,
          event.prompt,
          event.promptImage,
          responseText,
          FilePickerResult([]),
          DateTime.now(),
        );
        if (chatEntity == null) {
          emit(HomeError(message: "Failed to save chat"));
          return;
        } else {
          emit(ChatSendSuccess(chat: chatEntity));
        }
      } catch (e) {
        emit(ChatSendError("Failed to send chat: $e"));
      }
    });
  }

  Future<String> _getDeepSeekResponse(String prompt, List<List<int>>? promptVector) async {
    // DeepSeek API integration
    const apiKey = 'YOUR_DEEPSEEK_API_KEY';
    final url = Uri.parse('https://api.deepseek.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'deepseek-chat',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 256,
      'temperature': 0.7,
      'prompt_vector': promptVector, // Include 2D prompt vector in the API call
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? '';
    } else {
      // Check for billing/paid error and provide fallback
      if (response.body.contains('insufficient_quota') || response.body.contains('billing')) {
        return 'Sorry, the AI service is currently unavailable due to billing or quota issues.';
      }
      // Fallback: use a simple rule-based response
      return 'Sorry, I am unable to process your request at the moment.';
    }
  }
}
