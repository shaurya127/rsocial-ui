import 'dart:convert';
import 'dart:core';
import 'dart:io';

// import 'package:audioplayers/audio_cache.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';

//import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/display_post.dart';
import 'package:rsocial2/Screens/invested_with.dart';

import 'package:rsocial2/Screens/login_page.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/Screens/reaction_info.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'package:rsocial2/Widgets/post_tile.dart';
import 'package:rsocial2/Widgets/request_tile.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import '../contants/config.dart';
import '../contants/constants.dart';
import '../deep_links.dart';
import '../functions.dart';
import '../helper.dart';
import '../model/post.dart';
import '../model/reaction_model.dart';
import '../read_more.dart';
import '../model/user.dart';
import 'package:http/http.dart' as http;
import '../Widgets/video_player_landing.dart' as video;
import '../controller.dart';
//Map<String, Map<String, int>> m = new Map();

class InvestPostTile extends StatefulWidget {
  Post userPost;
  var photoUrl;
  User curUser;
  Function reactionCallback;
  ReusableVideoListController reusableVideoListController;
  final VoidCallback onPressDelete;
  InvestPostTile({
    @required this.curUser,
    @required this.reusableVideoListController,
    this.userPost,
    this.photoUrl,
    this.reactionCallback,
    this.onPressDelete,
  });
  @override
  _InvestPostTileState createState() => _InvestPostTileState();
}

class _InvestPostTileState extends State<InvestPostTile>
    with TickerProviderStateMixin {
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
  bool _isCreatingLink = false;
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
    counter = {'loved': 0, 'liked': 0, 'whatever': 0, 'hated': 0, 'noreact': 0};
    for (int i = 0; i < widget.userPost.reactedBy.length; i++) {
      User user = widget.userPost.reactedBy[i];
      String rt = user.reactionType;
      counter[rt]++;

      if (user.id == (curUser != null ? curUser.id : savedUser.id)) {
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
    // audioPlayer = new AudioPlayer();
    // audioCache = new AudioCache(fixedPlayer: audioPlayer);
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

  showProfile(BuildContext context, User user, String photourl) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          currentUser: widget.curUser,
          photoUrl: photourl,
          user: user,
        ),
      ),
    );
    setState(() {});
  }

  react(String reactn) async {
    setState(() {
      isDisabled = true;
      // audioCache.play("click.mp3");
      String prvrxn = rxn;
      rxn = reactn;
      counter[prvrxn]--;
      counter[rxn]++;
      //print(widget.userPost.profit);
      m[widget.userPost.id] = {reactn: counter[reactn]};
      //print("updating mp");
      mp[widget.userPost.id] = counter;
      prft[widget.userPost.id] = widget.userPost.profit;
    });
    var user, token;
    try {
      user = auth.FirebaseAuth.instance.currentUser;
      token = await user.getIdToken();
    } catch (e) {
      setState(() {
        isDisabled = false;
      });
      return;
    }
    Reaction reaction = Reaction(
        id: (curUser != null
            ? (curUser != null ? curUser.id : savedUser.id)
            : savedUser.id),
        storyId: widget.userPost.id,
        reactionType: reactn);

    print(reaction.id);
    print(reaction.reactionType);
    print(reaction.storyId);
    print(reactn);

    //print(jsonEncode(reaction.toJson()));
    //print(token);
    var response = await putFunc(
        url: storyEndPoint + 'react',
        token: token,
        body: jsonEncode(reaction.toJson()));

    if (response == null) {
      setState(() {
        isDisabled = false;
      });
      return;
    }

    print("This is the story reaction");
    print(response.statusCode);

    if (response.statusCode == 200) {
      var responseMessage;
      try {
        responseMessage =
            jsonDecode((jsonDecode(response.body))['body'])['message'];

        setState(() {
          prft[widget.userPost.id] = responseMessage["PresentValue"].toString();
        });
      } catch (e) {
        setState(() {
          isDisabled = false;
        });
        return;
      }
      getReactions();

      if (widget.reactionCallback != null) widget.reactionCallback();
      setState(() {});
    }
    //print("hello hello");
    setState(() {
      isDisabled = false;
    });
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
        react(reaction);
        //counter[reaction]++;
      }
    } else
      Fluttertoast.showToast(
          msg: "You cannot react on your own post",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);

    // print("state is set");
    // print(counter[reaction]);
    // setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    final transformationController = TransformationController();
    if (m.containsKey(widget.userPost.id)) {
      Map<String, int> map = m[widget.userPost.id];
      Map<String, int> map2 = mp[widget.userPost.id];
      for (var key in map.keys) rxn = key;
      print("my reaction is now $rxn");
      counter = map2;
      counter[rxn] = map[rxn];
      widget.userPost.profit = prft[widget.userPost.id];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
        //margin: EdgeInsets.only(top: 5,bottom: 5),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        EdgeInsets.only(left: 0, right: -35, bottom: 0),
                    leading: GestureDetector(
                      onTap: () => showProfile(context, widget.userPost.user,
                          widget.userPost.user.photoUrl),
                      child: CircleAvatar(
                        backgroundImage: widget.userPost.user.photoUrl != ""
                            ? NetworkImage(widget.userPost.user.photoUrl)
                            : AssetImage("images/avatar.jpg"),
                      ),
                    ),
                    title: Text(
                      "${widget.userPost.user.fname} ${widget.userPost.user.lname}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Lato",
                        fontSize: 14,
                        color: nameCol,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: <Widget>[
                            widget.userPost.investedWithUser != []
                                ? Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () => showProfile(
                                            context,
                                            widget.userPost.investedWithUser[0],
                                            widget.userPost.user.photoUrl),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Invested " +
                                                  investAmountFormatting(
                                                      double.parse(widget
                                                              .userPost
                                                              .investedAmount)
                                                          .floor()) +
                                                  " with ",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: "Lato",
                                                fontSize: 12,
                                                color: colorGreyTint,
                                              ),
                                            ),
                                            Text(
                                              "${widget.userPost.investedWithUser[0].fname}",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: "Lato",
                                                  fontSize: 12,
                                                  color: colorPrimaryBlue,
                                                  decoration:
                                                      TextDecoration.underline),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // GestureDetector(
                                      //   onTap: () {
                                      //     Navigator.push(
                                      //         context,
                                      //         PageTransition(
                                      //           // settings: RouteSettings(
                                      //           //     name: "Login_Page"),
                                      //           type: PageTransitionType.fade,
                                      //           child: Profile(
                                      //             currentUser: widget.curUser,
                                      //             photoUrl:
                                      //                 investedWithUser[0].photoUrl,
                                      //             user: investedWithUser[0],
                                      //           ),
                                      //         ));
                                      //   },
                                      //   child: Text(
                                      //     // (widget.userPost.investedWithUser[0]
                                      //     //                     .fname +
                                      //     //                 " " +
                                      //     //                 widget
                                      //     //                     .userPost
                                      //     //                     .investedWithUser[0]
                                      //     //                     .lname)
                                      //     //             .length <
                                      //     //         11
                                      //     //     ? "${widget.userPost.investedWithUser[0].fname} ${widget.userPost.investedWithUser[0].lname}"
                                      //     //     : (widget.userPost.investedWithUser[0]
                                      //     //                     .fname +
                                      //     //                 " " +
                                      //     //                 widget
                                      //     //                     .userPost
                                      //     //                     .investedWithUser[0]
                                      //     //                     .lname)
                                      //     //             .substring(0, 7) +
                                      //     //         ".",
                                      //     "${widget.userPost.investedWithUser.length} people",
                                      //     style: TextStyle(
                                      //       fontFamily: "Lato",
                                      //       fontSize: 12,
                                      //       color: subtitile,
                                      //     ),
                                      //   ),
                                      // )
                                    ],
                                  )
                                : Text(
                                    "Invested " +
                                        investAmountFormatting(double.parse(
                                                widget.userPost.investedAmount)
                                            .floor()) +
                                        " alone",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: "Lato",
                                      fontSize: 12,
                                      color: colorGreyTint,
                                    ),
                                  ),
                            SizedBox(
                              width: 2,
                            ),
                            // widget.userPost.investedWithUser.length >= 2
                            //     ? GestureDetector(
                            //         onTap: () {
                            //           Navigator.push(
                            //               context,
                            //               PageTransition(
                            //                   // settings: RouteSettings(
                            //                   //     name: "Login_Page"),
                            //                   type: PageTransitionType.fade,
                            //                   child: InvestedWithPage(
                            //                     investedWithUser:
                            //                         this.investedWithUser,
                            //                     curUser: widget.curUser,
                            //                   )));
                            //         },
                            //         child: Text(
                            //           "+ ${widget.userPost.investedWithUser.length - 1}",
                            //           style: TextStyle(
                            //             fontFamily: "Lato",
                            //             fontSize: 12,
                            //             color: colorButton,
                            //           ),
                            //         ),
                            //       )
                            //     : SizedBox.shrink()
                          ],
                        ),
                        Text(
                          "${widget.userPost.createdOn}",
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontFamily: "Lato",
                            fontSize: 12,
                            color: colorGreyTint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //SizedBox(width: 1,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: <Widget>[
                    //     Row(
                    //       children: <Widget>[
                    //         SvgPicture.asset(
                    //           "images/coins.svg",
                    //           color: colorCoins,
                    //         ),
                    //         Container(
                    //           child: Text(
                    //             "Invested",
                    //             style: TextStyle(
                    //                 fontFamily: "Lato",
                    //                 fontSize: 12,
                    //                 color: subtitile),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     SizedBox(
                    //       height: 6,
                    //     ),
                    //     Container(
                    //       child: Text(
                    //         "${widget.userPost.investedAmount}",
                    //         style: TextStyle(
                    //           fontFamily: "Lato",
                    //           fontSize: 12,
                    //           color: Color(0xff4DBAE6),
                    //         ),
                    //       ),
                    //       //transform: Matrix4.translationValues(-35, 0.0, 0.0),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(
                      width: 0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                // settings: RouteSettings(
                                //     name: "Login_Page"),
                                type: PageTransitionType.fade,
                                child: Reaction_Info(
                                  counter: counter,
                                  postId: widget.userPost.id,
                                )));
                      },
                      child: Column(
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
                                //transform: Matrix4.translationValues(-38, 0.0, 0.0),
                                child: Text(
                                  kPostTileGain,
                                  style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: 12,
                                    color: colorGreyTint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Container(
                            child: Text(
                              double.parse(widget.userPost.profit)
                                  .round()
                                  .toString(),
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 12,
                                color: double.parse(widget.userPost.profit) >= 0
                                    ? colorProfitPositive
                                    : colorProfitNegative,
                              ),
                              //     TextStyle(
                              //     fontSize: 12,
                              //     color: Color(0xff37B44B)
                              // ),
                            ),
                            //transform: Matrix4.translationValues(-35, 0.0, 0.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 14,
                    ),

                    // if (counter['loved'] == 0 &&
                    //     counter['liked'] == 0 &&
                    //     counter['whatever'] == 0 &&
                    //     counter['hated'] == 0)
                    //   SizedBox()
                    // else if (counter['loved'] >= counter['liked'] &&
                    //     counter['loved'] >= counter['whatever'] &&
                    //     counter['loved'] >= counter['hated'])
                    //   GestureDetector(
                    //     onTap: () {
                    //       buildReactionTile();
                    //       Navigator.push(
                    //           context,
                    //           PageTransition(
                    //               // settings: RouteSettings(
                    //               //     name: "Login_Page"),
                    //               type: PageTransitionType.fade,
                    //               child: Reaction_Info(
                    //                 like: likes,
                    //                 love: love,
                    //                 hate: hates,
                    //                 whatever: whatevers,
                    //               )));
                    //     },
                    //     child: SvgPicture.asset(
                    //       "images/thumb_blue.svg",
                    //       //color: colorPrimaryBlue,
                    //       height: 23,
                    //     ),
                    //   )
                    // else if (counter['liked'] > counter['loved'] &&
                    //     counter['liked'] >= counter['whatever'] &&
                    //     counter['liked'] >= counter['hated'])
                    //   GestureDetector(
                    //     onTap: () {
                    //       buildReactionTile();
                    //       Navigator.push(
                    //           context,
                    //           PageTransition(
                    //               // settings: RouteSettings(
                    //               //     name: "Login_Page"),
                    //               type: PageTransitionType.fade,
                    //               child: Reaction_Info(
                    //                 like: likes,
                    //                 love: love,
                    //                 hate: hates,
                    //                 whatever: whatevers,
                    //               )));
                    //     },
                    //     child: SvgPicture.asset(
                    //       "images/rsocial_thumbUp_blue.svg",
                    //       height: 23,
                    //     ),
                    //   )
                    // else if (counter['whatever'] > counter['loved'] &&
                    //     counter['whatever'] > counter['liked'] &&
                    //     counter['whatever'] >= counter['hated'])
                    //   GestureDetector(
                    //     onTap: () {
                    //       buildReactionTile();
                    //       Navigator.push(
                    //           context,
                    //           PageTransition(
                    //               // settings: RouteSettings(
                    //               //     name: "Login_Page"),
                    //               type: PageTransitionType.fade,
                    //               child: Reaction_Info(
                    //                 like: likes,
                    //                 love: love,
                    //                 hate: hates,
                    //                 whatever: whatevers,
                    //               )));
                    //     },
                    //     child: SvgPicture.asset(
                    //       "images/rsocial_thumbDown_blue.svg",
                    //       height: 23,
                    //     ),
                    //   )
                    // else if (counter['hated'] > counter['liked'] &&
                    //     counter['hated'] > counter['loved'] &&
                    //     counter['hated'] > counter['whatever'])
                    //   GestureDetector(
                    //     onTap: () {
                    //       buildReactionTile();
                    //       Navigator.push(
                    //           context,
                    //           PageTransition(
                    //               // settings: RouteSettings(
                    //               //     name: "Login_Page"),
                    //               type: PageTransitionType.fade,
                    //               child: Reaction_Info(
                    //                 like: likes,
                    //                 love: love,
                    //                 hate: hates,
                    //                 whatever: whatevers,
                    //               )));
                    //     },
                    //     child: SvgPicture.asset(
                    //       "images/rsocial_punch_blue.svg",
                    //       height: 23,
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),
                    //SizedBox(width: 14,),
                    PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        size: 30,
                        color: colorGreyTint,
                      ),
                      itemBuilder: (_) => <PopupMenuItem>[
                        new PopupMenuItem(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          // settings: RouteSettings(
                                          //     name: "Login_Page"),
                                          type: PageTransitionType.fade,
                                          child: DisplayPost(
                                            postId: widget.userPost.id,
                                          )));
                                },
                                child: new Text('View post'))),
                        new PopupMenuItem(
                            child: GestureDetector(
                                onTap: () {
                                  //buildReactionTile();
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          // settings: RouteSettings(
                                          //     name: "Login_Page"),
                                          type: PageTransitionType.fade,
                                          child: Reaction_Info(
                                            counter: counter,
                                            postId: widget.userPost.id,
                                          )));
                                },
                                child: new Text('Reactions'))),
                        if (widget.userPost.user.id ==
                            (curUser != null ? curUser.id : savedUser.id))
                          new PopupMenuItem(
                              child: GestureDetector(
                                  onTap: widget.onPressDelete,
                                  child: new Text('Delete')))
                      ],
                    )
                  ],
                ),
              ],
            ),
            widget.userPost.storyText == null
                ? Container(
                    height: 0,
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                        top: 7, bottom: 3, left: 3, right: 3),
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      linkStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                      text: widget.userPost.storyText,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Lato",
                          color: colorUnselectedBottomNav),
                    ),
                    // Read_More(
                    //   "${widget.userPost.storyText}",
                    //   trimLines: 2,
                    //   colorClickableText: Colors.blueGrey,
                    //   trimMode: TrimMode.Line,
                    //   trimCollapsedText: "...Show More",
                    //   trimExpandedText: " Show Less",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontFamily: "Lato",
                    //     color: colorUnselectedBottomNav,
                    //   ),
                    // )
                    /*Text(

                "today was a great day with my cats! ",
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: true,
                style: GoogleFonts.lato(
                  fontSize:15,
                  color: colorUnselectedBottomNav ,
                ),
                //textAlign: TextAlign.left,
              ),*/
                  ),
            widget.userPost.fileUpload.length != 0
                ? Padding(
                    padding: widget.userPost.storyText == null
                        ? EdgeInsets.only(top: 0, bottom: 15)
                        : EdgeInsets.only(bottom: 15, top: 6),
                    child: Container(
                        constraints: BoxConstraints(
                          maxHeight:
                              widget.userPost.fileUpload.length != 0 ? 300 : 0,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)),
                        child: isLoading == false
                            ? (widget.userPost.fileUpload.length > 1
                                ? InteractiveViewer(
                                    transformationController:
                                        transformationController,
                                    onInteractionEnd: (details) {
                                      setState(() {
                                        transformationController
                                            .toScene(Offset.zero);
                                      });
                                    },
                                    //boundaryMargin: EdgeInsets.all(20.0),
                                    minScale: 0.1,
                                    maxScale: 2,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Swiper(
                                          loop: false,
                                          pagination: SwiperPagination(
                                            builder: DotSwiperPaginationBuilder(
                                              color: Colors.grey,
                                              activeColor: colorButton,
                                              size: 10.0,
                                              activeSize: 12.0,
                                              space: 5.0,
                                            ),
                                          ),
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              widget.userPost.fileUpload.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                showDialogFunc(
                                                    context, fileList, index);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,

                                                  // image: DecorationImage(
                                                  //   image: NetworkImage(
                                                  //     fileList[index],
                                                  //   ),
                                                  //   fit: BoxFit.contain,
                                                  // ),
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: fileList[index],
                                                  fit: BoxFit.contain,
                                                  width: double.infinity,
                                                  placeholder: (ctx, _) => Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  )
                                // Swiper(
                                //     loop: false,
                                //     pagination: SwiperPagination(
                                //       builder: DotSwiperPaginationBuilder(
                                //           color: Colors.grey,
                                //           activeColor: Colors.red,
                                //           size: 13.0,
                                //           activeSize: 15.0,
                                //           space: 5.0),
                                //     ),
                                //     scrollDirection: Axis.horizontal,
                                //     itemCount:
                                //         widget.userPost.fileUpload.length,
                                //     itemBuilder:
                                //         (BuildContext context, int index) {
                                //       return Stack(
                                //         children: <Widget>[
                                //           InteractiveViewer(
                                //             transformationController:
                                //                 transformationController,
                                //             onInteractionEnd: (details) {
                                //               setState(() {
                                //                 transformationController
                                //                     .toScene(Offset.zero);
                                //               });
                                //             },
                                //             //boundaryMargin: EdgeInsets.all(20.0),
                                //             minScale: 0.1,
                                //             maxScale: 2,
                                //             child: ClipRRect(
                                //               borderRadius:
                                //                   BorderRadius.circular(10),
                                //               child: Container(
                                //                 decoration: BoxDecoration(
                                //                     color: Colors.grey
                                //                         .withOpacity(0.2),
                                //                     image: DecorationImage(
                                //                         image: NetworkImage(
                                //                           fileList[index],
                                //                         ),
                                //                         fit: BoxFit.cover)),
                                //                 height: 300,
                                //               ),
                                //             ),
                                //           ),
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
                                //     ],
                                //   );
                                // })
                                : widget.userPost.fileUpload[0].endsWith(".mp4")
                                    ? video.ReusableVideoListWidget(
                                        videoListController:
                                            widget.reusableVideoListController,
                                        videoListData: video.VideoListData(
                                          "TEST",
                                          widget.userPost.fileUpload[0],
                                        ),
                                        //"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"),
                                        canBuildVideo: () => true,
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          showDialogFunc(context, fileList, 0);
                                        },
                                        child: InteractiveViewer(
                                          transformationController:
                                              transformationController,
                                          onInteractionEnd: (details) {
                                            setState(() {
                                              transformationController
                                                  .toScene(Offset.zero);
                                            });
                                          },
                                          minScale: 0.1,
                                          maxScale: 2,
                                          child: Container(
                                            child: CachedNetworkImage(
                                              imageUrl: fileList[0],
                                              fit: BoxFit.contain,
                                              width: double.infinity,
                                              placeholder: (ctx, _) => Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              // image: DecorationImage(
                                              //     image: NetworkImage(
                                              //       fileList[0],
                                              //     ),
                                              //     fit: BoxFit.contain),
                                            ),
                                          ),
                                        ),
                                      ))

                            //  InteractiveViewer(
                            //     transformationController:
                            //         transformationController,
                            //     onInteractionEnd: (details) {
                            //       setState(() {
                            //         transformationController
                            //             .toScene(Offset.zero);
                            //       });
                            //     },
                            //     //boundaryMargin: EdgeInsets.all(20.0),
                            //     minScale: 0.1,
                            //     maxScale: 2,
                            //     child: ClipRRect(
                            //       borderRadius:
                            //           BorderRadius.circular(10),
                            //       child: Container(
                            //         decoration: BoxDecoration(
                            //             color: Colors.grey
                            //                 .withOpacity(0.2),
                            //             image: DecorationImage(
                            //                 image: NetworkImage(
                            //                   fileList[0],
                            //                 ),
                            //                 fit: BoxFit.cover)),
                            //         height: 300,
                            //       ),
                            //     ),
                            //   ))
                            : Center(
                                child: CircularProgressIndicator(),
                              )))
                : SizedBox.shrink(),
            SizedBox(
              height: widget.userPost.fileUpload.length == 0 ? 10 : 0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    child: widget.userPost.canReact
                        ? Row(
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
                                            color: colorUnselectedBottomNav,
                                          ),
                                        )
                                      ],
                                    )
                                  : GestureDetector(
                                      onTap: () => {
                                        reaction('loved')
                                        // widget.userPost.user.id != widget.curUser.id
                                        //     ?
                                        // //     ? Fluttertoast.showToast(
                                        // //         msg: "You cannot react on your own post!",
                                        // //         toastLength: Toast.LENGTH_SHORT,
                                        // //         gravity: ToastGravity.BOTTOM,
                                        // //         fontSize: 15)
                                        // //     :
                                        // (rxn == 'loved'
                                        //     ? {react("noreact"), counter['loved']--}
                                        //     : {react("loved"), counter['loved']++})
                                        //     : print("not allowed")
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
                                            height:
                                                4 - 3 * lovedAnimation.value,
                                          ),
                                          Text(
                                            counter['loved'].toString(),
                                            style: TextStyle(
                                              fontFamily: "Lato",
                                              fontSize: 10,
                                              color: colorUnselectedBottomNav,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                              SizedBox(
                                width: 20 -
                                    lovedAnimation.value *
                                        reactionSizeIncrease -
                                    likedAnimation.value *
                                        reactionSizeIncrease /
                                        2,
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
                                            color: colorUnselectedBottomNav,
                                          ),
                                        )
                                      ],
                                    )
                                  : GestureDetector(
                                      onTap: () => {
                                        reaction('liked')
                                        // widget.userPost.user.id != widget.curUser.id
                                        //     ?
                                        // //     ? Fluttertoast.showToast(
                                        // //         msg: "You cannot react on your own post!",
                                        // //         toastLength: Toast.LENGTH_SHORT,
                                        // //         gravity: ToastGravity.BOTTOM,
                                        // //         fontSize: 15)
                                        // //     :
                                        // (rxn == 'liked'
                                        //     ? {react("noreact"), counter['liked']--}
                                        //     : {react("liked"), counter['liked']++})
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
                                              color: colorUnselectedBottomNav,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                              SizedBox(
                                width: 20 -
                                    likedAnimation.value *
                                        reactionSizeIncrease /
                                        2 -
                                    whateverAnimation.value *
                                        reactionSizeIncrease /
                                        2,
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
                                            color: colorUnselectedBottomNav,
                                          ),
                                        )
                                      ],
                                    )
                                  : GestureDetector(
                                      onTap: () => {
                                        reaction('whatever')
                                        // widget.userPost.user.id != widget.curUser.id
                                        //     ?
                                        // //     ? Fluttertoast.showToast(
                                        // //         msg: "You cannot react on your own post!",
                                        // //         toastLength: Toast.LENGTH_SHORT,
                                        // //         gravity: ToastGravity.BOTTOM,
                                        // //         fontSize: 15)
                                        // //     :
                                        // (rxn == 'whatever'
                                        //     ? {
                                        //   react("noreact"),
                                        //   counter['whatever']--
                                        // }
                                        //     : {
                                        //   react("whatever"),
                                        //   counter['whatever']++
                                        // })
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
                                              color: colorUnselectedBottomNav,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                              SizedBox(
                                width: 20 -
                                    hatedAnimation.value *
                                        reactionSizeIncrease -
                                    whateverAnimation.value *
                                        reactionSizeIncrease /
                                        2,
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
                                                  "images/rsocial_punch_outline.svg",
                                                  fit: BoxFit.cover,
                                                ),
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
                                            color: colorUnselectedBottomNav,
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
                                        // //     ? Fluttertoast.showToast(
                                        // //         msg: "You cannot react on your own post!",
                                        // //         toastLength: Toast.LENGTH_SHORT,
                                        // //         gravity: ToastGravity.BOTTOM,
                                        // //         fontSize: 15)
                                        // //     :
                                        // (rxn == 'hated'
                                        //     ? {react("noreact"), counter['hated']--}
                                        //     : {react("hated"), counter['hated']++})
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
                                                    "images/rsocial_punch_outline.svg",
                                                    fit: BoxFit.cover,
                                                  ),
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
                                              color: colorUnselectedBottomNav,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                            ],
                          )
                        : Container(
                            child: Text(
                              "Investment Matured",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.bold,
                                color: colorUnselectedBottomNav,
                              ),
                            ),
                          )),
                SizedBox(
                  width: 20 - hatedController.value * reactionSizeIncrease,
                ),
                //Container(),

                Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: !_isCreatingLink
                          ? () async {
                              final Uri uri =
                                  await makeLink('postid', widget.userPost);
                              String sender = uri.queryParameters['postid'];
                              print("link is: $uri \n sent by: $sender");

                              final RenderBox box = context.findRenderObject();
                              share(uri);
                            }
                          : null,
                      child: Container(
                        height: 23,
                        width: 23,
                        child: SvgPicture.asset(
                          "images/share.svg",
                          color: postIcons,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Share",
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 10,
                          color: colorUnselectedBottomNav,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Uri> makeLink(String type, Post post) async {
    Uri uri;
    setState(() {
      _isCreatingLink = true;
    });
    uri = await createDynamicLink(type, post);
    setState(() {
      _isCreatingLink = false;
    });
    return uri;
  }

  Future<void> share(Uri uri) async {
    final RenderBox box = context.findRenderObject();
    Share.share(
      "Hey! Checkout this post ${uri.toString()}",
      subject: "Checkout this post on RSocial",
      sharePositionOrigin: box.localToGlobal(
            Offset.zero,
          ) &
          box.size,
    );
    // await FlutterShare.share(
    //     title: 'Hey! checkout this post',
    //     //text: '${widget.userPost.user.fname} on RSocial',
    //     linkUrl: uri.toString(),
    //     chooserTitle: 'Share this post with');
  }
}
