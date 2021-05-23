import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/Widgets/request_tile.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/model/user.dart';

import '../contants/constants.dart';
import 'package:http/http.dart' as http;

import 'bottom_nav_bar.dart';

class Reaction_Info extends StatefulWidget {
  String postId;

  Reaction_Info({this.postId});
  @override
  _Reaction_InfoState createState() => _Reaction_InfoState();
}

class _Reaction_InfoState extends State<Reaction_Info>
    with TickerProviderStateMixin {
  TabController _tabController;
  bool isGettingReaction = true;
  bool failedGettingReaction = false;
  List<User> loved = [];
  List<User> liked = [];
  List<User> hated = [];
  List<User> whatever = [];
  List<Request_Tile> love = [];
  List<Request_Tile> hates = [];
  List<Request_Tile> likes = [];
  List<Request_Tile> whatevers = [];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 4);
    getPostReactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getPostReactions() async {
    print("get user started");
    var user = auth.FirebaseAuth.instance.currentUser;
    var token = await user.getIdToken();

    final url = storyEndPoint + "getstoryreaction";

    var response;
    try {
      token = await user.getIdToken();
      print(token);
      response = await http.post(Uri.parse(url),
          encoding: Encoding.getByName("utf-8"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            //"Accept": "*/*"
          },
          body: jsonEncode({"storyId": widget.postId}));
    } catch (e) {
      print(e);
      setState(() {
        isGettingReaction = false;
        failedGettingReaction = true;
      });
      return null;
    }
    print("Get Reaction response");
    //print(response.body);
    //print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonPostReaction = jsonDecode(response.body);
      var body = jsonPostReaction['body'];
      var body1 = jsonDecode(body);
      //print("body is $body");
      print(body1);
      var msg = body1['message'];
      var lovedResponse = msg['loved'];
      var likedResponse = msg['liked'];
      var whateverResponse = msg['whatever'];
      var hatedResponse = msg['hated'];
      if (msg == 'User Not Found') {
        setState(() {
          isGettingReaction = false;
          failedGettingReaction = true;
        });
      }

      if (lovedResponse != null) {
        for (int i = 0; i < lovedResponse.length; i++) {
          User user = User.fromJson(lovedResponse[i]);
          user.reactionType = 'loved';
          loved.add(user);
        }
      }
      if (likedResponse != null) {
        for (int i = 0; i < likedResponse.length; i++) {
          User user = User.fromJson(likedResponse[i]);
          user.reactionType = 'liked';
          liked.add(user);
        }
      }
      if (whateverResponse != null) {
        for (int i = 0; i < whateverResponse.length; i++) {
          User user = User.fromJson(whateverResponse[i]);
          user.reactionType = 'whatever';
          whatever.add(user);
        }
      }
      if (hatedResponse != null) {
        for (int i = 0; i < hatedResponse.length; i++) {
          User user = User.fromJson(hatedResponse[i]);
          user.reactionType = 'hated';
          hated.add(user);
        }
      }
      if (postsGlobal.firstWhere((element) => element.id == widget.postId,
              orElse: () {
            return -1;
          }) !=
          -1) {
        postsGlobal
            .firstWhere((element) => element.id == widget.postId)
            .reactedBy = [
          ...loved,
          ...liked,
          ...whatever,
          ...hated,
        ];
      }
      buildReactionTile();
      setState(() {
        isGettingReaction = false;
      });
    } else {
      print(response.statusCode);
      setState(() {
        isGettingReaction = false;
        failedGettingReaction = true;
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

  buildReactionTile() {
    likes = [];
    love = [];
    hates = [];
    whatevers = [];
    setState(() {
      isGettingReaction = true;
    });
    for (int i = 0; i < loved.length; i++) {
      Request_Tile tile = Request_Tile(
        text: curUser.userMap.containsKey(loved[i].id)
            ? curUser.userMap[loved[i].id]
            : "add",
        user: loved[i],
      );
      love.add(tile);
    }
    print(love.length);

    for (int i = 0; i < liked.length; i++) {
      Request_Tile tile = Request_Tile(
        text: curUser.userMap.containsKey(liked[i].id)
            ? curUser.userMap[liked[i].id]
            : "add",
        user: liked[i],
      );
      likes.add(tile);
    }

    for (int i = 0; i < hated.length; i++) {
      Request_Tile tile = Request_Tile(
        text: curUser.userMap.containsKey(hated[i].id)
            ? curUser.userMap[hated[i].id]
            : "add",
        user: hated[i],
      );
      hates.add(tile);
    }

    for (int i = 0; i < whatever.length; i++) {
      Request_Tile tile = Request_Tile(
        text: curUser.userMap.containsKey(whatever[i].id)
            ? curUser.userMap[whatever[i].id]
            : "add",
        user: whatever[i],
      );
      whatevers.add(tile);
    }
    setState(() {
      isGettingReaction = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          kReactionInfoAppBarTitle,
          style: TextStyle(
            //fontWeight: FontWeight.bold,
            fontSize: 18, color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        bottom: isGettingReaction
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16),
                      child: TabBar(
                          controller: _tabController,
                          indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                width: 4,
                                color: colorPrimaryBlue,
                              ),
                              insets: EdgeInsets.only(
                                right: 20,
                              )),
                          isScrollable: true,
                          labelPadding: EdgeInsets.only(bottom: 8),
                          tabs: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Row(
                                children: <Widget>[
                                  SvgPicture.asset(
                                    "images/thumb_blue.svg",
                                    height: 23,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    // widget.counter['loved'].toString(),
                                    love.length.toString(),
                                    style: TextStyle(
                                      fontFamily: "Lato",
                                      fontSize: 15,
                                      color: colorPrimaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //SizedBox(width: 10,),
                            Row(
                              children: <Widget>[
                                SvgPicture.asset(
                                  "images/rsocial_thumbUp_blue.svg",
                                  height: 23,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  //widget.counter['liked'].toString(),
                                  likes.length.toString(),
                                  style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: 15,
                                    color: colorPrimaryBlue,
                                  ),
                                ),
                                SizedBox(width: 20),
                              ],
                            ),

                            Row(
                              children: <Widget>[
                                SvgPicture.asset(
                                  "images/rsocial_thumbDown_blue.svg",
                                  height: 23,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  // widget.counter['whatever'].toString(),
                                  whatevers.length.toString(),
                                  style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: 15,
                                    color: colorPrimaryBlue,
                                  ),
                                ),
                                SizedBox(width: 20),
                              ],
                            ),

                            Row(
                              children: <Widget>[
                                SvgPicture.asset(
                                  "images/rsocial_punch_blue.svg",
                                  height: 23,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  //widget.counter['hated'].toString(),
                                  hates.length.toString(),
                                  style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: 15,
                                    color: colorPrimaryBlue,
                                  ),
                                ),
                                SizedBox(width: 20),
                              ],
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
      ),
      body: isGettingReaction
          ? Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              children: <Widget>[
                love.isNotEmpty
                    ? Container(
                        color: Colors.white,
                        child: ListView(children: love),
                      )
                    : Center(
                        child: Text(
                          "No love yet!",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                likes.isNotEmpty
                    ? Container(
                        color: Colors.white,
                        child: ListView(
                          children: likes,
                        ),
                      )
                    : Center(
                        child: Text(
                          "No likes yet!",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                whatevers.isNotEmpty
                    ? Container(
                        color: Colors.white,
                        child: ListView(children: whatevers),
                      )
                    : Center(
                        child: Text(
                          "No one here!",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                hates.isNotEmpty
                    ? Container(
                        color: Colors.white,
                        child: ListView(children: hates),
                      )
                    : Center(
                        child: Text(
                          "No one here!",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ],
              controller: _tabController,
            ),
    );
  }
}
