part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

class ChatSuccessState extends ChatState {
  // This list now holds AppMessageModel
  final List<AppMessageModel> messages;

  ChatSuccessState({
    required this.messages,
  });
}
