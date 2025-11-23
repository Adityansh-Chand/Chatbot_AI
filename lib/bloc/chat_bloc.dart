import 'dart:async';
import 'package:artificial_intelegence/Model/chat_message_model.dart';
import 'package:artificial_intelegence/Model/leave_balance_model.dart'; // Import the new model
import 'package:artificial_intelegence/repo/chat_repo.dart';
import 'package:artificial_intelegence/repo/leave_api_repo.dart'; // Import the new repo
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // 1. State now holds a list of AppMessageModel
  ChatBloc() : super(ChatSuccessState(messages: const [])) {
    // 2. Load the JSON knowledge base when the BLoC is created
    ChatRepo.loadKnowledgeBase();
    on<ChatGenerateNewTextMessageEvent>(chatGenerateNewTextMessageEvent);
  }

  // 3. The BLoC's message list now uses the new UI model
  List<AppMessageModel> messages = [];
  bool generating = false;

  FutureOr<void> chatGenerateNewTextMessageEvent(
      ChatGenerateNewTextMessageEvent event, Emitter<ChatState> emit) async {
    final String userMessage = event.inputMessage;
    if (userMessage.isEmpty) return;

    // 4. Add the user's message (as an AppMessageModel)
    messages.add(AppMessageModel(
      role: "user",
      type: MessageType.text,
      text: userMessage,
    ));
    // Emit the user's message immediately
    emit(ChatSuccessState(messages: messages));
    generating = true;
    await Future.delayed(
        const Duration(milliseconds: 100)); // Small delay for UI

    // 5. --- INTENT ROUTING LOGIC ---
    String userTextLower = userMessage.toLowerCase();
    bool isLeaveBalanceRequest = userTextLower.contains("leave balance") ||
        userTextLower.contains("my leave") ||
        userTextLower.contains("leave count");

    if (isLeaveBalanceRequest) {
      // --- INTENT 1: Fetch Leave Balance (REST API) ---
      // ignore: avoid_print
      print("BLoC: Matched intent 'Leave Balance'. Calling LeaveApiRepo...");
      LeaveBalanceModel? balance =
          await LeaveApiRepo.fetchLeaveBalance("456"); // Pass a user ID

      if (balance != null) {
        // Add a 'table' type message
        messages.add(AppMessageModel(
          role: 'model',
          type: MessageType.table, // <-- Use the new type
          leaveBalance: balance, // <-- Attach the data
        ));
      } else {
        // Handle API error
        messages.add(AppMessageModel(
          role: 'model',
          text: "Sorry, I couldn't fetch your leave balance right now.",
        ));
      }
    } else {
      // --- INTENT 2: Policy Question (RAG) ---
      // ignore: avoid_print
      print(
          "BLoC: Matched intent 'Policy Question'. Calling ChatRepo (RAG)...");
      // The repo will handle finding context and calling Gemini
      String generatedText = await ChatRepo.chatTextGenerationRepo(messages);

      if (generatedText.isNotEmpty) {
        messages.add(AppMessageModel(role: 'model', text: generatedText));
      } else {
        messages.add(AppMessageModel(
            role: 'model',
            text: "Sorry, I'm having trouble connecting. Please try again."));
      }
    }

    // 6. Emit final state (with AI/API response) and stop loading
    generating = false;
    emit(ChatSuccessState(messages: messages));
  }
}
