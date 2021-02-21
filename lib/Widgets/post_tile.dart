import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';

//import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rsocial2/Screens/display_post.dart';
import 'package:rsocial2/Screens/landing_page.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/deep_links.dart';
import 'package:rsocial2/functions.dart';
import 'package:path/path.dart' as p;
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/invested_with.dart';
import 'package:rsocial2/Screens/login_page.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/Screens/reaction_info.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'package:rsocial2/Widgets/request_tile.dart';
import '../contants/constants.dart';
import '../model/post.dart';
import '../model/reaction_model.dart';
import '../read_more.dart';
import '../model/user.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

import 'disabled_reaction_button.dart';

Map<String, Map<String, int>> m = new Map();
Map<String, Map<String, int>> mp = new Map();
Map<String, String> prft = new Map();

class Post_Tile extends StatefulWidget {
  Post userPost;
  var photoUrl;
  User curUser;
  Function reactionCallback;
  final VoidCallback onPressDelete;
  Post_Tile(
      {@required this.curUser,
      this.userPost,
      this.photoUrl,
      this.onPressDelete,
      this.reactionCallback});
  @override
  _Post_TileState createState() => _Post_TileState();
}

class _Post_TileState extends State<Post_Tile> with TickerProviderStateMixin {
  List<String> fileList = [];
  List<File> downloadedFileList = [];
  Directory dir;
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
  // AudioPlayer audioPlayer;
  // AudioCache audioCache;
  int reactionSizeIncrease = 3;
  bool _isCreatingLink = false;
  bool isDeleting = false;

  getReactions() {
    print(rxn);
    // loved = [];
    // liked = [];
    // whatever = [];
    // hated = [];
    counter = {'loved': 0, 'liked': 0, 'whatever': 0, 'hated': 0, 'noreact': 0};
    //bool inLoop=true;
    for (int i = 0; i < widget.userPost.reactedBy.length; i++) {
      User user = widget.userPost.reactedBy[i];
      String rt = user.reactionType;
      // if (rt == 'loved')
      //   loved.add(user);
      // else if (rt == 'liked')
      //   liked.add(user);
      // else if (rt == 'hated')
      //   hated.add(user);
      // else
      //   whatever.add(user);

      counter[rt]++;

      if (user.id == (curUser!=null ? curUser.id : savedUser.id)) {
        this.rxn = user.reactionType;
      }
    }
  }

  convertStringToFile() async {
    for (int i = 0; i < widget.userPost.fileUpload.length; i++) {
      fileList.add(widget.userPost.fileUpload[i]);

      print(fileList[i]);
      // downloadedFileList
      //     .add(await file("${widget.userPost.id}_" + i.toString() + ".jpg"));
    }
    print("download list: " + downloadedFileList.length.toString());
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

  Future<File> file(String filename) async {
    if (dir == null) dir = await getApplicationDocumentsDirectory();
    print(dir);
    String pathName = p.join(dir.path, filename);
    return File(pathName);
  }

  showProfile(BuildContext context, User user, String photourl) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          currentUser: curUser,
          photoUrl: photourl,
          user: user,
        ),
      ),
    );
    setState(() {});
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
    var url = storyEndPoint + 'react';
    var user = await FirebaseAuth.instance.currentUser();

    Reaction reaction = Reaction(
        id: (curUser!=null ? (curUser!=null ? curUser.id : savedUser.id) : savedUser.id), storyId: widget.userPost.id, reactionType: reactn);
    var token = await user.getIdToken();
    //print(jsonEncode(reaction.toJson()));
    //print(token);
    var response;
    try {
      response = await http.put(
        url,
        encoding: Encoding.getByName("utf-8"),
        body: jsonEncode(reaction.toJson()),
        headers: {
          "Authorization": "Bearer: $token",
          "Content-Type": "application/json",
        },
      );
    } catch (e) {
      setState(() {
        isDisabled = false;
      });
    }

    print(response.statusCode);
    if (response.statusCode == 200) {
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

      getReactions();
      //curUser.lollarAmount = 123334;
      if (widget.reactionCallback != null) widget.reactionCallback();
      print(
          "Hello heloo sdfhsdklfhsdlkfjsdklfsdjfklsdjfklsdfjskdlfjdsklfjsdflkjcf");

      // });
      setState(() {});
    }
    //print("hello hello");
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
    if (widget.userPost.user.id != (curUser!=null ? curUser.id : savedUser.id)) {
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
                                //fontWeight: FontWeight.bold,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.bold,
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
                                color: colorGreyTint,
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
                                //fontWeight: FontWeight.bold,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.bold,
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
                                                onTap: () {
                                                  showProfile(
                                                      context,
                                                      widget.userPost
                                                          .investedWithUser[0],
                                                      widget.userPost.user
                                                          .photoUrl);
                                                  setState(() {});
                                                },
                                                child: Text(
                                                  "Invested " +
                                                      investAmountFormatting(
                                                          double.parse(widget
                                                                  .userPost
                                                                  .investedAmount)
                                                              .floor()) +
                                                      " with ${widget.userPost.investedWithUser[0].fname}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: "Lato",
                                                    fontSize: 12,
                                                    color: colorGreyTint,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            "Invested " +
                                                investAmountFormatting(
                                                    double.parse(widget.userPost
                                                            .investedAmount)
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
                                  ],
                                ),
                                Text(
                                  "${widget.userPost.createdOn}",
                                  textAlign: TextAlign.left,
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
                                              postId: widget.userPost.id,
                                            )));
                                  },
                                  child: new Text('Reactions'))),
                          if (widget.userPost.user.id == (curUser!=null ? curUser.id : savedUser.id))
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
                        color: colorUnselectedBottomNav,
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
                                          pagination: SwiperPagination(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              widget.userPost.fileUpload.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                        fileList[index],
                                                        // errorWidget: (context,
                                                        //         url, error) =>
                                                        //     Icon(Icons.error),
                                                      ),
                                                      fit: BoxFit.cover)),
                                              height: 250,
                                            );
                                          }),
                                    ),
                                  )
                                : InteractiveViewer(
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
                                      color: colorUnselectedBottomNav,
                                    ),
                                  )
                                ],
                              )
                            : GestureDetector(
                                onTap: () => {reaction('loved')},
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: 23 +
                                          reactionSizeIncrease *
                                              lovedAnimation.value,
                                      width: 23 +
                                          reactionSizeIncrease *
                                              lovedAnimation.value,
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
                                        color: colorUnselectedBottomNav,
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
                                      color: colorUnselectedBottomNav,
                                    ),
                                  )
                                ],
                              )
                            : GestureDetector(
                                onTap: () => {reaction('liked')},
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
                                      color: colorUnselectedBottomNav,
                                    ),
                                  )
                                ],
                              )
                            : GestureDetector(
                                onTap: () => {reaction('whatever')},
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
                                      color: colorUnselectedBottomNav,
                                    ),
                                  )
                                ],
                              )
                            : GestureDetector(
                                onTap: () => {reaction('hated')},
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
                    ),
                  ),
                  SizedBox(
                    width: 20 - hatedController.value * reactionSizeIncrease,
                  ),
                  //Container(),

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
                              color: colorUnselectedBottomNav,
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

// class ReactionButton extends StatefulWidget {
//   String reactionType;
//   Function ontap;
//   String imageSelected;
//   Animation reactionAnimation;
//   Map<String, int> counter;
//   String imageNotSelected;
//   String currentReaction;
//   int reactionCount;
//   Post userPost;
//   ReactionButton({this.reactionType,this.ontap,this.imageSelected,
//     this.imageNotSelected,this.currentReaction,this.reactionCount,
//   this.reactionAnimation,this.counter,this.userPost});
//   @override
//   _ReactionButtonState createState() => _ReactionButtonState();
// }
//
// class _ReactionButtonState extends State<ReactionButton> with TickerProviderStateMixin{
//   int reactionSizeIncrease = 3;
//   AnimationController animationController;
//   AudioPlayer audioPlayer;
//   AudioCache audioCache;
//
//   react() async {
//     setState(() {
//       audioCache.play("click.mp3");
//       String prvrxn = widget.currentReaction;
//       widget.currentReaction = widget.reactionType;
//       widget.counter[prvrxn]--;
//       widget.counter[widget.currentReaction]++;
//       //print(widget.userPost.profit);
//       m[widget.userPost.id] = {widget.currentReaction: widget.counter[widget.currentReaction]};
//       //print("updating mp");
//       mp[widget.userPost.id] = widget.counter;
//       prft[widget.userPost.id] = widget.userPost.profit;
//     });
//     var url = storyEndPoint + 'react';
//     var user = await FirebaseAuth.instance.currentUser();
//     //print(uid);
//     Reaction reaction = Reaction(
//         id: curUser.id, storyId: widget.userPost.id, reactionType: widget.currentReaction);
//     var token = await user.getIdToken();
//     var response;
//     try {
//       response = await http.put(
//         url,
//         encoding: Encoding.getByName("utf-8"),
//         body: jsonEncode(reaction.toJson()),
//         headers: {
//           "Authorization": "Bearer: $token",
//           "Content-Type": "application/json",
//         },
//       );
//     } catch (e) {
//       setState(() {
//         //isDisabled = false;
//       });
//     }
//
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       final jsonUser = jsonDecode(response.body);
//       var body = jsonUser['body'];
//       var body1 = jsonDecode(body);
//       print("body is $body");
//
//       //print(body1);
//       var msg = body1['message'];
//       setState(() {
//         prft[widget.userPost.id] = msg["PresentValue"].toString();
//       });
//
//       // if (widget.userPost.storyType == 'Wage')
//       //   widget.userPost = Post.fromJsonW(msg);
//       // else
//       //   widget.userPost = Post.fromJsonI(msg);
//
//       // getReactions();
//
//       // });
//       setState(() {});
//     }
//     //print("hello hello");
//     // setState(() {
//     //   isDisabled = false;
//     // });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     audioPlayer = new AudioPlayer();
//     audioCache = new AudioCache(fixedPlayer: audioPlayer);
//     animationController =
//         AnimationController(duration: Duration(milliseconds: 400), vsync: this);
//     widget.reactionAnimation = CurvedAnimation(
//         parent: animationController,
//         curve: Curves.easeIn,
//         reverseCurve: Curves.easeIn);
//   }
//
//   @override
//   void dispose() {
//     animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: (){
//             widget.ontap;
//             if (widget.userPost.user.id != curUser.id) {
//               animationController.forward();
//               animationController.addListener(() {
//                   setState(() {});
//                 });
//               animationController.addStatusListener((status) {
//                   if (status == AnimationStatus.completed) {
//                     animationController.reverse();
//                     animationController.addListener(() {
//                       setState(() {});
//                     });
//                   }
//                 });
//               // if (widget.currentReaction == widget.reactionType) {
//               //   react('noreact');
//               // } else {
//                 react();
//               //}
//             } else
//               Fluttertoast.showToast(
//                   msg: "You cannot react on your own post",
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.BOTTOM,
//                   fontSize: 15);
//           },
//           child: Column(
//             children: <Widget>[
//               Container(
//                   height: 23 +
//                       reactionSizeIncrease *
//                           widget.reactionAnimation.value,
//                   width: 23 +
//                       reactionSizeIncrease *
//                           widget.reactionAnimation.value,
//                   child: widget.currentReaction == widget.reactionType
//                       ? SvgPicture.asset(
//                       widget.imageSelected)
//                       : SvgPicture.asset(
//                       widget.imageNotSelected)),
//               SizedBox(
//                 height: 4 -
//                     reactionSizeIncrease *
//                         widget.reactionAnimation.value,
//               ),
//               Text(
//                 widget.reactionCount.toString(),
//                 style: TextStyle(
//                   fontFamily: "Lato",
//                   fontSize: 10,
//                   color: colorUnselectedBottomNav ,
//                 ),
//               )
//             ],
//           ),
//         ),
//
//       ],
//     );
//   }
// }
