part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchChatHistoryEvent extends HomeEvent {
  final String user;

  FetchChatHistoryEvent(this.user);
}

class FetchCurrentChatHistoryEvent extends HomeEvent {
  final String chatId;
  const FetchCurrentChatHistoryEvent(this.chatId);
}

class AddChatEvent extends HomeEvent {
  final String chatId;
  final String user;
  final String prompt;
  final FilePickerResult promptImage;
  final String timestamp;
  final List<List<int>>? promptVector;

  AddChatEvent({
    required this.chatId,
    required this.user,
    required this.prompt,
    required this.promptImage,
    required this.timestamp,
    this.promptVector,
  });
}
