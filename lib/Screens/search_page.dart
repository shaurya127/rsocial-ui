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

// class Connection {
//   Connection({
//     this.id,
//     this.friendId,
//   });
//
//   String id;
//   String friendId;
//
//   factory Connection.fromJson(Map<String, dynamic> json) => Connection(
//         id: json["id"],
//         friendId: json["friendId"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "id": this.id,
//         "friendId": this.friendId,
//       };
// }

class Search_Page extends StatefulWidget {
  String photourl;
  User curUser;
  Search_Page({this.curUser, this.photourl});

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
  User curUser;
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "Search_page");
    setState(() {
      isLoading = true;
    });
    getAllConnections();
    getUser();
    //getConnections();
  }

  setOrientation(String Orientation) {
    setState(() {
      this.Orientation = Orientation;
    });
  }

  Future<User> getUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    var token = await user.getIdToken();
    print(token);

    DocumentSnapshot doc = await users.document(user.uid).get();
    //print("This is the doc");
    //print(doc.data);

    var id = doc['id'];
    final url = userEndPoint + "$id";

    token = await user.getIdToken();
    //print(token);
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    });
    //print(response.body);
    //print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      //print("body is $body");
      // print(body1);
      var msg = body1['message'];
      print(msg["SentPendingConnection"]);

      List<String> outgoing = [];
      if (msg["SentPendingConnection"] != null) {
        for (int i = 0; i < msg["SentPendingConnection"].length; i++) {
          User user = User.fromJson(msg["SentPendingConnection"][i]);
          outgoing.add(user.id);
        }
      }

      List<String> frnds = [];
      if (msg["Connection"] != null) {
        for (int i = 0; i < msg["Connection"].length; i++) {
          User user = User.fromJson(msg["Connection"][i]);
          frnds.add(user.id);
        }
      }

      sentPendingConnections = outgoing;
      idConnections = frnds;
      curUser = User.fromJson(msg);

      //this.sentPendingConnections = curUser.sentPendingConnection;

      setState(() {
        isLoading = false;
      });
      return curUser;
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

    suggestionList = query == null || query.isEmpty || allUsers.isEmpty
        ? []
        : allUsers
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

  Future<List<User>> getAllConnections() async {
    print("==========Inside get all connection ===================");
    var user = await FirebaseAuth.instance.currentUser();
    //
    // DocumentSnapshot doc = await users.document(user.uid).get();
    // var id = doc['id'];
    var id = widget.curUser.id;
    final url = userEndPoint + "$id/all";

    var token = await user.getIdToken();
    //print(token);

    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    });

    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      var msg = body1['message'];

      //print("length is ${msg.length}")
      for (int i = 0; i < msg.length; i++) {
        // print(msg[i]['PendingConnection']);

        if (msg[i]['id'] == id) {
          continue;
        }

        User user = User.fromJson(msg[i]);

        allUsers.add(user);
      }
      setState(() {
        isLoading = false;
      });
      return allUsers;
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  buildSearchTab() {
    //sentPendingConnections = curUser.sentPendingConnection;
    print("These are my sent connections");
    //print(curUser.sentPendingConnection);
    print(sentPendingConnections.length);
    // if (suggestionList.isNotEmpty) {
    List<Request_Tile> searchResults = [];
    Request_Tile tile;
    for (int i = 0; i < suggestionList.length; i++) {
      if (sentPendingConnections.contains(suggestionList[i].id) ||
          idConnections.contains(suggestionList[i].id)) {
        print("Hello");
        tile = Request_Tile(
          user: suggestionList[i],
          accepted: true,
          request: false,
          photourl: widget.photourl,
          curUser: widget.curUser,
        );
      } else {
        tile = Request_Tile(
          user: suggestionList[i],
          text: "Add",
          request: false,
          accepted: false,
          photourl: widget.photourl,
          curUser: widget.curUser,
        );
      }
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
        Request_Tile tile = Request_Tile(
          user: connections[i],
          text: "Remove",
          accepted: false,
          request: false,
          photourl: widget.photourl,
          curUser: widget.curUser,
        );
        friendResults.add(tile);
      }
      return ListView(
        children: friendResults,
      );
    } else
      return Scaffold(
        body: Center(
          child: Container(
            child: Text("You have no friends till now"),
          ),
        ),
      );
  }

  buildRequestTab() {
    requestList = curUser.receivedPendingConnection;
    if (requestList.isNotEmpty) {
      List<Request_Tile> tiles = [];
      for (int i = 0; i < requestList.length; i++) {
        Request_Tile tile = Request_Tile(
          user: requestList[i],
          request: true,
          accepted: false,
          photourl: requestList[i].photoUrl,
          text: "Accept",
          curUser: widget.curUser,
        );
        tiles.add(tile);
      }
      return ListView(children: tiles);
    } else
      return Scaffold(
        body: Center(
          child: Container(
            child: Text("You have no pending requests"),
          ),
        ),
      );
  }

  Widget BuildScreen(String Orientation) {
    if (Orientation == 'request')
      return isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : buildRequestTab();
    else if (Orientation == "suggest")
      return isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : buildSuggestedTab();
    else if (Orientation == "search")
      return isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : buildSearchTab();
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

// class Request_Tile extends StatefulWidget {
//   bool request = false;
//   bool accepted = false;
//   String photourl;
//   String text;
//   User user;
//   User curUser;
//   Request_Tile(
//       {this.request, this.text, this.user, this.photourl, this.curUser});
//   @override
//   _Request_TileState createState() => _Request_TileState();
// }
//
// class _Request_TileState extends State<Request_Tile> {
//   removeConnection(String friendId) async {
//     var url = userEndPoint + "removeconnection";
//     var user = await FirebaseAuth.instance.currentUser();
//     DocumentSnapshot doc = await users.document(user.uid).get();
//     var uid = doc['id'];
//     //print(uid);
//     Connection connection = Connection(
//       id: uid,
//       friendId: friendId,
//     );
//     var token = await user.getIdToken();
//     print(jsonEncode(connection.toJson()));
//     //print(token);
//     var response = await http.put(
//       url,
//       encoding: Encoding.getByName("utf-8"),
//       body: jsonEncode(connection.toJson()),
//       headers: {
//         "Authorization": "Bearer: $token",
//         "Content-Type": "application/json",
//       },
//     );
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       print(response.body);
//       setState(() {
//         widget.accepted = true;
//       });
//     }
//   }
//
//   addConnection(String friendId) async {
//     var url = userEndPoint + "addconnection";
//     var user = await FirebaseAuth.instance.currentUser();
//     DocumentSnapshot doc = await users.document(user.uid).get();
//     var uid = doc['id'];
//     //print(uid);
//     Connection connection = Connection(
//       id: uid,
//       friendId: friendId,
//     );
//     var token = await user.getIdToken();
//     print(jsonEncode(connection.toJson()));
//     //print(token);
//     var response = await http.put(
//       url,
//       encoding: Encoding.getByName("utf-8"),
//       body: jsonEncode(connection.toJson()),
//       headers: {
//         "Authorization": "Bearer: $token",
//         "Content-Type": "application/json",
//       },
//     );
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       print(response.body);
//       setState(() {
//         widget.accepted = true;
//       });
//     }
//   }
//
//   acceptConnection(String friendId) async {
//     var url = userEndPoint + "acceptconnection";
//
//     var user = await FirebaseAuth.instance.currentUser();
//     DocumentSnapshot doc = await users.document(user.uid).get();
//     var uid = doc['id'];
//     print(uid);
//     Connection connection = Connection(
//       id: uid,
//       friendId: friendId,
//     );
//     var token = await user.getIdToken();
//     print(jsonEncode(connection.toJson()));
//     //print(token);
//     var response = await http.put(
//       url,
//       encoding: Encoding.getByName("utf-8"),
//       body: jsonEncode(connection.toJson()),
//       headers: {
//         "Authorization": "Bearer: $token",
//         "Content-Type": "application/json",
//       },
//     );
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       final jsonUser = jsonDecode(response.body);
//       var body = jsonUser['body'];
//       var body1 = jsonDecode(body);
//       //print("body is $body");
//       // print(body1);
//       var msg = body1['message'];
//       //print("id is: ${msg['id']}");
//       //print(msg);
//       setState(() {
//         curUser = User.fromJson(msg);
//         widget.accepted = true;
//       });
//     }
//   }
//
//   showProfile(BuildContext context, User user, String photourl, User curUser) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Profile(
//           currentUser: curUser,
//           photoUrl: photourl,
//           user: user,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Column(
//         children: <Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Expanded(
//                 child: ListTile(
//                   //contentPadding: EdgeInsets.all(4),
//                   dense: true,
//                   //contentPadding: EdgeInsets.all(-10)
//                   leading: GestureDetector(
//                     onTap: () => showProfile(context, widget.user,
//                         widget.user.photoUrl, widget.curUser),
//                     child: CircleAvatar(
//                       backgroundImage: NetworkImage(
//                         widget.user.photoUrl,
//                       ),
//                     ),
//                   ),
//                   title: Text(
//                     "${widget.user.fname} ${widget.user.lname}",
//                     style: TextStyle(
//                       fontFamily: "Lato",
//                       //fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: nameCol,
//                     ),
//                   ),
//                   subtitle: Row(
//                     children: <Widget>[
//                       Container(
//                         height: 15,
//                         width: 15,
//                         padding: EdgeInsets.only(right: 2),
//                         child: SvgPicture.asset(
//                           "images/group2834.svg",
//                           color: nameCol.withOpacity(0.4),
//                         ),
//                       ),
//                       Text(
//                         "${widget.user.lollarAmount}",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         child: Container(
//                           width: 1,
//                           height: 10,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Container(
//                         height: 15,
//                         width: 15,
//                         padding: EdgeInsets.only(right: 2),
//                         child: SvgPicture.asset(
//                           "images/high-five.svg",
//                           color: nameCol.withOpacity(0.4),
//                         ),
//                       ),
//                       Text(
//                         "${widget.user.connection.length}",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Row(
//                 children: <Widget>[
//                   (widget.request && widget.accepted == false)
//                       ? Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 5),
//                           child: GestureDetector(
//                             onTap: () {},
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 8, horizontal: 8),
//                               child: Text(
//                                 "Reject",
//                                 style: TextStyle(
//                                   fontFamily: "Lato",
//                                   fontSize: 14,
//                                   color: Orientation == 'search'
//                                       ? Colors.white
//                                       : Theme.of(context).primaryColor,
//                                 ),
//                               ),
//                               decoration: BoxDecoration(
//                                   color: Orientation == 'search'
//                                       ? Theme.of(context).primaryColor
//                                       : Colors.white,
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(
//                                       width: 1,
//                                       color: Theme.of(context).primaryColor)),
//                             ),
//                           ),
//                         )
//                       : Container(),
//                   widget.accepted == false
//                       ? Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 5),
//                           child: GestureDetector(
//                             onTap: () {
//                               if (widget.text == 'Accept')
//                                 acceptConnection(widget.user.id);
//                               else if (widget.text == 'Add')
//                                 addConnection(widget.user.id);
//                               else if (widget.text == 'Remove')
//                                 removeConnection(widget.user.id);
//                               //addConnection(widget.user.id);
//                             },
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: 8, horizontal: 8),
//                               child: Text(
//                                 widget.text,
//                                 style: TextStyle(
//                                     fontFamily: "Lato",
//                                     fontSize: 14,
//                                     color: Colors.white),
//                               ),
//                               decoration: BoxDecoration(
//                                   color: Theme.of(context).primaryColor,
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(
//                                       width: 1,
//                                       color: Theme.of(context).primaryColor)),
//                             ),
//                           ),
//                         )
//                       : Icon(
//                           Icons.check,
//                           size: 24,
//                           color: colorPrimaryBlue,
//                         )
//                 ],
//               )
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 5),
//             child: Divider(
//               height: 1,
//               color: Colors.grey,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
