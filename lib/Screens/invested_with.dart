import 'package:flutter/material.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/user_tile.dart';
import 'package:rsocial2/constants.dart';
import '../Widgets/request_tile.dart';
import '../user.dart';
import 'bottom_nav_bar.dart';

class InvestedWithPage extends StatefulWidget {
  List<User> investedWithUser;
  User curUser;

  InvestedWithPage({this.investedWithUser, this.curUser});

  @override
  _InvestedWithPageState createState() => _InvestedWithPageState();
}

class _InvestedWithPageState extends State<InvestedWithPage> {
  List<Request_Tile> tiles = new List();

  buildList() {
    print(widget.investedWithUser.length);
    for (int i = 0; i < widget.investedWithUser.length; i++) {
      Request_Tile tile = Request_Tile(
        user: widget.investedWithUser[i],
        accepted: true,
        text: curUser.userMap.containsKey(widget.investedWithUser[i].id)
            ? curUser.userMap[widget.investedWithUser[i].id]
            : "add",
        //request: false,
        //photourl: curUser.photoUrl,
      );

      tiles.add(tile);
    }
    return ListView(
      children: tiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          context,
          kInvestingWith,
          widget.curUser.lollarAmount.toString(),
          widget.curUser.photoUrl,
          widget.curUser.socialStanding.toString()),
      body: buildList(),
    );
  }
}
