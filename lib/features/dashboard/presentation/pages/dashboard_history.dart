import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Casca/config/routes/routes_consts.dart';
import 'package:Casca/features/authentication/domain/entities/user.dart';
import 'package:Casca/features/dashboard/presentation/widgets/bottom_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/consts.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/barber_card.dart';

class DashboardHistoryPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const DashboardHistoryPage({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardHistoryPage> createState() => _DashboardHistoryPageState();
}

class _DashboardHistoryPageState extends State<DashboardHistoryPage> {
  late String email;

  @override
  void initState() {
    super.initState();
    email = widget.user['email'];
    context.read<HomeBloc>().add(FetchChatHistoryEvent(email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatHistoryLoaded) {
          final chatHistory = state.chatHistory;
          if (chatHistory.isEmpty) {
            return Center(
                child: Text(
              "No chat history available",
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light
                    ? Constants.lightTextColor
                    : Constants.darkTextColor,
                letterSpacing: 2,
                wordSpacing: 1.25,
                fontStyle: FontStyle.normal,
              ),
            ));
          }
          // Group chats by chatId
          final Map<String, List<dynamic>> groupedChats = {};
          for (var chat in chatHistory) {
            groupedChats.putIfAbsent(chat.chatId, () => []).add(chat);
          }
          return ListView(
            children: groupedChats.entries.map((entry) {
              final chatId = entry.key;
              final chats = entry.value;
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).brightness == Brightness.light
                            ? Constants.lightCardFillColor
                            : Constants.darkCardFillColor,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      'Chat ID: ' + chatId,
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Constants.lightTextColor
                            : Constants.darkTextColor,
                      ),
                    ),
                  ),
                  ...chats.map<Widget>((chat) => ListTile(
                        title: Text(chat.prompt),
                        subtitle: Text(chat.response),
                        leading: const Icon(Icons.chat),
                      )),
                ],
              );
            }).toList(),
          );
        } else if (state is HomeError) {
          return Center(child: Text(state.message));
        } else {
          return Center(
              child: Text(
            "Some error occurred, please try again",
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.light
                  ? Constants.lightTextColor
                  : Constants.darkTextColor,
              letterSpacing: 2,
              wordSpacing: 1.25,
              fontStyle: FontStyle.normal,
            ),
          ));
        }
      },
    );
  }
}
