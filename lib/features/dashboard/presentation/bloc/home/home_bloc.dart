import 'dart:developer';

import 'package:Casca/features/dashboard/data/data_sources/link.dart';
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

final connectionURL =
    "mongodb+srv://casca:casca@casca.gctq7.mongodb.net/CascaDB?retryWrites=true&w=majority";
    
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
        // final responseText = await _getDeepSeekResponse(event.prompt, event.promptVector);
        // print('object');
        
        ChatEntity? chatEntity = await addChat.call(
          event.chatId,
          event.user,
          event.prompt,
          event.promptImage,
          "aaaa",
          FilePickerResult([]),
          DateTime.now(),
          event.promptVector,
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

}
