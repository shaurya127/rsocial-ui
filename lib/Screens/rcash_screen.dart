import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Widgets/rcash_tile.dart';
import 'package:rsocial2/constants.dart';

class RcashScreen extends StatefulWidget {
  @override
  _RcashScreenState createState() => _RcashScreenState();
}

class _RcashScreenState extends State<RcashScreen> {
  List titles = [
    "Total",
    "Available",
    "Wage",
    "Investment",
    "Joining",
    "Platform Engagement"
  ];
  List values = [
    curUser.lollarAmount.toString(),
    curUser.lollarAmount.toString(),
    "3000",
    "3000",
    "200",
    "3000"
  ];

  buildList() {
    List<RcashTile> tiles = [];
    for (int i = 0; i < 6; i++) {
      RcashTile tile = RcashTile(
        user: curUser,
        title: titles[i],
        value: values[i],
        textColor: titles[i] == "Investment" ||
                titles[i] == "Wage" ||
                titles[i] == "Platform Engagement"
            ? colorAmountNegative
            : colorAmountPositive,
        backgroundColor: titles[i] == "Investment" ||
                titles[i] == "Wage" ||
                titles[i] == "Platform Engagement"
            ? colorRcashNegative
            : colorRcashPositive,
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
      child: buildList(),
    );
  }
}
