import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/Widgets/rcash_tile.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/model/user.dart';

import 'login_page.dart';
import 'package:http/http.dart' as http;

class RcashScreen extends StatefulWidget {
  User Ruser;
  RcashScreen({this.Ruser});
  @override
  _RcashScreenState createState() => _RcashScreenState();
}

class _RcashScreenState extends State<RcashScreen> {
  bool isLoading = true;
  List titles = [
    "Total",
    "Available",
    "Wage",
    "Investment",
    "Joining",
    "Platform Engagement"
  ];
  List values;

  @override
  void initState() {
    super.initState();
    getRCashDetails();
    values = [
      curUser.lollarAmount,
      curUser.totalAvailableYollar,
      curUser.totalWageEarningAmount,
      curUser.totalInvestmentEarningActiveAmount,
      curUser.joiningBonus,
      curUser.totalPlatformEngagementAmount
    ];
  }

  Future<void> getRCashDetails() async {
    var user = await FirebaseAuth.instance.currentUser();
    var token = await user.getIdToken();
    DocumentSnapshot doc = await users.document(user.uid).get();

    var id = doc['id'];
    final url = userEndPoint + "getyollar";

    var response;
    try {
      token = await user.getIdToken();
      //print(token);
      response = await http.post(url,
          encoding: Encoding.getByName("utf-8"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            //"Accept": "*/*"
          },
          body: jsonEncode({"id": id}));
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      return null;
    }
    print(response.body);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      var body = jsonResponse['body'];
      var body1 = jsonDecode(body);
      var msg = body1['message'];
      widget.Ruser = User.fromJson(msg);

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
        curUser.lollarAmount,
        curUser.totalAvailableYollar,
        curUser.totalWageEarningAmount,
        curUser.totalInvestmentEarningActiveAmount,
        curUser.joiningBonus,
        curUser.totalPlatformEngagementAmount
      ];
      //print(this.user.lollarAmount);
      setState(() {
        isLoading = false;
      });
    } else {
      print(response.statusCode);
      setState(() {
        isLoading = false;
      });
      var alertBox = AlertDialogBox(
        title: "Error status: ${response.statusCode}",
        content: "Server Error",
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Back",
              style: TextStyle(
                color: colorButton,
                fontFamily: "Lato",
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          ),
        ],
      );

      showDialog(context: (context), builder: (context) => alertBox);
    }
  }

  buildList() {
    List<RcashTile> tiles = [];
    for (int i = 0; i < 6; i++) {
      RcashTile tile = RcashTile(
        user: widget.Ruser,
        title: titles[i],
        value: values[i],
        textColor: values[i] < 0 ? colorAmountNegative : colorAmountPositive,
        backgroundColor:
            values[i] < 0 ? colorRcashNegative : colorRcashPositive,
      );
      tiles.add(tile);
    }

    return ListView(
      children: tiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: RefreshIndicator(onRefresh: getRCashDetails, child: buildList()),
    );
  }
}
