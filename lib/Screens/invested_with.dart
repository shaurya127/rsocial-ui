import 'package:flutter/material.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/user_tile.dart';
import '../Widgets/request_tile.dart';
import '../user.dart';

class InvestedWithPage extends StatefulWidget {
  List<User> investedWithUser;
  User curUser;

  InvestedWithPage({this.investedWithUser, this.curUser});

  @override
  _InvestedWithPageState createState() => _InvestedWithPageState();
}

class _InvestedWithPageState extends State<InvestedWithPage> {
  List<UserTile> tiles = new List();
  buildList() {
    print(widget.investedWithUser.length);
    for (int i = 0; i < widget.investedWithUser.length; i++) {
      UserTile tile = UserTile(
        user: widget.investedWithUser[i],
        curUser: widget.curUser,
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
          "Invested with",
          widget.curUser.lollarAmount.toString(),
          widget.curUser.photoUrl,
          widget.curUser.socialStanding.toString()),
      body: buildList(),
    );
  }
}
