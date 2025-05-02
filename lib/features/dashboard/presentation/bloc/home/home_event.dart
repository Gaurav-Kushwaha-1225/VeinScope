part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchChatHistoryEvent extends HomeEvent {
  final String email;

  FetchChatHistoryEvent(this.email);
}
