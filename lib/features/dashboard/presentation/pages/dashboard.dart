import 'dart:convert';
import 'dart:developer';

import 'package:Casca/features/dashboard/domain/entities/chat_entity.dart';
import 'package:Casca/features/dashboard/presentation/bloc/home/home_bloc.dart';
import 'package:Casca/features/dashboard/presentation/pages/dashboard_history.dart';
import 'package:Casca/features/dashboard/presentation/pages/dashboard_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/routes/routes_consts.dart';
import '../../../../utils/consts.dart';
import '../../../../widgets/app_bar.dart';
import 'dashboard_profile.dart';

class DashboardPage extends StatefulWidget {
  Map<String, dynamic> user;
  DashboardPage({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentBottomNavigationPage = 0;
  static const String chatId = 'xyz'; // Constant chatId for the chat session
  String currentChatId = chatId;
  List<ChatEntity> chatHistory = [];

  @override
  Widget build(BuildContext context) {
    // User currentUser = User.fromJson(widget.user);
    final List<Widget> dashboard_pages = [
      DashboardHomePage(
          user: widget.user,
          chatHistory: chatHistory),
      // DashboardExplorePage(),
      // DashboardBookingPage(),
      // DashboardInboxPage(),
      DashboardHistoryPage(user: widget.user),
      DashboardProfilePage(user: widget.user),
    ];
    final appBarHeading = ["Casca", "History", "Profile"];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: CustomAppBar(
          text: appBarHeading[currentBottomNavigationPage],
          leadingFunc: () {},
          actions: [
            if (currentBottomNavigationPage == 0)
              IconButton(
                onPressed: () {
                  setState(() {
                    currentChatId = UniqueKey().toString();
                    chatHistory = [];
                  });
                  context
                      .read<HomeBloc>()
                      .add(FetchCurrentChatHistoryEvent(currentChatId));
                },
                icon: Icon(
                  Icons.chat_rounded,
                  size: 23,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Constants.lightTextColor
                      : Constants.darkTextColor,
                ),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
          ],
        ),
      ),
      body: dashboard_pages[currentBottomNavigationPage],
      bottomNavigationBar: SizedBox(
        height: 60,
        child: BottomNavigationBar(
            onTap: (index) {
              setState(() {
                currentBottomNavigationPage = index;
              });
            },
            currentIndex: currentBottomNavigationPage,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Constants.lightPrimary
                : Constants.darkPrimary,
            selectedItemColor: Theme.of(context).brightness == Brightness.light
                ? Constants.lightSecondary
                : Constants.darkSecondary,
            unselectedItemColor: Colors.grey,
            iconSize: 24,
            selectedLabelStyle: GoogleFonts.urbanist(
                fontSize: 13,
                color: Theme.of(context).brightness == Brightness.light
                    ? Constants.lightSecondary
                    : Constants.darkSecondary,
                fontStyle: FontStyle.normal),
            unselectedLabelStyle: GoogleFonts.urbanist(
                fontSize: 10,
                color: Theme.of(context).brightness == Brightness.light
                    ? Constants.lightSecondary
                    : Constants.darkSecondary,
                fontStyle: FontStyle.normal),
            items: [
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home), label: "Home"),
              // BottomNavigationBarItem(
              //     icon: Icon(CupertinoIcons.location_solid), label: "Explore"),
              // BottomNavigationBarItem(
              //     icon: Icon(CupertinoIcons.text_badge_checkmark),
              //     label: "My Booking"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: "History"),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.profile_circled), label: "Profile"),
            ]),
      ),
    );
  }
}
