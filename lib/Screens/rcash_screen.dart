import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/Widgets/error.dart';
import 'package:rsocial2/Widgets/rcash_tile.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/model/user.dart';
import 'package:rsocial2/Widgets/expanded_Rcashtile.dart';
import '../helper.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;

class RcashScreen extends StatefulWidget {
  User Ruser;
  RcashScreen({this.Ruser, this.reactionCallback});
  Function reactionCallback;
  @override
  _RcashScreenState createState() => _RcashScreenState();
}

class _RcashScreenState extends State<RcashScreen> {
  bool isLoading = true;
  bool isFailedRcash = false;
  // List titles = [
  //   "Total",
  //   "Available",
  //   "Wassup",
  //   "Investment",
  //   "Joining Bonus",
  //   "Platform Engagement"
  // ];
  List titles = [
    "Your Earning",
    "Reward",
    "Wassup",
    "Investment Earning (Matured)",
    "Investment Earning (Active)",
    "Interaction",
    "Referral",
    "Your Investment",
    "Available for Investment",
    "Active Investment",
    "Investment Earning (Active)"
  ];
  List values;

  @override
  void initState() {
    super.initState();
    getRCashDetails();
    values = [
      0,
      curUser.joiningBonus,
      curUser.totalWageEarningAmount,
      curUser.totalInvestmentEarningMaturedAmount,
      curUser.totalInvestmentEarningActiveAmount,
      curUser.totalPlatformInteractionAmount,
      curUser.referralAmount,
      0,
      curUser.totalAvailableYollar,
      curUser.totalActiveInvestmentAmount,
      curUser.totalInvestmentEarningActiveAmount,
      // curUser.lollarAmount,
      // curUser.totalAvailableYollar,
      // curUser.totalWageEarningAmount,
      // curUser.totalInvestmentEarningActiveAmount,
      // curUser.joiningBonus,
      // curUser.totalPlatformEngagementAmount
    ];
  }

  Future<void> getRCashDetails() async {
    setState(() {
      isLoading = true;
      isFailedRcash = false;
    });

    var user = authFirebase.currentUser;
    var token = await user.getIdToken();
    var id = curUser.id;

    var response = await postFunc(
        url: userEndPoint + "getyollar",
        token: token,
        body: jsonEncode({"id": id}));

    if (response == null) {
      setState(() {
        isLoading = false;
        isFailedRcash = true;
      });
      return null;
    }
    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];
      widget.Ruser = User.fromJson(responseMessage);

      curUser.lollarAmount = widget.Ruser.lollarAmount;
      curUser.totalAvailableYollar = widget.Ruser.totalAvailableYollar;
      curUser.totalWageEarningAmount = widget.Ruser.totalWageEarningAmount;
      curUser.totalInvestmentEarningActiveAmount =
          widget.Ruser.totalInvestmentEarningActiveAmount;
      curUser.joiningBonus = widget.Ruser.joiningBonus;
      curUser.totalPlatformEngagementAmount =
          widget.Ruser.totalPlatformEngagementAmount;
      curUser.referralAmount = widget.Ruser.referralAmount;
      curUser.totalPlatformInteractionAmount =
          widget.Ruser.totalPlatformInteractionAmount;
      curUser.totalActiveInvestmentAmount =
          widget.Ruser.totalActiveInvestmentAmount;
      curUser.totalInvestmentEarningMaturedAmount =
          widget.Ruser.totalInvestmentEarningMaturedAmount;
      setState(() {});
      values = [
        0,
        curUser.joiningBonus,
        curUser.totalWageEarningAmount,
        curUser.totalInvestmentEarningMaturedAmount,
        curUser.totalInvestmentEarningActiveAmount,
        curUser.totalPlatformInteractionAmount,
        curUser.referralAmount,
        0,
        curUser.totalAvailableYollar,
        curUser.totalActiveInvestmentAmount,
        curUser.totalInvestmentEarningActiveAmount,
        // curUser.lollarAmount,
        // curUser.totalAvailableYollar,
        // curUser.totalWageEarningAmount,
        // curUser.totalInvestmentEarningActiveAmount,
        // curUser.joiningBonus,
        // curUser.totalPlatformEngagementAmount
      ];
      //print(this.user.lollarAmount);
      if (widget.reactionCallback != null) widget.reactionCallback();
    }
    setState(() {
      isLoading = false;
      isFailedRcash = false;
    });
  }

  buildList() {
    List<Widget> tiles = [];
    List<int> value1 = [];
    List<String> title1 = [];
    List<String> title2 = [];
    List<int> value2 = [];
    int j = 0;

    while (j < 7) {
      value1.add(values[j]);
      title1.add(titles[j]);
      j++;
    }
    EpandedRcashTile tile1 = EpandedRcashTile(
      user: widget.Ruser,
      titles: title1,
      values: value1,
    );
    while (j < 11) {
      value2.add(values[j]);
      title2.add(titles[j]);
      j++;
    }
    EpandedRcashTile tile2 = EpandedRcashTile(
      user: widget.Ruser,
      titles: title2,
      values: value2,
    );
    tiles.add(tile1);
    tiles.add(SizedBox(
      height: 10,
    ));
    tiles.add(tile2);
    // for (int i = 0; i < 6; i++) {
    //   if (titles[i] == "Platform Engagement" || titles[i] == "Investment") {
    //     RcashTile tile = RcashTile(
    //       user: widget.Ruser,
    //       title: titles[i],
    //       value: values[i],
    //       textColor: values[i] < 0 ? colorAmountNegative : colorAmountPositive,
    //       backgroundColor:
    //           values[i] < 0 ? colorRcashNegative : colorRcashPositive,
    //     );
    //     tiles.add(tile);
    //   }
    // }

    return ListView(
      children: tiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading && !isFailedRcash
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : isFailedRcash
            ? ErrWidget(
                showLogout: false,
                tryAgainOnPressed: () {
                  getRCashDetails();
                })
            : Padding(
                padding: EdgeInsets.only(top: 20),
                child: RefreshIndicator(
                  onRefresh: getRCashDetails,
                  child: buildList(),
                ),
              );
  }
}
