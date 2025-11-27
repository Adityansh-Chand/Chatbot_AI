import 'dart:async';
import 'package:artificial_intelegence/Model/chat_message_model.dart';
import 'package:artificial_intelegence/repo/chat_repo.dart';
import 'package:artificial_intelegence/repo/leave_api_repo.dart'; // Import the new repo
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // 1. State now holds a list of AppMessageModel
  ChatBloc()
      : super(ChatSuccessState(messages: const [], isGenerating: false)) {
    // 2. Load the JSON knowledge base when the BLoC is created
    ChatRepo.loadKnowledgeBase();
    on<ChatGenerateNewTextMessageEvent>(chatGenerateNewTextMessageEvent);
  }

  // 3. The BLoC's message list now uses the new UI model
  List<AppMessageModel> messages = [];

  FutureOr<void> chatGenerateNewTextMessageEvent(
      ChatGenerateNewTextMessageEvent event, Emitter<ChatState> emit) async {
    final userMessage = event.inputMessage.trim();
    if (userMessage.isEmpty) return;

    // 4. Add the user's message (as an AppMessageModel)
    messages.add(AppMessageModel(
      role: "user",
      type: MessageType.text,
      text: userMessage,
    ));
    // Emit new messages + set isGenerating = true
    emit(ChatSuccessState(
      messages: List.from(messages),
      isGenerating: true,
    ));

    await Future.delayed(
        const Duration(milliseconds: 100)); // Small delay for UI

    // 5. --- INTENT ROUTING LOGIC ---
    final textLower = userMessage.toLowerCase();
    final isLeaveBalanceRequest = textLower.contains("leave balance") ||
        textLower.contains("my leave") ||
        textLower.contains("leave count");

    if (isLeaveBalanceRequest) {
      final balance = await LeaveApiRepo.fetchLeaveBalance("1001");

      if (balance != null) {
        messages.add(AppMessageModel(
          role: 'model',
          type: MessageType.table,
          leaveBalance: balance,
        ));
      } else {
        messages.add(AppMessageModel(
          role: 'model',
          type: MessageType.text,
          text: "Sorry, I couldn't fetch your leave balance.",
        ));
      }
    } else {
      final generatedText = await ChatRepo.chatTextGenerationRepo(messages);

      messages.add(AppMessageModel(
        role: 'model',
        type: MessageType.text,
        text: generatedText.isNotEmpty
            ? generatedText
            : "Sorry, I'm having trouble connecting.",
      ));
    }

    // 6. --- Finally emit messages + isGenerating = false ---
    emit(ChatSuccessState(
      messages: List.from(messages),
      isGenerating: false,
    ));
  }
}
