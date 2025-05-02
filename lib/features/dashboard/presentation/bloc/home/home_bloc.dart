import 'package:Casca/features/dashboard/domain/usecases/fetch_chat_history.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_sources/barber_database.dart';
import '../../../data/models/barber_model.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchChatHistory fetchChatHistory;

  HomeBloc({required this.fetchChatHistory}) : super(HomeInitial()) {
    on<FetchChatHistoryEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final chatHistory = await fetchChatHistory.getHistory(event.email);
        emit(ChatHistoryLoaded(chatHistory: chatHistory));
      } catch (e) {
        emit(HomeError(message: "Failed to load chat history"));
      }
    });
  }
}
