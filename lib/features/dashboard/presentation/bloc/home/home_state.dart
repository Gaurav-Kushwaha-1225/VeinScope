part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});
}

class ChatHistoryLoaded extends HomeState {
  final List<ChatEntity> chatHistory;

  ChatHistoryLoaded({required this.chatHistory});
}

class ChatSendSuccess extends HomeState {
  final ChatEntity chat;

  ChatSendSuccess({required this.chat});
}

class ChatSendError extends HomeState {
  final String message;

  ChatSendError(this.message);
}
