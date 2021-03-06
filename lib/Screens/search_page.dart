import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/Widgets/error.dart';
import 'package:rsocial2/Widgets/selectButton.dart';
import 'package:rsocial2/auth.dart';
import 'package:rsocial2/contants/config.dart';
import '../Widgets/request_tile.dart';
import '../contants/constants.dart';
import '../model/user.dart';
import 'bottom_nav_bar.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;

class Search_Page extends StatefulWidget {
  User currentUser;
  Search_Page({this.currentUser});

  @override
  _Search_PageState createState() => _Search_PageState();
}

class _Search_PageState extends State<Search_Page>
    with TickerProviderStateMixin {
  String Orientation = "suggest";
  List<User> connections = [];
  List<String> sentPendingConnections = [];
  List<String> idConnections = [];
  List<User> allUsers = [];
  List<User> requestList = [];
  Set<User> suggestionList ={};
  bool isLoading = false;
  String searchQuery = "";
  String photourl = "";
  bool isGetUserFail = false;
  bool isFailedGetAllUser = false;
  bool isLoadingSearch = false;
  bool searchResultsLeft = false;
  int page = 0;
  ScrollController controller = ScrollController();
  //User curUser;
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "Search_page");
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (searchResultsLeft) {
          setState(() {
            page = page + 10;
          });
          //print("i was called with $page and $platformStoriesStillLeft");
          buildSuggestions();
        }
      }
    });
  }

  setOrientation(String orientation) {
    setState(() {
      this.Orientation = orientation;
    });
  }

  Future<void> getUser() async {
    setState(() {
      isLoading = true;
    });
    var user = auth.FirebaseAuth.instance.currentUser;
    var token = await user.getIdToken();

    var id = curUser.id;
    final url = Uri.parse(userEndPoint + "get");

    token = await user.getIdToken();

    var response;
    try {
      response = await http.post(url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"id": id, "email": user.email}));
    } catch (e) {
      setState(() {
        setState(() {
          isGetUserFail = true;
          isLoading = false;
        });
      });
    }
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

  // Future<void> getAllUsers() async {
  //   setState(() {
  //     suggestionList = [];
  //     allUsers = [];
  //     isLoadingSearch = true;
  //   });
  //   print("Inside get all users");
  //   var user;
  //   var id;
  //   var response;
  //   try {
  //     user = auth.FirebaseAuth.instance.currentUser;

  //     DocumentSnapshot doc = await users.doc(user.uid).get();
  //     id = doc['id'];

  //     final url = Uri.parse(userEndPoint + "all");

  //     var token = await user.getIdToken();
  //     //print(token);

  //     response = await http.post(url,
  //         headers: {
  //           "Authorization": "Bearer $token",
  //           "Content-Type": "application/json"
  //         },
  //         body: jsonEncode({"id": id, "email": user.email}));
  //   } catch (e) {
  //     setState(() {
  //       isFailedGetAllUser = true;
  //       isLoadingSearch = false;
  //     });
  //   }
  //   if (response.statusCode == 200) {
  //     final jsonUser = jsonDecode(response.body);
  //     var body = jsonUser['body'];
  //     var body1 = jsonDecode(body);
  //     var msg = body1['message'];
  //     //print(msg);
  //     //print("length is ${msg.length}")
  //     for (int i = 0; i < msg.length; i++) {
  //       // print(msg[i]['PendingConnection']);

  //       if (msg[i]['id'] == id) {
  //         continue;
  //       }

  //       User user = User.fromJson(msg[i]);

  //       allUsers.add(user);
  //     }
  //     setState(() {
  //       isLoadingSearch = false;
  //     });
  //     // print("all the users");
  //     // print(allUsers.length);
  //     return allUsers;
  //   } else {
  //     // print(response.statusCode);
  //     throw Exception();
  //   }
  // }

  Future<void> buildSuggestions() async {
    // show when someone searches for something
    setState(() {
      if (page == 0) {
        suggestionList = {};
        // isLoadingSearch = true;
      }
    });

    if (searchQuery == null || searchQuery.isEmpty) {
      setState(() {
        isLoadingSearch = false;
      });
      Fluttertoast.showToast(
        msg: "Please enter a non-empty search query",
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    var user;
    var id;
    var response;
    try {
      user = auth.FirebaseAuth.instance.currentUser;

      DocumentSnapshot doc = await users.doc(user.uid).get();
      id = doc['id'];

      final url = Uri.parse(userEndPoint + "paginatedfilterall");

      var token = await user.getIdToken();
      print(
        {
          "id": id,
          "namefilter": searchQuery,
          "start_token": 0,
        },
      );
      response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "id": id,
            "namefilter": searchQuery,
            "start_token": page,
          },
        ),
      );
    } catch (e) {
      setState(() {
        isFailedGetAllUser = true;
        isLoadingSearch = false;
      });
    }
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);

      print(jsonUser);
      if (jsonUser["statusCode"] == 200) {
        var body = jsonUser['body'];
        var body1 = jsonDecode(body);
        searchResultsLeft = body1["message"]["user_left"];
        var msg = body1['message']['users'];
        for (int i = 0; i < msg.length; i++) {
          if (msg[i]['id'] == id) {
            continue;
          }
          User user = User.fromJson(msg[i]);
          suggestionList.add(user);
        }
        if (suggestionList.isEmpty) {
          Fluttertoast.showToast(
            msg: "Sorry, no results found!",
            gravity: ToastGravity.CENTER,
            fontSize: 18,
          );
        }
      }
      setState(() {
        isLoadingSearch = false;
      });
    } else {
      throw Exception();
    }
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

  // Future<void> getAllConnections() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   //print("==========Inside get all connection ===================");
  //   var user = await FirebaseAuth.instance.currentUser();
  //   //
  //   // DocumentSnapshot doc = await users.document(user.uid).get();
  //   // var id = doc['id'];
  //   var id = curUser.id;
  //   final url = userEndPoint + "all";
  //
  //   var token = await user.getIdToken();
  //   //print(token);
  //
  //   final response = await http.post(url,
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode({"id": id, "email": user.email}));
  //
  //   //print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     final jsonUser = jsonDecode(response.body);
  //     var body = jsonUser['body'];
  //     var body1 = jsonDecode(body);
  //     var msg = body1['message'];
  //
  //     //print("length is ${msg.length}")
  //     for (int i = 0; i < msg.length; i++) {
  //       // print(msg[i]['PendingConnection']);
  //
  //       if (msg[i]['id'] == id) {
  //         curUser = User.fromJson(msg[i]);
  //         continue;
  //       }
  //
  //       User user = User.fromJson(msg[i]);
  //
  //       allUsers.add(user);
  //     }
  //     setState(() {
  //       widget.allusers = allUsers;
  //       isLoading = false;
  //     });
  //     //return allUsers;
  //   } else {
  //     print(response.statusCode);
  //     throw Exception();
  //   }
  // }

  buildSearchTab() {
    List<Request_Tile> searchResults = [];
    Request_Tile tile;
    for (int i = 0; i < suggestionList.length; i++) {
      tile = Request_Tile(
        user: suggestionList.elementAt(i),
        accepted: true,
        text: curUser.userMap.containsKey(suggestionList.elementAt(i).id)
            ? curUser.userMap[suggestionList.elementAt(i).id]
            : "add",
      );
      searchResults.add(tile);
    }
    return ListView.builder(
        controller: controller,
        itemCount: (searchResultsLeft)
            ? 2 + searchResults.length
            : 1 + searchResults.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == searchResults.length + 1) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) {
                          searchQuery = value;
                          buildSuggestions();
                        },
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
                          hintText: "Search Users",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: colorButton,
                      ),
                      onPressed: () {
                        page = 0;
                        buildSuggestions();
                      },
                    )
                  ],
                ),
              ),
            );
          } else
            return searchResults.isEmpty
                ? buildMsg()
                : searchResults[index - 1];
        });
  }

  buildSuggestedTab() {
    if (widget.currentUser != null) {
      connections = curUser.connection;
      List<Request_Tile> friendResults = [];
      if (connections.isNotEmpty) {
        for (int i = 0; i < connections.length; i++) {
          // print("printing connection length");
          // print(connections[i].connection.length);
          // print(connections[i].fname);
          Request_Tile tile = Request_Tile(
            user: connections[i],
            text: "remove",
            accepted: true,
            //request: false,
            //photourl: photourl,
            //curUser: curUser,
          );
          friendResults.add(tile);
        }
        friendResults.sort(
            (tile1, tile2) => tile1.user.fname.compareTo(tile2.user.fname));
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
    } else
      return LinearProgressIndicator();
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
          //photourl: requestList[i].photoUrl,
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
          ? LinearProgressIndicator()
          : isGetUserFail
              ? ErrWidget(
                  tryAgainOnPressed: () {
                    setState(() {
                      isGetUserFail = false;
                      isLoading = true;
                    });
                    getUser();
                  },
                )
              : RefreshIndicator(
                  onRefresh: getUser,
                  child: buildRequestTab(),
                );
    else if (Orientation == "suggest")
      return isLoading
          ? LinearProgressIndicator()
          : isGetUserFail
              ? ErrWidget(
                  tryAgainOnPressed: () {
                    setState(() {
                      isGetUserFail = false;
                      isLoading = true;
                    });
                    getUser();
                  },
                )
              : RefreshIndicator(
                  onRefresh: getUser,
                  child: buildSuggestedTab(),
                );
    else if (Orientation == "search")
      return isLoadingSearch
          ? LinearProgressIndicator()
          : isFailedGetAllUser
              ? ErrWidget(
                  tryAgainOnPressed: () {
                    setState(() {
                      isGetUserFail = false;
                      isLoadingSearch = true;
                    });
                    buildSuggestions();
                  },
                )
              : buildSearchTab();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SelectButton(
                      onTap: () {
                        setState(() {
                          this.Orientation = "request";
                          getUser();
                        });
                      },
                      text: "Request",
                      orientation: 'request',
                      curOrientation: Orientation),
                  SelectButton(
                      onTap: () {
                        setState(() {
                          this.Orientation = "suggest";
                        });
                      },
                      text: "Bonds",
                      orientation: 'suggest',
                      curOrientation: Orientation),
                  SelectButton(
                      onTap: () {
                        setState(() {
                          this.Orientation = "search";
                        });
                      },
                      text: "Search",
                      orientation: 'search',
                      curOrientation: Orientation),
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
