import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import '../my_flutter_app_icons.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/invested_with.dart';
import 'package:rsocial2/Screens/login_page.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/Screens/reaction_info.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'package:rsocial2/Widgets/request_tile.dart';
import 'package:rsocial2/config.dart';
import '../constants.dart';
import '../post.dart';
import '../read_more.dart';
import '../user.dart';
import 'package:http/http.dart' as http;

Map<String, Map<String, int>> m = new Map();
Map<String, Map<String, int>> mp = new Map();
class Reaction {
  Reaction({
    this.id,
    this.storyId,
    this.reactionType,
  });

  String id;
  String storyId;
  String reactionType;

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        id: json["id"],
        storyId: json["StoryId"],
        reactionType: json["ReactionType"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "StoryId": storyId,
        "ReactionType": reactionType,
      };
}

class Post_Tile extends StatefulWidget {
  Post userPost;
  var photoUrl;
  User curUser;
  Post_Tile({@required this.curUser, this.userPost, this.photoUrl});
  @override
  _Post_TileState createState() => _Post_TileState();
}

class _Post_TileState extends State<Post_Tile> with TickerProviderStateMixin {
  List<String> fileList = [];
  bool isLoading = true;
  List<User> loved = [];
  List<User> liked = [];
  List<User> hated = [];
  List<User> whatever = [];
  List<Request_Tile> love = [];
  List<Request_Tile> hates = [];
  List<Request_Tile> likes = [];
  List<Request_Tile> whatevers = [];
  List<User> investedWithUser = [];
  String rxn = "noreact";
  Map<String, int> counter = {
    'loved': 0,
    'liked': 0,
    'whatever': 0,
    'hated': 0,
    'noreact': 0
  };
  bool isDisabled = false;

  AnimationController hatedController;
  AnimationController lovedController;
  AnimationController likedController;
  AnimationController whateverController;
  Animation hatedAnimation;
  Animation lovedAnimation;
  Animation likedAnimation;
  Animation whateverAnimation;

  int reactionSizeIncrease = 3;
  getReactions() {
    print(rxn);
    //bool inLoop=true;
    for (int i = 0; i < widget.userPost.reactedBy.length; i++) {
      User user = widget.userPost.reactedBy[i];
      String rt = user.reactionType;
      if (rt == 'loved')
        loved.add(user);
      else if (rt == 'liked')
        liked.add(user);
      else if (rt == 'hated')
        hated.add(user);
      else
        whatever.add(user);

      counter[rt]++;

      if (user.id == widget.curUser.id) {
        this.rxn = user.reactionType;
      }
    }
  }

  convertStringToFile() {
    for (int i = 0; i < widget.userPost.fileUpload.length; i++) {
      //print("hehe");
      fileList.add(widget.userPost.fileUpload[i]);
    }
    //print(fileList.length);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    lovedController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    lovedAnimation = CurvedAnimation(
        parent: lovedController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeIn);
    likedController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    likedAnimation = CurvedAnimation(
        parent: likedController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeIn);
    whateverController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    whateverAnimation = CurvedAnimation(
        parent: whateverController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeIn);
    hatedController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    hatedAnimation = CurvedAnimation(
        parent: hatedController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeIn);

    getReactions();
    convertStringToFile();
    getInvestedWithUser();
  }

  getInvestedWithUser() {
    this.investedWithUser = widget.userPost.investedWithUser;
  }

  showProfile(BuildContext context, User user, String photourl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          currentUser: widget.curUser,
          photoUrl: photourl,
          user: user,
        ),
      ),
    );
  }

  @override
  void dispose() {
    lovedController.dispose();
    likedController.dispose();
    whateverController.dispose();
    hatedController.dispose();
    super.dispose();
  }

  react(String reactn) async {
    setState(() {
      isDisabled = true;
    });
    var url = storyEndPoint + 'react';
    var user = await FirebaseAuth.instance.currentUser();
    //print(uid);
    Reaction reaction = Reaction(
        id: curUser.id, storyId: widget.userPost.id, reactionType: reactn);
    var token = await user.getIdToken();
    //print(jsonEncode(reaction.toJson()));
    //print(token);
    var response = await http.put(
      url,
      encoding: Encoding.getByName("utf-8"),
      body: jsonEncode(reaction.toJson()),
      headers: {
        "Authorization": "Bearer: $token",
        "Content-Type": "application/json",
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      //print(response.body);

      // setState(() {
      String prevrxn = rxn;
      if (prevrxn == 'loved')
        loved.removeWhere((element) => element.id == curUser.id);
      else if (prevrxn == 'liked')
        liked.removeWhere((element) => element.id == curUser.id);
      else if (prevrxn == 'whatever')
        whatever.removeWhere((element) => element.id == curUser.id);
      else if (prevrxn == 'hated')
        hated.removeWhere((element) => element.id == curUser.id);
      rxn = reactn;
      if (reactn == 'loved')
        loved.add(curUser);
      else if (reactn == 'liked')
        liked.add(curUser);
      else if (reactn == 'whatever')
        whatever.add(curUser);
      else if (reactn == 'hated') hated.add(curUser);
      //print("this is my reaction $rxn");
      bool inLoop = true;

      for (int i = 0; i < widget.userPost.reactedBy.length; i++) {
        User user = widget.userPost.reactedBy[i];
        //print("rara");
        if (user.id == widget.curUser.id) {
          //print("in user post");
          //if (m.containsKey(widget.userPost.id)) m.remove(widget.userPost.id);
          user.reactionType = reactn;
          inLoop = false;
        }
      }

      //when user reacts on the post for the first time
      if (inLoop == true) {
        //print("charu22");
        // widget.userPost.user.firstRxn=reactn;
        //m[widget.userPost.id] = {reactn: counter[reactn]};
        print("This is my reaction");
        if (rxn == "noreact") {
          // m[widget.userPost.id] = {reactn: counter[reactn]};
          counter[prevrxn]--;
          //print("previous reaction is $prevrxn: ${counter[prevrxn]}");
        } else if (prevrxn != "noreact" && prevrxn != rxn) counter[prevrxn]--;

      } else {
        // if a user toggles to another reaction we need to
        // decrease the counter of the previous reaction type
        // if(rxn=='noreact')
        //   rxn="noreact";
        //print("This is my second reaction");
        if (rxn == "noreact") {
          // m[widget.userPost.id] = {reactn: counter[reactn]};
          counter[prevrxn]--;
          //print("previous reaction is $prevrxn: ${counter[prevrxn]}");
        } else if (prevrxn != rxn && rxn != "noreact") {
          counter[prevrxn]--;
        }

        //curUser.userMap[curUser.id] = reactn;
      }
      setState(() {
        m[widget.userPost.id] = {reactn: counter[reactn]};
        //print("updating mp");
        mp[widget.userPost.id] = counter;
      });
      // });
      setState(() {});
    }
    print("hello hello");
    setState(() {
      isDisabled = false;
    });
  }

  buildReactionTile() {
    likes = [];
    love = [];
    hates = [];
    whatevers = [];
    for (int i = 0; i < counter['loved']; i++) {
      Request_Tile tile = Request_Tile(
        //request: recievedpending ? true : false,
        text: curUser.userMap.containsKey(loved[i].id)
            ? curUser.userMap[loved[i].id]
            : "add",
        //accepted: aconnection,
        user: loved[i],
        photourl: loved[i].photoUrl,
        //curUser: widget.curUser,
      );
      love.add(tile);
    }

    for (int i = 0; i < counter['liked']; i++) {
      Request_Tile tile = Request_Tile(
        //request: recievedpending ? true : false,
        text: curUser.userMap.containsKey(liked[i].id)
            ? curUser.userMap[liked[i].id]
            : "add",
        //accepted: aconnection ,
        user: liked[i],
        photourl: liked[i].photoUrl,
        //curUser: widget.curUser,
      );
      likes.add(tile);
    }

    for (int i = 0; i < counter['hated']; i++) {
      Request_Tile tile = Request_Tile(
        //request: recievedpending ? true : false,
        text: curUser.userMap.containsKey(hated[i].id)
            ? curUser.userMap[hated[i].id]
            : "add",
        //accepted: aconnection ,
        user: hated[i],
        photourl: hated[i].photoUrl,
        //curUser: widget.curUser,
      );
      hates.add(tile);
    }

    for (int i = 0; i < counter['whatever']; i++) {
      Request_Tile tile = Request_Tile(
        //request: recievedpending ? true : false,
        text: curUser.userMap.containsKey(whatever[i].id)
            ? curUser.userMap[whatever[i].id]
            : "add",
        //accepted: aconnection ? true : false,
        user: whatever[i],
        photourl: whatever[i].photoUrl,
        //curUser: widget.curUser,
      );
      whatevers.add(tile);
    }
  }

  reaction(String reaction) {
    if (widget.userPost.user.id != widget.curUser.id) {
      if (reaction == 'loved') {
        lovedController.forward();
        lovedController.addListener(() {
          setState(() {});
        });
        lovedAnimation.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            lovedController.reverse();
            lovedController.addListener(() {
              setState(() {});
            });
          }
        });
      } else if (reaction == 'liked') {
        likedController.forward();
        likedController.addListener(() {
          setState(() {});
        });
        likedAnimation.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            likedController.reverse();
            likedController.addListener(() {
              setState(() {});
            });
          }
        });
      } else if (reaction == 'whatever') {
        whateverController.forward();
        whateverController.addListener(() {
          setState(() {});
        });
        whateverAnimation.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            whateverController.reverse();
            whateverController.addListener(() {
              setState(() {});
            });
          }
        });
      } else {
        hatedController.forward();
        hatedController.addListener(() {
          setState(() {});
        });
        hatedAnimation.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            hatedController.reverse();
            hatedController.addListener(() {
              setState(() {});
            });
          }
        });
      }

      if (rxn == reaction) {
        react('noreact');

        // counter[reaction]--;
        //  m[widget.userPost.user.id] = {reaction: --counter[reaction]};
      } else {
        counter[reaction]++;
        react(reaction);
      }
    } else
      print("not allowed");

    // print("state is set");
    // print(counter[reaction]);
    // setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    if (m.containsKey(widget.userPost.id)) {
      Map<String, int> map = m[widget.userPost.id];
      Map<String, int> map2 = mp[widget.userPost.id];
      for (var key in map.keys) rxn = key;
      // print("my reaction is now $rxn ${counter[rxn]}");
      setState(() {
        counter=map2;
        counter[rxn] = map[rxn];
      });

      //print(counter['hated']);
      //Map<String, int> mx = m[widget.userPost.id];
      // for (var key in mx.keys) rxn = key;

      // if (rxn == "loved")
      //   lovedCounter = m[widget.userPost.id][0];
      // else if (rxn == "liked")
      //   likedCounter = m[widget.userPost.id][1];
      // else if (rxn == "whatever")
      //   whateverCounter = m[widget.userPost.id][2];
      // else if (rxn == "hated") hatedCounter = m[widget.userPost.id][3];

    }
    //print("This is build function");

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
        //margin: EdgeInsets.only(top: 5,bottom: 5),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 15, bottom: 15),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 15, left: 15, top: 5, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: widget.userPost.storyType == "Wage"
                        ? ListTile(
                            dense: true,
                            contentPadding:
                                EdgeInsets.only(left: 0, right: -35, bottom: 0),
                            leading: GestureDetector(
                              onTap: () => showProfile(
                                  context,
                                  widget.userPost.user,
                                  widget.userPost.user.photoUrl),
                              child: CircleAvatar(
                                backgroundImage: widget.userPost.user.photoUrl !=
                                        ""
                                    ? NetworkImage(widget.userPost.user.photoUrl)
                                    : AssetImage("images/avatar.jpg"),
                              ),
                            ),
                            title: Text(
                              "${widget.userPost.user.fname} ${widget.userPost.user.lname}",
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                fontFamily: "Lato",
                                fontSize: 14,
                                color: nameCol,
                              ),
                            ),
                          )
                        : ListTile(
                            dense: true,
                            contentPadding:
                                EdgeInsets.only(left: 0, right: -35, bottom: 0),
                            leading: GestureDetector(
                              onTap: () => showProfile(
                                  context,
                                  widget.userPost.user,
                                  widget.userPost.user.photoUrl),
                              child: CircleAvatar(
                                backgroundImage: widget.userPost.user.photoUrl !=
                                        ""
                                    ? NetworkImage(widget.userPost.user.photoUrl)
                                    : AssetImage("images/avatar.jpg"),
                              ),
                            ),
                            title: Text(
                              "${widget.userPost.user.fname} ${widget.userPost.user.lname}",
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                fontFamily: "Lato",
                                fontSize: 14,
                                color: nameCol,
                              ),
                            ),
                            subtitle: Row(
                              children: <Widget>[
                                widget.userPost.investedWithUser != []
                                    ? Row(
                                        children: <Widget>[
                                          Text(
                                            "Investing with ",
                                            style: TextStyle(
                                              fontFamily: "Lato",
                                              fontSize: 12,
                                              color: subtitile,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (widget.userPost.investedWithUser
                                                      .length >=
                                                  2)
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        // settings: RouteSettings(
                                                        //     name: "Login_Page"),
                                                        type: PageTransitionType
                                                            .fade,
                                                        child: InvestedWithPage(
                                                          investedWithUser: this
                                                              .investedWithUser,
                                                          curUser: widget.curUser,
                                                        )));
                                              else
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                      // settings: RouteSettings(
                                                      //     name: "Login_Page"),
                                                      type:
                                                          PageTransitionType.fade,
                                                      child: Profile(
                                                        currentUser:
                                                            widget.curUser,
                                                        photoUrl:
                                                            investedWithUser[0]
                                                                .photoUrl,
                                                        user: investedWithUser[0],
                                                      ),
                                                    ));
                                            },
                                            child: Text(
                                              (widget.userPost.investedWithUser[0]
                                                                  .fname +
                                                              " " +
                                                              widget
                                                                  .userPost
                                                                  .investedWithUser[
                                                                      0]
                                                                  .lname)
                                                          .length <
                                                      11
                                                  ? "${widget.userPost.investedWithUser[0].fname} ${widget.userPost.investedWithUser[0].lname}"
                                                  : (widget
                                                                  .userPost
                                                                  .investedWithUser[
                                                                      0]
                                                                  .fname +
                                                              " " +
                                                              widget
                                                                  .userPost
                                                                  .investedWithUser[
                                                                      0]
                                                                  .lname)
                                                          .substring(0, 7) +
                                                      ".",
                                              style: TextStyle(
                                                fontFamily: "Lato",
                                                fontSize: 12,
                                                color: subtitile,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Text(
                                        "Investing alone",
                                        style: TextStyle(
                                          fontFamily: "Lato",
                                          fontSize: 12,
                                          color: subtitile,
                                        ),
                                      ),
                                SizedBox(
                                  width: 2,
                                ),
                                widget.userPost.investedWithUser.length >= 2
                                    ? GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  // settings: RouteSettings(
                                                  //     name: "Login_Page"),
                                                  type: PageTransitionType.fade,
                                                  child: InvestedWithPage(
                                                    investedWithUser:
                                                        this.investedWithUser,
                                                    curUser: widget.curUser,
                                                  )));
                                        },
                                        child: Text(
                                          "+ ${widget.userPost.investedWithUser.length - 1}",
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontSize: 12,
                                            color: colorButton,
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink()
                              ],
                            ),
                          ),
                  ),
                  //SizedBox(width: 1,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      widget.userPost.storyType == "Wage"
                          ? SizedBox()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      "images/coins.svg",
                                      color: colorCoins,
                                    ),
                                    Container(
                                      child: Text(
                                        "Invested",
                                        style: TextStyle(
                                            fontFamily: "Lato",
                                            fontSize: 12,
                                            color: subtitile),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Container(
                                  child: Text(
                                    "${widget.userPost.investedAmount}",
                                    style: TextStyle(
                                      fontFamily: "Lato",
                                      fontSize: 12,
                                      color: Color(0xff4DBAE6),
                                    ),
                                  ),
                                  //transform: Matrix4.translationValues(-35, 0.0, 0.0),
                                ),
                              ],
                            ),
                      SizedBox(
                        width: 14,
                      ),
                      widget.userPost.storyType == "Wage"
                          ? SizedBox()
                          : SizedBox(),
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: <Widget>[
                      //     Row(
                      //       children: <Widget>[
                      //         SvgPicture.asset("images/coins.svg",color: colorCoins,),
                      //
                      //         Container(
                      //           //transform: Matrix4.translationValues(-38, 0.0, 0.0),
                      //           child: Text("Profit",
                      //             style: TextStyle(
                      //               fontFamily: "Lato",
                      //               fontSize:12,color:subtitile,
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     SizedBox(height: 6,),
                      //     Container(
                      //       child: Text("500",
                      //         style: TextStyle(
                      //           fontFamily: "Lato",
                      //           fontSize:12,color:Color(0xff37B44B),
                      //         ),
                      //     //     TextStyle(
                      //     //     fontSize: 12,
                      //     //     color: Color(0xff37B44B)
                      //     // ),
                      //       ),
                      //       //transform: Matrix4.translationValues(-35, 0.0, 0.0),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        width: 14,
                      ),

                      if (counter['loved'] == 0 &&
                          counter['liked'] == 0 &&
                          counter['whatever'] == 0 &&
                          counter['hated'] == 0)
                        SizedBox()
                      else if (counter['loved'] >= counter['liked'] &&
                          counter['loved'] >= counter['whatever'] &&
                          counter['loved'] >= counter['hated'])
                        GestureDetector(
                          onTap: () {
                            buildReactionTile();
                            Navigator.push(
                                context,
                                PageTransition(
                                    // settings: RouteSettings(
                                    //     name: "Login_Page"),
                                    type: PageTransitionType.fade,
                                    child: Reaction_Info(
                                      like: likes,
                                      love: love,
                                      hate: hates,
                                      whatever: whatevers,
                                    )));
                          },
                          child: SvgPicture.asset(
                            "images/thumb_blue.svg",
                            //color: colorPrimaryBlue,
                            height: 23,
                          ),
                        )
                      else if (counter['liked'] > counter['loved'] &&
                          counter['liked'] >= counter['whatever'] &&
                          counter['liked'] >= counter['hated'])
                        GestureDetector(
                          onTap: () {
                            buildReactionTile();
                            Navigator.push(
                                context,
                                PageTransition(
                                    // settings: RouteSettings(
                                    //     name: "Login_Page"),
                                    type: PageTransitionType.fade,
                                    child: Reaction_Info(
                                      like: likes,
                                      love: love,
                                      hate: hates,
                                      whatever: whatevers,
                                    )));
                          },
                          child: SvgPicture.asset(
                            "images/rsocial_thumbUp_blue.svg",
                            height: 23,
                          ),
                        )
                      else if (counter['whatever'] > counter['loved'] &&
                          counter['whatever'] > counter['liked'] &&
                          counter['whatever'] >= counter['hated'])
                        GestureDetector(
                          onTap: () {
                            buildReactionTile();
                            Navigator.push(
                                context,
                                PageTransition(
                                    // settings: RouteSettings(
                                    //     name: "Login_Page"),
                                    type: PageTransitionType.fade,
                                    child: Reaction_Info(
                                      like: likes,
                                      love: love,
                                      hate: hates,
                                      whatever: whatevers,
                                    )));
                          },
                          child: SvgPicture.asset(
                            "images/rsocial_thumbDown_blue.svg",
                            height: 23,
                          ),
                        )
                      else if (counter['hated'] > counter['liked'] &&
                          counter['hated'] > counter['loved'] &&
                          counter['hated'] > counter['whatever'])
                        GestureDetector(
                          onTap: () {
                            buildReactionTile();
                            Navigator.push(
                                context,
                                PageTransition(
                                    // settings: RouteSettings(
                                    //     name: "Login_Page"),
                                    type: PageTransitionType.fade,
                                    child: Reaction_Info(
                                      like: likes,
                                      love: love,
                                      hate: hates,
                                      whatever: whatevers,
                                    )));
                          },
                          child: SvgPicture.asset(
                            "images/rsocial_punch_blue.svg",
                            height: 23,
                          ),
                        ),
                      //SizedBox(width: 14,),
                      Icon(
                        Icons.more_vert,
                        color: colorUnselectedBottomNav,
                        size: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            widget.userPost.storyText == null
                ? Container(
                    height: 0,
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10, left: 18, right: 18),
                    child: Read_More(
                      "${widget.userPost.storyText}",
                      trimLines: 2,
                      colorClickableText: Colors.blueGrey,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: "...Show More",
                      trimExpandedText: " Show Less",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Lato",
                        color: postDesc,
                      ),
                    )
                    /*Text(
                "today was a great day with my cats! ",
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: true,
                style: GoogleFonts.lato(
                  fontSize:15,
                  color: postDesc,
                ),
                //textAlign: TextAlign.left,
              ),*/
                    ),
            widget.userPost.fileUpload.length != 0
                ? Padding(
                    padding: widget.userPost.storyText == null
                        ? EdgeInsets.only(top: 0, )
                        : EdgeInsets.only( top: 6),
                    child: Container(
                        height:
                            widget.userPost.fileUpload.length != 0 ? 350 : 0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)),
                        child: isLoading == false
                            ? (widget.userPost.fileUpload.length > 1
                                ? Swiper(
                                    loop: false,
                                    pagination: SwiperPagination(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        widget.userPost.fileUpload.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Stack(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                                // borderRadius:
                                                //     BorderRadius.circular(10),
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                      fileList[index],
                                                    ),
                                                    fit: BoxFit.cover)),
                                            height: 350,
                                          ),
                                          // Container(
                                          //   decoration: BoxDecoration(
                                          //       borderRadius: BorderRadius.only(
                                          //           bottomRight:
                                          //           Radius.circular(8)),
                                          //       color: Colors.red
                                          //           .withOpacity(0.2)),
                                          //   child: IconButton(
                                          //     icon: Icon(
                                          //       Icons.clear,
                                          //     ),
                                          //     onPressed: () {
                                          //       setState(() {
                                          //         fileList.removeAt(index);
                                          //         list.removeAt(index);
                                          //       });
                                          //     },
                                          //   ),
                                          // )
                                        ],
                                      );
                                    })
                                : Container(
                          padding: EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(
                                        //borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey.withOpacity(0.2),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              fileList[0],
                                            ),
                                            fit: BoxFit.cover)),
                                    height: 450,
                                  ))
                            : Center(
                                child: CircularProgressIndicator(),
                              )))
                : SizedBox(),
            Padding(
              padding: EdgeInsets.only(right: 15,left: 15,top: 15,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        isDisabled
                            ? Column(
                                children: <Widget>[
                                  Container(
                                    height: 23 +
                                        reactionSizeIncrease *
                                            lovedAnimation.value,
                                    width: 23 +
                                        reactionSizeIncrease *
                                            lovedAnimation.value,
                                    // child: Icon(
                                    //   MyFlutterApp.rsocial_logo_thumb_upside,
                                    //   color: rxn == "loved"
                                    //       ? colorPrimaryBlue
                                    //       : postIcons,
                                    //   size: 30,
                                    // ),
                                    child: rxn == "loved"
                                        ? SvgPicture.asset(
                                            "images/thumb_blue.svg",
                                            // color: rxn == "loved"
                                            //     ? colorPrimaryBlue
                                            //     : postIcons,
                                            height: 40,
                                          )
                                        : SvgPicture.asset(
                                            "images/rsocial_thumb_outline.svg",
                                            height: 40,
                                          ),
                                  ),
                                  SizedBox(
                                    height: 4 -
                                        reactionSizeIncrease *
                                            lovedAnimation.value,
                                  ),
                                  Text(
                                    counter['loved'].toString(),
                                    style: TextStyle(
                                      fontFamily: "Lato",
                                      fontSize: 10,
                                      color: postDesc,
                                    ),
                                  )
                                ],
                              )
                            : GestureDetector(
                                onTap: () => {
                                  reaction('loved')
                                  //widget.userPost.user.id != widget.curUser.id
                                  //  ?
                                  //     ? Fluttertoast.showToast(
                                  //         msg: "You cannot react on your own post!",
                                  //         toastLength: Toast.LENGTH_SHORT,
                                  //         gravity: ToastGravity.BOTTOM,
                                  //         fontSize: 15)
                                  //     :
                                  // (rxn == 'loved'
                                  //     ? {react("noreact"), counter['loved']--}
                                  //     : {react("loved"), counter['loved']++})
                                  // : print("not allowed")
                                },
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: 23 +
                                          reactionSizeIncrease *
                                              lovedAnimation.value,
                                      width: 23 +
                                          reactionSizeIncrease *
                                              lovedAnimation.value,

                                      // child: Icon(
                                      //   MyFlutterApp.rsocial_logo_thumb_upside,
                                      //   color: rxn == "loved"
                                      //       ? colorPrimaryBlue
                                      //       : postIcons,
                                      //   size: 35,
                                      // ),
                                      child: rxn == "loved"
                                          ? SvgPicture.asset(
                                              "images/thumb_blue.svg",
                                              // color: rxn == "loved"
                                              //     ? colorPrimaryBlue
                                              //     : postIcons,
                                              height: 40,
                                            )
                                          : SvgPicture.asset(
                                              "images/rsocial_thumb_outline.svg",
                                            ),
                                    ),
                                    SizedBox(
                                      height: 4 - 3 * lovedAnimation.value,
                                    ),
                                    Text(
                                      counter['loved'].toString(),
                                      style: TextStyle(
                                        fontFamily: "Lato",
                                        fontSize: 10,
                                        color: postDesc,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        SizedBox(
                          width: 20 -
                              lovedAnimation.value * reactionSizeIncrease -
                              likedAnimation.value * reactionSizeIncrease / 2,
                        ),
                        isDisabled
                            ? Column(
                                children: <Widget>[
                                  Container(
                                    height: 23 +
                                        reactionSizeIncrease *
                                            likedAnimation.value,
                                    width: 23 +
                                        reactionSizeIncrease *
                                            likedAnimation.value,
                                    child: rxn == "liked"
                                        ? SvgPicture.asset(
                                            "images/rsocial_thumbUp_blue.svg",
                                          )
                                        : SvgPicture.asset(
                                            "images/rsocial_thumbUp_outline.svg"),
                                  ),
                                  //Icon(Icons.thumb_up,size: 30,color:postIcons),
                                  SizedBox(
                                    height: 4 -
                                        reactionSizeIncrease *
                                            likedAnimation.value,
                                  ),
                                  Text(
                                    counter['liked'].toString(),
                                    style: TextStyle(
                                      fontFamily: "Lato",
                                      fontSize: 10,
                                      color: postDesc,
                                    ),
                                  )
                                ],
                              )
                            : GestureDetector(
                                onTap: () => {
                                  reaction('liked')
                                  // widget.userPost.user.id != widget.curUser.id
                                  //     ?
                                  //     //     ? Fluttertoast.showToast(
                                  //     //         msg: "You cannot react on your own post!",
                                  //     //         toastLength: Toast.LENGTH_SHORT,
                                  //     //         gravity: ToastGravity.BOTTOM,
                                  //     //         fontSize: 15)
                                  //     //     :
                                  //     (rxn == 'liked'
                                  //         ? {react("noreact"), counter['liked']--}
                                  //         : {react("liked"), counter['liked']++})
                                  //     : print("not allowed")
                                },
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: 23 +
                                          reactionSizeIncrease *
                                              likedAnimation.value,
                                      width: 23 +
                                          reactionSizeIncrease *
                                              likedAnimation.value,
                                      child: rxn == "liked"
                                          ? SvgPicture.asset(
                                              "images/rsocial_thumbUp_blue.svg",
                                            )
                                          : SvgPicture.asset(
                                              "images/rsocial_thumbUp_outline.svg"),
                                    ),
                                    //Icon(Icons.thumb_up,size: 30,color:postIcons),
                                    SizedBox(
                                      height: 4 -
                                          reactionSizeIncrease *
                                              likedAnimation.value,
                                    ),
                                    Text(
                                      counter['liked'].toString(),
                                      style: TextStyle(
                                        fontFamily: "Lato",
                                        fontSize: 10,
                                        color: postDesc,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        SizedBox(
                          width: 20 -
                              likedAnimation.value * reactionSizeIncrease / 2 -
                              whateverAnimation.value * reactionSizeIncrease / 2,
                        ),
                        isDisabled
                            ? Column(
                                children: <Widget>[
                                  Container(
                                      height: 23 +
                                          reactionSizeIncrease *
                                              whateverAnimation.value,
                                      width: 23 +
                                          reactionSizeIncrease *
                                              whateverAnimation.value,
                                      child: rxn == "whatever"
                                          ? SvgPicture.asset(
                                              "images/rsocial_thumbDown_blue.svg")
                                          : SvgPicture.asset(
                                              "images/rsocial_thumbDown_outline.svg")),
                                  SizedBox(
                                    height: 4 -
                                        reactionSizeIncrease *
                                            whateverAnimation.value,
                                  ),
                                  Text(
                                    counter['whatever'].toString(),
                                    style: TextStyle(
                                      fontFamily: "Lato",
                                      fontSize: 10,
                                      color: postDesc,
                                    ),
                                  )
                                ],
                              )
                            : GestureDetector(
                                onTap: () => {
                                  reaction('whatever')
                                  // widget.userPost.user.id != widget.curUser.id
                                  //     ?
                                  //     //     ? Fluttertoast.showToast(
                                  //     //         msg: "You cannot react on your own post!",
                                  //     //         toastLength: Toast.LENGTH_SHORT,
                                  //     //         gravity: ToastGravity.BOTTOM,
                                  //     //         fontSize: 15)
                                  //     //     :
                                  //     (rxn == 'whatever'
                                  //         ? {
                                  //             react("noreact"),
                                  //             counter['whatever']--
                                  //           }
                                  //         : {
                                  //             react("whatever"),
                                  //             counter['whatever']++
                                  //           })
                                  //     : print("not allowed")
                                },
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                        height: 23 +
                                            reactionSizeIncrease *
                                                whateverAnimation.value,
                                        width: 23 +
                                            reactionSizeIncrease *
                                                whateverAnimation.value,
                                        child: rxn == "whatever"
                                            ? SvgPicture.asset(
                                                "images/rsocial_thumbDown_blue.svg")
                                            : SvgPicture.asset(
                                                "images/rsocial_thumbDown_outline.svg")),
                                    SizedBox(
                                      height: 4 -
                                          reactionSizeIncrease *
                                              whateverAnimation.value,
                                    ),
                                    Text(
                                      counter['whatever'].toString(),
                                      style: TextStyle(
                                        fontFamily: "Lato",
                                        fontSize: 10,
                                        color: postDesc,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        SizedBox(
                          width: 20 -
                              hatedAnimation.value * reactionSizeIncrease -
                              whateverAnimation.value * reactionSizeIncrease / 2,
                        ),
                        isDisabled
                            ? Column(
                                children: <Widget>[
                                  Container(
                                    height: 23 +
                                        reactionSizeIncrease *
                                            hatedAnimation.value,
                                    width: 23 +
                                        reactionSizeIncrease *
                                            hatedAnimation.value,
                                    child: rxn == "hated"
                                        ? SvgPicture.asset(
                                            "images/rsocial_punch_blue.svg",
                                            fit: BoxFit.cover,
                                          )
                                        : SvgPicture.asset(
                                            "images/rsocial_punch_outline.svg"),
                                  ),
                                  SizedBox(
                                    height: 4 -
                                        reactionSizeIncrease *
                                            hatedAnimation.value,
                                  ),
                                  Text(
                                    counter['hated'].toString(),
                                    style: TextStyle(
                                      fontFamily: "Lato",
                                      fontSize: 10,
                                      color: postDesc,
                                    ),
                                  )
                                ],
                              )
                            : GestureDetector(
                                onTap: () => {
                                  reaction('hated')
                                  // rxn == 'hated'
                                  //     ? reaction('noreact')
                                  //     : reaction('hated')
                                  // widget.userPost.user.id != widget.curUser.id
                                  //     ?
                                  //     //     ? Fluttertoast.showToast(
                                  //     //         msg: "You cannot react on your own post!",
                                  //     //         toastLength: Toast.LENGTH_SHORT,
                                  //     //         gravity: ToastGravity.BOTTOM,
                                  //     //         fontSize: 15)
                                  //     //     :
                                  //     (rxn == 'hated'
                                  //         ? {react("noreact"), counter['hated']--}
                                  //         : {react("hated"), counter['hated']++})
                                  //     : print("not allowed")
                                },
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: 23 +
                                          reactionSizeIncrease *
                                              hatedAnimation.value,
                                      width: 23 +
                                          reactionSizeIncrease *
                                              hatedAnimation.value,
                                      child: rxn == "hated"
                                          ? SvgPicture.asset(
                                              "images/rsocial_punch_blue.svg",
                                              fit: BoxFit.cover,
                                            )
                                          : SvgPicture.asset(
                                              "images/rsocial_punch_outline.svg"),
                                    ),
                                    SizedBox(
                                      height: 4 -
                                          reactionSizeIncrease *
                                              hatedAnimation.value,
                                    ),
                                    Text(
                                      counter['hated'].toString(),
                                      style: TextStyle(
                                        fontFamily: "Lato",
                                        fontSize: 10,
                                        color: postDesc,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20 - hatedController.value * reactionSizeIncrease,
                  ),
                  //Container(),

                  Column(
                    children: <Widget>[
                      Container(
                        height: 23,
                        width: 23,
                        child: SvgPicture.asset(
                          "images/share.svg",
                          color: postIcons,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Share",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontSize: 10,
                            color: postDesc,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
