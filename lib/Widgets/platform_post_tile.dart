import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/Widgets/post_tile.dart';
import 'package:rsocial2/Widgets/request_tile.dart';
import 'package:http/http.dart' as http;
import '../user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Screens/display_post.dart';
import '../auth.dart';
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
import 'package:package_info/package_info.dart';

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

class PlatformPostTile extends StatefulWidget {
  Post userPost;
  var photoUrl;
  User curUser;
  PlatformPostTile({@required this.curUser, this.userPost, this.photoUrl});
  @override
  _PlatformPostTileState createState() => _PlatformPostTileState();
}

class _PlatformPostTileState extends State<PlatformPostTile>
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
  bool _isCreatingLink = false;
  bool _showPreview = false;
  String _image;

  getReactions() {
    print(rxn);
    loved = [];
    liked = [];
    whatever = [];
    hated = [];
    counter = {'loved': 0, 'liked': 0, 'whatever': 0, 'hated': 0, 'noreact': 0};
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
      //setState(() {
        final jsonUser = jsonDecode(response.body);
        var body = jsonUser['body'];
        var body1 = jsonDecode(body);
        print("body is $body");

        //print(body1);
        var msg = body1['message'];
        setState(() {
          prft[widget.userPost.id] = msg["PresentValue"].toString();
        });
        // if (widget.userPost.storyType == 'Wage')
        //   widget.userPost = Post.fromJsonW(msg);
        // else
        //   widget.userPost = Post.fromJsonI(msg);
        //
        // getReactions();
        // print(widget.userPost.profit);
        // m[widget.userPost.id] = {reactn: counter[reactn]};
        // //print("updating mp");
        // mp[widget.userPost.id] = counter;
        // prft[widget.userPost.id] = widget.userPost.profit;
      //});
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
        //photourl: loved[i].photoUrl,
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
        // photourl: liked[i].photoUrl,
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
        //photourl: hated[i].photoUrl,
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
        //photourl: whatever[i].photoUrl,
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
        //counter[reaction]++;
        react(reaction);
      }
    } else
      print("not allowed");

    // print("state is set");
    // print(counter[reaction]);
    // setState(() {});
    return;
  }

  Future<Uri> createDynamicLink() async {
    var queryParameters = {
      'postid': widget.userPost.id.toString(),
    };

    //Uri link =Uri.http('flutters.page.link', 'invites', queryParameters);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
        // This should match firebase but without the username query param
        uriPrefix: 'https://rsocial.page.link',
        // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
        link: Uri.parse(
            'https://rsocial.page.link/posts?postid=${widget.userPost.id}&'),
        androidParameters: AndroidParameters(
          packageName: packageInfo.packageName,
          minimumVersion: 0,
        ),

        // dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        //   shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
        // ),

        iosParameters: IosParameters(
          bundleId: packageInfo.packageName,
          minimumVersion: '0',
          appStoreId: '123456789',
        ),
        googleAnalyticsParameters: GoogleAnalyticsParameters(
          campaign: 'example-promo',
          medium: 'social',
          source: 'orkut',
        ),
        itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
          providerToken: '123456',
          campaignToken: 'example-promo',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
            title: '${widget.userPost.user.fname} on RSocial',
            // description: event.post?.excerpt,
            imageUrl: widget.userPost.fileUpload.isNotEmpty
                ? Uri.parse(widget.userPost.fileUpload[0])
                : Uri.parse(widget.userPost.user.photoUrl)),
        navigationInfoParameters:
            NavigationInfoParameters(forcedRedirectEnabled: true));

    final link = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink =
        await DynamicLinkParameters.shortenUrl(
      link,
      DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );
    setState(() {
      //_linkMessage = url;
      //print(link.queryParameters['sender']);
      _isCreatingLink = false;
    });
    //print(shortenedLink.shortUrl.queryParameters['postid']);
    return shortenedLink.shortUrl;
  }

  Future<void> share(Uri uri) async {
    await FlutterShare.share(
        title: 'Hey! checkout this post',
        //text: '${widget.userPost.user.fname} on RSocial',
        linkUrl: uri.toString(),
        chooserTitle: 'Share this post with');
  }

  @override
  Widget build(BuildContext context) {
    final transformationController = TransformationController();
    if (m.containsKey(widget.userPost.id)) {
      Map<String, int> map = m[widget.userPost.id];
      Map<String, int> map2 = mp[widget.userPost.id];
      for (var key in map.keys) rxn = key;
      // print("my reaction is now $rxn ${counter[rxn]}");
      setState(() {
        counter = map2;
        counter[rxn] = map[rxn];
        widget.userPost.profit = prft[widget.userPost.id];
      });
    }
    //print("This is build function");

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
        //margin: EdgeInsets.only(top: 5,bottom: 5),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 10),
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
                                backgroundImage:
                                    widget.userPost.user.photoUrl != ""
                                        ? NetworkImage(
                                            widget.userPost.user.photoUrl)
                                        : AssetImage("images/avatar.jpg"),
                              ),
                            ),
                            title: Text(
                              "${widget.userPost.user.fname} ${widget.userPost.user.lname}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Lato",
                                fontSize: 14,
                                color: nameCol,
                              ),
                            ),
                            subtitle: Text(
                              "${widget.userPost.createdOn}",
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                fontFamily: "Lato",
                                fontSize: 12,
                                color: subtitile,
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
                                backgroundImage:
                                    widget.userPost.user.photoUrl != ""
                                        ? NetworkImage(
                                            widget.userPost.user.photoUrl)
                                        : AssetImage("images/avatar.jpg"),
                              ),
                            ),

                            //),
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
                                                onTap: () =>showProfile(context, widget.userPost.investedWithUser[0], widget.userPost.user.photoUrl),
                                                child: Text(
                                                  "Invested ${(int.parse(widget.userPost.investedAmount) / 100) % 10 == 0 ? (widget.userPost.investedAmount[0]) : (double.parse(widget.userPost.investedAmount) / 1000).toString()} k with ${widget.userPost.investedWithUser[0].fname}",
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: "Lato",
                                                    fontSize: 12,
                                                    color: subtitile,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            "Invested ${(int.parse(widget.userPost.investedAmount) / 100) % 10 == 0 ? (widget.userPost.investedAmount[0]) : (double.parse(widget.userPost.investedAmount) / 1000).toString()} k alone",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: "Lato",
                                              fontSize: 12,
                                              color: subtitile,
                                            ),
                                          ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                  ],
                                ),
                                Text(
                                  "${widget.userPost.createdOn}",
                                  style: TextStyle(
                                    //fontWeight: FontWeight.bold,
                                    fontFamily: "Lato",
                                    fontSize: 12,
                                    color: subtitile,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // //SizedBox(width: 1,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // widget.userPost.storyType == "Wage"
                      //     ? SizedBox()
                      //     : SizedBox.shrink(),
                      // : Column(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: <Widget>[
                      //       Row(
                      //         children: <Widget>[
                      //           SvgPicture.asset(
                      //             "images/coins.svg",
                      //             color: colorCoins,
                      //           ),
                      //           Container(
                      //             child: Text(
                      //               "Invested",
                      //               style: TextStyle(
                      //                   fontFamily: "Lato",
                      //                   fontSize: 12,
                      //                   color: subtitile),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       SizedBox(
                      //         height: 6,
                      //       ),
                      //       Container(
                      //         child: Text(
                      //           "${widget.userPost.investedAmount}",
                      //           style: TextStyle(
                      //             fontFamily: "Lato",
                      //             fontSize: 12,
                      //             color: Color(0xff4DBAE6),
                      //           ),
                      //         ),
                      //         //transform: Matrix4.translationValues(-35, 0.0, 0.0),
                      //       ),
                      //     ],
                      //   ),
                      SizedBox(
                        width: 0,
                      ),
                      // widget.userPost.storyType == "Wage"
                      //     ? SizedBox()
                      //     :
                      Column(
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
                                  "Profit",
                                  style: TextStyle(
                                    fontFamily: "Lato",
                                    fontSize: 12,
                                    color: subtitile,
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
                      //     ),
                      //   ),
                      //SizedBox(width: 14,),
                      GestureDetector(
// <<<<<<< HEAD
//                         onTap: () {
//                           buildReactionTile();
//                           Navigator.push(
//                               context,
//                               PageTransition(
//                                   // settings: RouteSettings(
//                                   //     name: "Login_Page"),
//                                   type: PageTransitionType.fade,
//                                   child: Reaction_Info(
//                                     like: likes,
//                                     love: love,
//                                     hate: hates,
//                                     whatever: whatevers,
//                                   )));
//                         },
//                         child: SvgPicture.asset("images/rsocial_punch_blue.svg",
//                             height: 23, fit: BoxFit.cover),
// =======
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DisplayPost(
                                      postId: widget.userPost.id,
                                    ))),
                        child: Icon(
                          Icons.more_vert,
                          color: colorUnselectedBottomNav,
                          size: 30,
                        ),
//>>>>>>> master
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
                        top: 5, bottom: 3, left: 3, right: 3),
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
                    )),
            widget.userPost.fileUpload.length != 0
                ? Padding(
                    padding: widget.userPost.storyText == null
                        ? EdgeInsets.only(top: 0, bottom: 15)
                        : EdgeInsets.only(bottom: 15, top: 6),
                    child: Container(
                        height:
                            widget.userPost.fileUpload.length != 0 ? 250 : 0,
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
                                          InteractiveViewer(
                                            transformationController: transformationController,
                                            onInteractionEnd: (details) {
                                              setState(() {
                                                transformationController.toScene(Offset.zero);
                                              });
                                            },
                                            //boundaryMargin: EdgeInsets.all(20.0),
                                            minScale: 0.1,
                                            maxScale: 2,
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              child: Container(
                                                decoration: BoxDecoration(

                                                    color: Colors.grey.withOpacity(0.2),
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                          fileList[index],
                                                        ),
                                                        fit: BoxFit.cover)),
                                                height: 250,
                                              ),
                                            ),
                                          )
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
                                : InteractiveViewer(
                          transformationController: transformationController,
                          onInteractionEnd: (details) {
                            setState(() {
                              transformationController.toScene(Offset.zero);
                            });
                          },
                          //boundaryMargin: EdgeInsets.all(20.0),
                          minScale: 0.1,
                          maxScale: 2,
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(

                                  color: Colors.grey.withOpacity(0.2),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        fileList[0],
                                      ),
                                      fit: BoxFit.cover)),
                              height: 250,
                            ),
                          ),
                        ))
                            : Center(
                                child: CircularProgressIndicator(),
                              )))
                : SizedBox(),
            Padding(
              padding: EdgeInsets.only(
                top: 15,
              ),
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
                                        color: postDesc,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        SizedBox(
                          width: 20 -
                              likedAnimation.value * reactionSizeIncrease / 2 -
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
                                        color: postDesc,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        SizedBox(
                          width: 20 -
                              hatedAnimation.value * reactionSizeIncrease -
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

                  GestureDetector(
                    onTap: !_isCreatingLink
                        ? () async {
                            final Uri uri = await createDynamicLink();
                            //final Uri uri=_linkMessage;
                            String sender = uri.queryParameters['postid'];
                            print("link is: $uri \n sent by: $sender");
                            //initDynamicLinks();

                            final RenderBox box = context.findRenderObject();
                            share(uri);
                          }
                        : null,
                    child: Column(
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
