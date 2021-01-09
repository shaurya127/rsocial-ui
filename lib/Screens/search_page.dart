import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/auth.dart';
import 'package:rsocial2/config.dart';
import '../Widgets/request_tile.dart';
import '../constants.dart';
import '../user.dart';
import 'bottom_nav_bar.dart';
import 'login_page.dart';
import 'package:rsocial2/connection.dart';
import 'package:http/http.dart' as http;

class Search_Page extends StatefulWidget {
  List<User> allusers;

  Search_Page({this.allusers});

  @override
  _Search_PageState createState() => _Search_PageState();
}

class _Search_PageState extends State<Search_Page>
    with TickerProviderStateMixin {
  String Orientation = "request";
  List<User> connections = [];
  List<String> sentPendingConnections = [];
  List<String> idConnections = [];
  List<User> allUsers = [];
  List<User> requestList = [];
  List<User> suggestionList = [];
  bool isLoading = false;
  String searchQuery = "";
  String photourl = "";
  //User curUser;
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "Search_page");
    // setState(() {
    //   isLoading = true;
    // });
    //getAllConnections();
    //getUser();
    //getConnections();
    print("all users in search page");
    print(widget.allusers.length);
  }

  setOrientation(String Orientation) {
    setState(() {
      this.Orientation = Orientation;
    });
  }

  Future<void> getUser() async {
    setState(() {
      isLoading = true;
    });
    var user = await FirebaseAuth.instance.currentUser();
    var token = await user.getIdToken();
    print(token);

    DocumentSnapshot doc = await users.document(user.uid).get();
    //print("This is the doc");
    //print(doc.data);

    var id = doc['id'];
    final url = userEndPoint + "get";

    token = await user.getIdToken();
    //print(token);
    final response = await http.post(url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"id": id, "email": user.email}));
    //print(response.body);
    //print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      //print("body is $body");
      // print(body1);
      var msg = body1['message'];
      //print(msg["SentPendingConnection"]);

      // List<String> outgoing = [];
      // if (msg["SentPendingConnection"] != null) {
      //   for (int i = 0; i < msg["SentPendingConnection"].length; i++) {
      //     User user = User.fromJson(msg["SentPendingConnection"][i]);
      //     outgoing.add(user.id);
      //   }
      // }
      //
      // List<String> frnds = [];
      // if (msg["Connection"] != null) {
      //   for (int i = 0; i < msg["Connection"].length; i++) {
      //     User user = User.fromJson(msg["Connection"][i]);
      //     frnds.add(user.id);
      //   }
      // }

      // sentPendingConnections = outgoing;
      // idConnections = frnds;
      //this.sentPendingConnections = curUser.sentPendingConnection;

      setState(() {
        curUser = User.fromJson(msg);

        isLoading = false;
      });
      //return curUser;
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }
  // Future<List<User>> getConnections() async {
  //   setState(() {
  //     isLoading=true;
  //   });
  //   List<User> connections = [];
  //   var user = await FirebaseAuth.instance.currentUser();
  //   //photourl = user.photoUrl;
  //   DocumentSnapshot doc = await users.document(user.uid).get();
  //   var id = doc['id'];
  //   final url =
  //       "https://9dhzla746i.execute-api.ap-south-1.amazonaws.com/user/${id}";
  //   //var user = await FirebaseAuth.instance.currentUser();
  //   //print("this user id is ${user.uid}");
  //   var token = await user.getIdToken();
  //   //print(token);
  //   final response = await http.get(url, headers: {
  //     "Authorization": "Bearer $token",
  //     "Content-Type": "application/json",
  //   });
  //   // print(response.body);
  //   // print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     final jsonUser = jsonDecode(response.body);
  //     var body = jsonUser['body'];
  //     var body1 = jsonDecode(body);
  //     // print("body is $body");
  //     // print(body1);
  //     var msg = body1['message'];
  //     //print("length is ${msg.length}");
  //     //print(msg[0]['id']);
  //     for(int i=0;i<msg.length;i++)
  //     {
  //       User connection = User.fromJson(msg[i]);
  //       connections.add(connection);
  //     }
  //     this.connections = connections;
  //     setState(() {
  //       isLoading=false;
  //     });
  //     return connections;
  //   } else {
  //     print(response.statusCode);
  //     throw Exception();
  //   }
  // }

  Widget buildSuggestions(BuildContext context, String query) {
    // show when someone searches for something

    suggestionList = query == null || query.isEmpty || widget.allusers.isEmpty
        ? []
        : widget.allusers
            .where((p) => (p.fname + " " + p.lname)
                .contains(RegExp(query, caseSensitive: false)))
            .toList();
  }

  Widget buildMsg() {
    return suggestionList.isEmpty
        ? SliverToBoxAdapter(
            child: Container(
              child: Text("Sorry, no search results!"),
            ),
          )
        : SizedBox.shrink();
  }

  Future<void> getAllConnections() async {
    setState(() {
      isLoading = true;
    });
    //print("==========Inside get all connection ===================");
    var user = await FirebaseAuth.instance.currentUser();
    //
    // DocumentSnapshot doc = await users.document(user.uid).get();
    // var id = doc['id'];
    var id = curUser.id;
    final url = userEndPoint + "all";

    var token = await user.getIdToken();
    //print(token);

    final response = await http.post(url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"id": id, "email": user.email}));

    //print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      var msg = body1['message'];

      //print("length is ${msg.length}")
      for (int i = 0; i < msg.length; i++) {
        // print(msg[i]['PendingConnection']);

        if (msg[i]['id'] == id) {
          curUser = User.fromJson(msg[i]);
          continue;
        }

        User user = User.fromJson(msg[i]);

        allUsers.add(user);
      }
      setState(() {
        widget.allusers = allUsers;
        isLoading = false;
      });
      //return allUsers;
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  buildSearchTab() {
    //sentPendingConnections = curUser.sentPendingConnection;
    //print("These are my sent connections");
    //print(curUser.sentPendingConnection);
    //print(sentPendingConnections.length);
    // if (suggestionList.isNotEmpty) {
    List<Request_Tile> searchResults = [];
    Request_Tile tile;
    for (int i = 0; i < suggestionList.length; i++) {
      tile = Request_Tile(
        user: suggestionList[i],
        accepted: true,
        text: curUser.userMap.containsKey(suggestionList[i].id)
            ? curUser.userMap[suggestionList[i].id]
            : "add",
        //request: false,
        photourl: photourl,
      );
      searchResults.add(tile);
    }
    return ListView.builder(
        itemCount: 1 + searchResults.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                child: TextFormField(
                  onChanged: (value) {
                    searchQuery = value;
                    buildSuggestions(context, searchQuery);
                    // isSelected = true;
                    setState(() {});
                  },
                  // onTap: () {
                  //   setState(() {
                  //     isSelected = true;
                  //   });
                  // },
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorPrimaryBlue)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: colorGreyTint.withOpacity(0.3))),
                      hintStyle: TextStyle(
                          color: colorGreyTint.withOpacity(0.6),
                          fontFamily: "Lato",
                          fontSize: 12,
                          letterSpacing: 0.75,
                          fontWeight: FontWeight.w300),
                      hintText: "Search Users"),
                ),
              ),
            );
          } else
            return searchResults[index - 1];
        });
  }

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
          photourl: photourl,
          //curUser: curUser,
        );
        friendResults.add(tile);
      }
      return ListView(
        children: friendResults,
      );
    } else
      return Scaffold(
          body: ListView(
        children: <Widget>[
          Text(
            "You have no friends till now",
            textAlign: TextAlign.center,
          ),
        ],
      ));
  }

  buildRequestTab() {
    requestList = curUser.receivedPendingConnection;
    if (requestList.isNotEmpty) {
      List<Request_Tile> tiles = [];
      for (int i = 0; i < requestList.length; i++) {
        Request_Tile tile = Request_Tile(
          user: requestList[i],
          //request: true,
          accepted: false,
          photourl: requestList[i].photoUrl,
          text: "request",
          //curUser: curUser,
        );
        tiles.add(tile);
      }
      return ListView(children: tiles);
    } else
      return Scaffold(
        body: ListView(children: <Widget>[
          Text(
            "You have no pending requests",
            textAlign: TextAlign.center,
          )
        ]),
      );
  }

  Widget BuildScreen(String Orientation) {
    if (Orientation == 'request')
      return isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: getUser,
              child: buildRequestTab(),
            );
    else if (Orientation == "suggest")
      return isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: getUser,
              child: buildSuggestedTab(),
            );
    else if (Orientation == "search")
      return isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: getAllConnections,
              child: buildSearchTab(),
            );
  }

  @override
  Widget build(BuildContext context) {
    // buildSuggestions(context, searchQuery);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => setOrientation("request"),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                      child: Text(
                        "Requests",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          color: Orientation == 'request'
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Orientation == 'request'
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: 1, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setOrientation("suggest"),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                      child: Text(
                        "Suggested",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Lato",
                          color: Orientation == 'suggest'
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Orientation == 'suggest'
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: 1, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setOrientation("search"),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                      child: Text(
                        "Search",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Lato",
                          color: Orientation == 'search'
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Orientation == 'search'
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: 1, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: Colors.grey,
            )
          ],
        ),
      ),
      body: BuildScreen(Orientation),
    );
  }
}
