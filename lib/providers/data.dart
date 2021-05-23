import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/contants/config.dart';
import '../model/user.dart' as userModel;
import '../helper.dart';

class Data with ChangeNotifier {
  bool isRefreshing = false;
  void triggerAppBarRebuild() async {
    print("GetRCashCalled");
    var user = authFirebase.currentUser;
    var token = await user.getIdToken();
    var id;
    if (curUser == null) {
      id = savedUser.id;
    } else {
      id = curUser.id;
    }
    var response = await postFunc(
        url: userEndPoint + "getyollar",
        token: token,
        body: jsonEncode({"id": id}));

    if (response == null) {
      return null;
    }
    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];
      var Ruser = userModel.User.fromJson(responseMessage);
      if (curUser != null) {
        curUser.lollarAmount = Ruser.lollarAmount;
        curUser.totalAvailableYollar = Ruser.totalAvailableYollar;
        curUser.totalWageEarningAmount = Ruser.totalWageEarningAmount;
        curUser.totalInvestmentEarningActiveAmount =
            Ruser.totalInvestmentEarningActiveAmount;
        curUser.joiningBonus = Ruser.joiningBonus;
        curUser.totalPlatformEngagementAmount =
            Ruser.totalPlatformEngagementAmount;
        curUser.referralAmount = Ruser.referralAmount;
        curUser.totalPlatformInteractionAmount =
            Ruser.totalPlatformInteractionAmount;
        curUser.totalActiveInvestmentAmount = Ruser.totalActiveInvestmentAmount;
        curUser.totalInvestmentEarningMaturedAmount =
            Ruser.totalInvestmentEarningMaturedAmount;
      }
    }
    notifyListeners();
  }
}
