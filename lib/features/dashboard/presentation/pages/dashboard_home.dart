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
import '../../data/models/barber_model.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/barber_card.dart';

class DashboardHomePage extends StatefulWidget {
  Map<String, dynamic> user;
  DashboardHomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  bool chatStarted = false;
  bool isProcessing = false;
  List<Map<String, dynamic>> chatMessages = [];

  @override
  Widget build(BuildContext context) {
    User user = User.fromJson(widget.user);
    double height = MediaQuery.of(context).size.height;
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: chatStarted
                  ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Hi ${user.name} 👋",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.urbanist(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).brightness == Brightness.light
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
                              color: Theme.of(context).brightness == Brightness.light
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
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Constants.lightTextColor
                                  : Constants.darkTextColor,
                              letterSpacing: 2,
                              wordSpacing: 1.25,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    )),
          SafeArea(
            child: BottomInputContainer(
              isProcessing: isProcessing,
              onTextSend: (String text) {},
              onImageSend: (File file) {},
            ),
          ),
        ],
    );
  }
}
