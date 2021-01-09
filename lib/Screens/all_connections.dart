import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/request_tile.dart';

import '../user.dart';
import 'bottom_nav_bar.dart';
import 'bottom_nav_bar.dart';

class AllConnections extends StatefulWidget {
  @override
  _AllConnectionsState createState() => _AllConnectionsState();
}

class _AllConnectionsState extends State<AllConnections> {
  List<User> connections = [];

  buildSuggestedTab() {
    connections = curUser.connection;
    List<Request_Tile> friendResults = [];
    if (connections.isNotEmpty) {
      for (int i = 0; i < connections.length; i++) {
        print("printing connection length");
        print(connections[i].connection.length);
        print(connections[i].fname);
        Request_Tile tile = Request_Tile(
          user: connections[i],
          text: "remove",
          accepted: true,
          //request: false,
          photourl: curUser.photoUrl,
          //curUser: curUser,
        );
        friendResults.add(tile);
      }
      return ListView(
        children: friendResults,
      );
    } else
      return ListView(
            children: <Widget>[
              Text(
                "You have no friends till now",
                textAlign: TextAlign.center,
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Connections",
          style: TextStyle(
            //fontWeight: FontWeight.bold,
            fontSize: 18, color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: buildSuggestedTab(),
    );
  }
}
