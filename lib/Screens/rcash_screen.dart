import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Widgets/rcash_tile.dart';

class RcashScreen extends StatefulWidget {
  @override
  _RcashScreenState createState() => _RcashScreenState();
}

class _RcashScreenState extends State<RcashScreen> {
  buildList() {
    List<RcashTile> tiles = [];
    for (int i = 0; i < 5; i++) {
      RcashTile tile = RcashTile(user: curUser);
      tiles.add(tile);
    }

    return ListView(
      children: tiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: buildList(),
    );
  }
}
