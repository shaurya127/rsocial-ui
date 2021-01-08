import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/login_page.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:http/http.dart' as http;
import 'package:rsocial2/Widgets/invest_post_tile.dart';
import 'package:rsocial2/Widgets/post_tile.dart';
import 'package:rsocial2/auth.dart';
import 'package:rsocial2/constants.dart';
import 'package:rsocial2/user.dart';

import '../config.dart';
import '../post.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
  User currentUser;
  User user;
  String photoUrl;
  Profile({this.currentUser, this.photoUrl, this.user});
}

class _ProfileState extends State<Profile> {
  String postOrientation = "wage";
  bool isLoading = true;
  List<Post> postsW = [];
  List<Post> postsI = [];
  List<InvestPostTile> InvestTiles = [];
  List<Post_Tile> WageTiles = [];

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserPosts();
    print("init fired");
  }

  getUserPosts() async {
    setState(() {
      isLoading = true;
    });
    print("get user post fired");
    var user = await FirebaseAuth.instance.currentUser();
    final url = storyEndPoint + "${widget.user.id}";
    var token = await user.getIdToken();
    //print(token);
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      //print("body is $body");
      //print(body1);
      var msg = body1['message'];
      //print(msg.length);
      //print("msg id ${msg}");
      for (int i = 0; i < msg.length; i++) {
        //print("msg $i is ${msg[i]}");
        Post post;
        if (msg[i]['StoryType'] == "Investment")
          post = Post.fromJsonI(msg[i]);
        else
          post = Post.fromJsonW(msg[i]);
        if (post != null) {
          if (msg[i]['StoryType'] == "Investment")
            postsI.add(post);
          else
            postsW.add(post);
        }
      }
      print("get user post finished");
      // print(postsW.length);
      // print(postsI.length);
      // buildInvestPosts();
      // buildWagePosts();
      setState(() {
        isLoading = false;
      });
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  buildWagePosts() {
    print("build wage post started");
    WageTiles = [];
    setState(() {
      isLoading = true;
    });
    if (postsW.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "No $postOrientation story yet!",
              style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorHintText),
            ),
            widget.user.id == widget.currentUser.id
                ? Text(
                    kProfilePageWage,
                    style: TextStyle(
                        fontFamily: "Lato", fontSize: 15, color: colorHintText),
                  )
                : Container()
          ],
        ),
      );
    } else {
      //print(posts.length);
      for (int i = 0; i < postsW.length; i++) {
        print("wage reaction");
        print(postsW[i].reactedBy.length);
        Post_Tile tile = Post_Tile(
            curUser: widget.currentUser,
            userPost: postsW[i],
            photoUrl: widget.user.photoUrl);
        WageTiles.add(tile);
      }
      setState(() {
        isLoading = false;
      });
      print("build wage post ended");
      return ListView(
        children: WageTiles.reversed.toList(),
      );
    }
  }

  buildInvestPosts() {
    print("build invest post started");
    InvestTiles = [];
    setState(() {
      isLoading = true;
    });
    if (postsI.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "No $postOrientation story yet!",
              style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorHintText),
            ),
            widget.user.id == widget.currentUser.id
                ? Text(
                    kProfilePageInvestment,
                    style: TextStyle(
                        fontFamily: "Lato", fontSize: 15, color: colorHintText),
                  )
                : Container(),
          ],
        ),
      );
    } else {
      //print(posts.length);
      for (int i = 0; i < postsI.length; i++) {
        print("Invest reaction");
        print(postsI[i].reactedBy.length);
        InvestPostTile tile = InvestPostTile(
            curUser: widget.currentUser,
            userPost: postsI[i],
            photoUrl: widget.user.photoUrl);
        InvestTiles.add(tile);
      }
      setState(() {
        isLoading = false;
      });
      print("build invest post ended");
      return ListView(
        children: InvestTiles.reversed.toList(),
      );
    }
  }

  buildPlatformPosts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "No $postOrientation story yet!",
            style: TextStyle(
                fontFamily: "Lato",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorHintText),
          ),
        ],
      ),
    );
  }

  List<Widget> buildHeader(BuildContext context) {
    List<Widget> list = [
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.user.photoUrl),
                ),
                widget.currentUser.id == widget.user.id
                    ? Icon(
                        Icons.edit,
                        color: colorPrimaryBlue,
                      )
                    // Text(
                    //   "Edit",
                    //   style: TextStyle(
                    //     fontFamily: "Lato",
                    //     fontWeight: FontWeight.bold,
                    //     decoration: TextDecoration.underline,
                    //     fontSize: 15,
                    //     color: Colors.blue,
                    //   ),
                    // )
                    : Container(),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "${widget.user.fname}" + " ${widget.user.lname}",
              style: TextStyle(
                fontFamily: "Lato",
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colorHintText,
              ),
            ),
            SizedBox(
              height: 3,
            ),
            widget.currentUser.id == widget.user.id
                ? Text(
                    "${widget.user.email}",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorGreyTint,
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(
              height: 3,
            ),
            widget.user.mobile != null
                ? Text(
                    widget.user.mobile != null
                        ? widget.user.mobile
                        : "mobile field is null",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 18,
                      color: colorGreyTint,
                    ),
                  )
                : SizedBox.shrink(),
            Text(
              widget.user.bio != null ? widget.user.bio : "here comes the bio",
              style: TextStyle(
                fontFamily: "Lato",
                fontSize: 16,
                color: colorHintText,
              ),
            ),
          ],
        ),
      ),
    ];
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Here app bar to be updated
        appBar: customAppBar(
            context,
            widget.currentUser.id == widget.user.id ? "My Profile" : "Profile",
            widget.currentUser.lollarAmount.toString(),
            widget.currentUser.photoUrl,
            widget.currentUser.socialStanding.toString()),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  buildHeader(context),
                ),
              )
            ];
          },
          body: Column(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                color: Colors.white,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          setPostOrientation("wage");
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              kProfilePageWageTab,
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 15,
                                color: postOrientation == 'wage'
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: 50,
                              height: 2,
                              color: postOrientation == 'wage'
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          setPostOrientation("invest");
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              kProfilePageInvestmentTab,
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 15,
                                color: postOrientation == 'invest'
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: 50,
                              height: 2,
                              color: postOrientation == 'invest'
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          setPostOrientation("platform");
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              kProfilePagePlatformTab,
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 15,
                                color: postOrientation == 'platform'
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: 50,
                              height: 2,
                              color: postOrientation == 'platform'
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : (postOrientation == 'wage'
                          ? buildWagePosts()
                          : (postOrientation == 'invest'
                              ? buildInvestPosts()
                              : buildPlatformPosts()))),
            ],
          ),
        )

        // ListView(
        //   children: <Widget>[
        //     Padding(
        //       padding: const EdgeInsets.all(24),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: <Widget>[
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: <Widget>[
        //               CircleAvatar(
        //                 radius: 50,
        //                 backgroundImage: NetworkImage(widget.user.photoUrl),
        //               ),
        //               widget.currentUser.id==widget.user.id ?
        //                   Icon(Icons.edit,color: colorPrimaryBlue,)
        //               // Text(
        //               //   "Edit",
        //               //   style: TextStyle(
        //               //     fontFamily: "Lato",
        //               //     fontWeight: FontWeight.bold,
        //               //     decoration: TextDecoration.underline,
        //               //     fontSize: 15,
        //               //     color: Colors.blue,
        //               //   ),
        //               // )
        //                   : Container(),
        //             ],
        //           ),
        //           SizedBox(
        //             height: 10,
        //           ),
        //           Text(
        //             "${widget.user.fname}" +
        //                 " ${widget.user.lname}",
        //             style: TextStyle(
        //               fontFamily: "Lato",
        //               fontWeight: FontWeight.bold,
        //               fontSize: 20,
        //               color: Color(0xff263238),
        //             ),
        //           ),
        //           SizedBox(
        //             height: 3,
        //           ),
        //           widget.currentUser.id==widget.user.id ? Text(
        //             "${widget.user.email}",
        //             style: TextStyle(
        //               fontFamily: "Lato",
        //               fontWeight: FontWeight.bold,
        //               fontSize: 18,
        //               color: Color(0xff7F7F7F),
        //             ),
        //           ) : SizedBox.shrink(),
        //           SizedBox(
        //             height: 3,
        //           ),
        //           widget.user.mobile != null
        //               ? Text(
        //                   widget.user.mobile != null
        //                       ? widget.user.mobile
        //                       : "mobile field is null",
        //                   style: TextStyle(
        //                     fontFamily: "Lato",
        //                     fontSize: 18,
        //                     color: Color(0xff7F7F7F),
        //                   ),
        //                 )
        //               : SizedBox.shrink(),
        //           Text(
        //             widget.user.bio != null
        //                 ? widget.user.bio
        //                 : "here comes the bio",
        //             style: TextStyle(
        //               fontFamily: "Lato",
        //               fontSize: 16,
        //               color: Color(0xff263238),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: <Widget>[
        //           Container(
        //             child: GestureDetector(
        //               onTap: () {
        //                 setPostOrientation("wage");
        //               },
        //               child: Column(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 children: <Widget>[
        //                   Text(
        //                     "Wage story",
        //                     style: TextStyle(
        //                       fontFamily: "Lato",
        //                       fontSize: 15,
        //                       color: postOrientation == 'wage'
        //                           ? Theme.of(context).primaryColor
        //                           : Colors.grey,
        //                     ),
        //                   ),
        //                   SizedBox(
        //                     height: 5,
        //                   ),
        //                   Container(
        //                     width: 50,
        //                     height: 2,
        //                     color: postOrientation == 'wage'
        //                         ? Theme.of(context).primaryColor
        //                         : Colors.white,
        //                   )
        //                 ],
        //               ),
        //             ),
        //           ),
        //           Container(
        //             child: GestureDetector(
        //               onTap: () => setPostOrientation("invest"),
        //               child: Column(
        //                 children: <Widget>[
        //                   Text(
        //                     "Investment story",
        //                     style: TextStyle(
        //                       fontFamily: "Lato",
        //                       fontSize: 15,
        //                       color: postOrientation == 'invest'
        //                           ? Theme.of(context).primaryColor
        //                           : Colors.grey,
        //                     ),
        //                   ),
        //                   SizedBox(
        //                     height: 5,
        //                   ),
        //                   Container(
        //                     width: 50,
        //                     height: 2,
        //                     color: postOrientation == 'invest'
        //                         ? Theme.of(context).primaryColor
        //                         : Colors.white,
        //                   )
        //                 ],
        //               ),
        //             ),
        //           ),
        //           Container(
        //             child: GestureDetector(
        //               onTap: () {
        //                 setPostOrientation("platform");
        //               },
        //               child: Column(
        //                 children: <Widget>[
        //                   Text(
        //                     "Platform Interaction",
        //                     style: TextStyle(
        //                       fontFamily: "Lato",
        //                       fontSize: 15,
        //                       color: postOrientation == 'platform'
        //                           ? Theme.of(context).primaryColor
        //                           : Colors.grey,
        //                     ),
        //                   ),
        //                   SizedBox(
        //                     height: 5,
        //                   ),
        //                   Container(
        //                     width: 50,
        //                     height: 2,
        //                     color: postOrientation == 'platform'
        //                         ? Theme.of(context).primaryColor
        //                         : Colors.white,
        //                   )
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.only(bottom: 10),
        //       child: Divider(
        //         height: 0.5,
        //         color: Colors.black,
        //       ),
        //     ),
        //     if (postOrientation == 'wage')
        //       Container(
        //         color: Colors.white,
        //         height: 1000,
        //         width: MediaQuery.of(context).size.width,
        //       )
        //     else if (postOrientation == 'invest')
        //       Container(
        //         color: Colors.white,
        //         height: 1000,
        //         width: MediaQuery.of(context).size.width,
        //       )
        //     else if (postOrientation == 'platform')
        //       Container(
        //         color: Colors.white,
        //         height: 1000,
        //         width: MediaQuery.of(context).size.width,
        //       )
        //   ],
        // )
        );
  }
}
