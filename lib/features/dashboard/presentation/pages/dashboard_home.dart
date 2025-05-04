import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';

import 'package:Casca/config/routes/routes_consts.dart';
import 'package:Casca/features/authentication/domain/entities/user.dart';
import 'package:Casca/features/dashboard/presentation/widgets/bottom_input.dart';
import 'package:Casca/services/server.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Casca/widgets/app_bar.dart';

import '../../../../utils/consts.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/barber_card.dart';
import '../../domain/entities/chat_entity.dart';

class DashboardHomePage extends StatefulWidget {
  Map<String, dynamic> user;
  String currentChatId;
  List<ChatEntity> chatHistory;
  String? initialKey;
  DashboardHomePage({
    Key? key,
    required this.user,
    required this.chatHistory,
  })  : currentChatId = UniqueKey().toString(), // Generate a unique key for every new chat
        super(key: key);

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  bool chatStarted = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialKey == null) {
      widget.initialKey = widget.currentChatId;
    } else {
      context.read<HomeBloc>().add(FetchCurrentChatHistoryEvent(widget.currentChatId));
    }
  }

  void startNewChat() async {
    await processImageOnServer('/home/teaching/', '/home/teaching/');
    setState(() {
      widget.currentChatId = UniqueKey().toString();
      widget.chatHistory = [];
    });
    context.read<HomeBloc>().add(FetchCurrentChatHistoryEvent(widget.currentChatId));
  }

  void continueCurrentChat() {
    context.read<HomeBloc>().add(FetchCurrentChatHistoryEvent(widget.currentChatId));
  }

  void _onTextSend(
    String prompt,
    FilePickerResult? promptImage,
  ) {
    if (promptImage == null && widget.chatHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach an image to your prompt.')),
      );
      return;
    }
    context.read<HomeBloc>().add(AddChatEvent(
      chatId: widget.currentChatId,
      user: widget.user['email'],
      prompt: prompt,
      promptImage: promptImage ?? FilePickerResult([]),
      timestamp: DateTime.now().toIso8601String(),
    ));
  }

  void _onTextSendPrompt(
    String prompt,
    FilePickerResult? promptImage,
    List<List<int>> promptVector, // Change to 2D vector
  ) {
    if (promptImage == null && widget.chatHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach an image to your prompt.')),
      );
      return;
    }

    // Extract indices where the value is 1 and form pairs [[x1, y1], [x2, y2], ...]
    final formattedPromptVector = <List<int>>[];
    for (int i = 0; i < promptVector.length; i++) {
      for (int j = 0; j < promptVector[i].length; j++) {
        if (promptVector[i][j] == 1) {
          formattedPromptVector.add([j, i]);
        }
      }
    }

    // Ensure the formattedPromptVector is limited to a maximum length of 5
    if (formattedPromptVector.length > 5) {
      formattedPromptVector.removeRange(5, formattedPromptVector.length);
    }

    context.read<HomeBloc>().add(AddChatEvent(
      chatId: widget.currentChatId,
      user: widget.user['email'],
      prompt: prompt,
      promptImage: promptImage ?? FilePickerResult([]),
      timestamp: DateTime.now().toIso8601String(),
      promptVector: formattedPromptVector, // Pass the formatted 2D prompt vector
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is ChatHistoryLoaded) {
          setState(() {
            widget.chatHistory = state.chatHistory;
          });
        } else if (state is ChatSendSuccess) {
          setState(() {
            widget.chatHistory.add(state.chat);
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: (context.watch<HomeBloc>().state is HomeLoading && widget.chatHistory.isEmpty)
                ? const Center(child: CircularProgressIndicator())
                : (widget.chatHistory.isEmpty)
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final height = constraints.maxHeight;
                          final user = widget.user;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Hi ${user['name'] ?? ''}",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Constants.lightTextColor
                                          : Constants.darkTextColor,
                                      letterSpacing: 2,
                                      wordSpacing: 1.25,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  Text(
                                    "Welcome to VeinScope!",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Constants.lightTextColor
                                          : Constants.darkTextColor,
                                      letterSpacing: 2,
                                      wordSpacing: 1.25,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  Text(
                                    "An AI-Powered Eye Vein Analysis, where you can detect and segment tear vein patterns for early health insights.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Constants.lightTextColor
                                          : Constants.darkTextColor,
                                      letterSpacing: 2,
                                      wordSpacing: 1.25,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: widget.chatHistory.length,
                        itemBuilder: (context, index) {
                          final chat = widget.chatHistory[
                              widget.chatHistory.length - 1 - index];
                          if (chat.prompt.isEmpty && chat.response.isEmpty) {
                            return Text("Start a new chat",
                                style: GoogleFonts.urbanist(
                                  fontSize: 15,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Constants.lightTextColor
                                      : Constants.darkTextColor,
                                  fontStyle: FontStyle.normal,
                                ));
                          }
                          return Column(
                            crossAxisAlignment: chat.response.isEmpty
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (chat.prompt.isNotEmpty)
                                Container(
                                  alignment: Alignment.centerRight,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.lightCardFillColor
                                        : Constants.darkCardFillColor,
                                    border: Border.all(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Constants.lightBorderColor
                                          : Constants.darkBorderColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(chat.prompt, 
                                        textAlign: TextAlign.start,
                                          style: GoogleFonts.urbanist(
                                        fontSize: 16,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.lightTextColor
                                            : Constants.darkTextColor,
                                        fontStyle: FontStyle.normal,
                                      )),
                                      const SizedBox(height: 5),
                                      if (chat.promptImage.isNotEmpty)
                                      Image.network(
                                        chat.promptImage,
                                        height: 200,
                                        width: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => 
                                            const Icon(Icons.error),
                                      ),
                                    ],
                                  ),
                                ),
                              if (chat.response.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 12),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Constants.lightCardFillColor
                                        : Constants.darkCardFillColor,
                                    border: Border.all(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Constants.lightBorderColor
                                          : Constants.darkBorderColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(chat.response, 
                                        textAlign: TextAlign.start,
                                          style: GoogleFonts.urbanist(
                                        fontSize: 16,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Constants.lightTextColor
                                            : Constants.darkTextColor,
                                        fontStyle: FontStyle.normal,
                                      )),
                                      const SizedBox(height: 5),
                                      if (chat.responseImage.isNotEmpty)
                                      Image.network(
                                        chat.responseImage,
                                        height: 200,
                                        width: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => 
                                            const Icon(Icons.error),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
          ),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeError || state is ChatSendError) {
                final msg = state is HomeError
                    ? state.message
                    : (state as ChatSendError).message;
                return Center(
                  child: Text(
                    'Error: ' + msg,
                    style:
                        GoogleFonts.urbanist(color: Colors.red, fontSize: 16),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          SafeArea(
            child: BottomInputContainer(
              isProcessing: isProcessing,
              onTextSend: _onTextSend,
              onTextSendPrompt: _onTextSendPrompt,
              onImageSend: (file) {},
            ),
          ),
        ],
      ),
    );
  }
}
