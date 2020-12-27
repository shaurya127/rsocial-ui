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

import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/invested_with.dart';
import 'package:rsocial2/Screens/login_page.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/Screens/reaction_info.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'package:rsocial2/Widgets/request_tile.dart';
import '../constants.dart';
import '../post.dart';
import '../read_more.dart';
import '../user.dart';
import 'package:http/http.dart' as http;

Map<String, Map<String, int>> m = new Map();

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

class _Post_TileState extends State<Post_Tile> {
  List<String> fileList = [];
  bool isLoading = true;
  List<User> loved = [];
  List<User> liked = [];
  List<Request_Tile> love = [];
  List<Request_Tile> likes = [];
  List<User> investedWithUser = [];
  String rxn = "noreact";
  Map<String, int> counter = {
    'loved': 0,
    'liked': 0,
    'whatever': 0,
    'hated': 0,
    'noreact': 0
  };

  getReactions() {
    print(rxn);
    //bool inLoop=true;
    for (int i = 0; i < widget.userPost.reactedBy.length; i++) {
      User user = widget.userPost.reactedBy[i];
      String rt = user.reactionType;
      if (rt == 'loved')
        loved.add(user);
      else if (rt == 'liked') liked.add(user);
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

  react(String reactn) async {
    var url =
        'https://t43kpz2m5d.execute-api.ap-south-1.amazonaws.com/story/react';
    var user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot doc = await users.document(user.uid).get();
    var uid = doc['id'];
    //print(uid);
    Reaction reaction =
        Reaction(id: uid, storyId: widget.userPost.id, reactionType: reactn);
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
      print(response.body);

      setState(() {
        String prevrxn = rxn;
        rxn = reactn;
        print("this is my reaction $rxn");
        bool inLoop = true;
        for (int i = 0; i < widget.userPost.reactedBy.length; i++) {
          User user = widget.userPost.reactedBy[i];
          print("rara");
          if (user.id == widget.curUser.id) {
            //print("in user post");
            if (m.containsKey(widget.userPost.id)) m.remove(widget.userPost.id);
            user.reactionType = reactn;
            inLoop = false;
          }
        }

        //when user reacts on the post for the first time
        if (inLoop == true) {
          //print("charu22");
          // widget.userPost.user.firstRxn=reactn;
          if (rxn == "noreact") {
            m[widget.userPost.id] = {reactn: counter[reactn]};
            return;
          }
          if (prevrxn != "noreact" && prevrxn != rxn) counter[prevrxn]--;
          // else
          //   {
          //     counter[prevrxn]--;
          //     counter[rxn]++;
          //   }
          m[widget.userPost.id] = {reactn: counter[reactn]};
          // if (rxn == "loved")
          //   m[widget.userPost.id][0] = ++lovedCounter;
          // else if (rxn == "liked")
          //   m[widget.userPost.id][1] = ++likedCounter;
          // else if (rxn == "whatever")
          //   m[widget.userPost.id][2] = ++whateverCounter;
          // else if (rxn == "hated")
          //   m[widget.userPost.id][3] = ++hatedCounter;

          // m[widget.userPost.id][reactn] = reactn == "loved"
          //     ? ++lovedCounter
          //     : (reactn == "liked"
          //         ? ++likedCounter
          //         : (reactn == "whatever"
          //             ? ++whateverCounter
          //             : (reactn == "hated" ? ++hatedCounter : rxn)));
          // rxn = reactn;
          // print("hello");
          // print(rxn);
        } else {
          // if a user toggles to another reaction we need to
          // decrease the counter of the previous reaction type
          // if(rxn=='noreact')
          //   rxn="noreact";
          if (prevrxn != rxn && rxn != "noreact") {
            counter[prevrxn]--;
          }
        }
      });
    }
  }

  buildReactionTile() {
    likes = [];
    love = [];
    for (int i = 0; i < counter['loved']; i++) {
      bool sentpending = false;
      bool recievedpending = false;
      bool aconnection = false;
      for (int j = 0; j < widget.curUser.sentPendingConnection.length; j++) {
        if (loved[i].id == widget.curUser.sentPendingConnection[j].id)
          sentpending = true;
      }
      for (int j = 0;
          j < widget.curUser.receivedPendingConnection.length;
          j++) {
        if (loved[i].id == widget.curUser.receivedPendingConnection[j].id)
          recievedpending = true;
      }
      for (int j = 0; j < widget.curUser.connection.length; j++) {
        if (loved[i].id == widget.curUser.connection[j].id) aconnection = true;
      }
      Request_Tile tile = Request_Tile(
        request: recievedpending ? true : false,
        text: recievedpending ? "Accept" : (sentpending ? "Pending" : ""),
        accepted: aconnection ? true : false,
        user: loved[i],
        photourl: loved[i].photoUrl,
        curUser: widget.curUser,
      );
      love.add(tile);
    }

    for (int i = 0; i < counter['liked']; i++) {
      bool sentpending = false;
      bool recievedpending = false;
      bool aconnection = false;
      for (int j = 0; j < widget.curUser.sentPendingConnection.length; j++) {
        if (liked[i].id == widget.curUser.sentPendingConnection[j].id)
          sentpending = true;
      }
      for (int j = 0;
          j < widget.curUser.receivedPendingConnection.length;
          j++) {
        if (liked[i].id == widget.curUser.receivedPendingConnection[j].id)
          recievedpending = true;
      }
      for (int j = 0; j < widget.curUser.connection.length; j++) {
        if (liked[i].id == widget.curUser.connection[j].id) aconnection = true;
      }
      Request_Tile tile = Request_Tile(
        request: recievedpending ? true : false,
        text: recievedpending ? "Accept" : (sentpending ? "Pending" : ""),
        accepted: aconnection ? true : false,
        user: liked[i],
        photourl: liked[i].photoUrl,
        curUser: widget.curUser,
      );
      likes.add(tile);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (m.containsKey(widget.userPost.id)) {
      Map<String, int> map = m[widget.userPost.id];
      for (var key in map.keys) rxn = key;
      print("my reaction is now $rxn");
      counter[rxn] = map[rxn];
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
                                  NetworkImage(widget.userPost.user.photoUrl),
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
                              backgroundImage:
                                  NetworkImage(widget.userPost.user.photoUrl),
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
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                  // settings: RouteSettings(
                                                  //     name: "Login_Page"),
                                                  type: PageTransitionType.fade,
                                                  child: Profile(
                                                    currentUser: widget.curUser,
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
                      SvgPicture.asset(
                        "images/loved.svg",
                        color: colorPrimaryBlue,
                      )
                    else if (counter['liked'] > counter['loved'] &&
                        counter['liked'] >= counter['whatever'] &&
                        counter['liked'] >= counter['hated'])
                      SvgPicture.asset(
                        "images/liked.svg",
                        color: colorPrimaryBlue,
                      )
                    else if (counter['whatever'] > counter['loved'] &&
                        counter['whatever'] > counter['liked'] &&
                        counter['whatever'] >= counter['hated'])
                      SvgPicture.asset(
                        "images/whatever.svg",
                        color: colorPrimaryBlue,
                      )
                    else if (counter['hated'] > counter['liked'] &&
                        counter['hated'] > counter['loved'] &&
                        counter['hated'] > counter['whatever'])
                      SvgPicture.asset(
                        "images/hated.svg",
                        color: colorPrimaryBlue,
                      ),
                    //SizedBox(width: 14,),
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
                                  )));

                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => Reaction_Info(
                          //               like: likes,
                          //               love: love,
                          //             )));
                        },
                        child: Icon(
                          Icons.more_vert,
                          color: Color(0xff707070),
                          size: 30,
                        )),
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
                        top: 12, bottom: 3, left: 3, right: 3),
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
            Padding(
                padding: widget.userPost.storyText == null
                    ? EdgeInsets.only(top: 0, bottom: 15)
                    : EdgeInsets.only(bottom: 15, top: 6),
                child: Container(
                    height: widget.userPost.fileUpload.length != 0 ? 250 : 0,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    child: isLoading == false
                        ? Swiper(
                            loop: false,
                            pagination: SwiperPagination(),
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.userPost.fileUpload.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Stack(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey.withOpacity(0.2),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              fileList[index],
                                            ),
                                            fit: BoxFit.cover)),
                                    height: 250,
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
                        : Center(
                            child: CircularProgressIndicator(),
                          ))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => {
                          // widget.userPost.user.id == widget.curUser.id
                          //     ? Fluttertoast.showToast(
                          //         msg: "You cannot react on your own post!",
                          //         toastLength: Toast.LENGTH_SHORT,
                          //         gravity: ToastGravity.BOTTOM,
                          //         fontSize: 15)
                          //     :
                          (rxn == 'loved'
                              ? {react("noreact"), counter['loved']--}
                              : {react("loved"), counter['loved']++})
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 23,
                              width: 23,
                              child: SvgPicture.asset(
                                "images/loved.svg",
                                color: rxn == "loved"
                                    ? colorPrimaryBlue
                                    : postIcons,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                counter['loved'].toString(),
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
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () => {
                          // widget.userPost.user.id == widget.curUser.id
                          //     ? Fluttertoast.showToast(
                          //         msg: "You cannot react on your own post!",
                          //         toastLength: Toast.LENGTH_SHORT,
                          //         gravity: ToastGravity.BOTTOM,
                          //         fontSize: 15)
                          //     :
                          (rxn == 'liked'
                              ? {react("noreact"), counter['liked']--}
                              : {react("liked"), counter['liked']++})
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 23,
                              width: 23,
                              child: SvgPicture.asset(
                                "images/liked.svg",
                                color: rxn == "liked"
                                    ? colorPrimaryBlue
                                    : postIcons,
                              ),
                            ),
                            //Icon(Icons.thumb_up,size: 30,color:postIcons),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                counter['liked'].toString(),
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
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => {
                          // widget.userPost.user.id == widget.curUser.id
                          //     ? Fluttertoast.showToast(
                          //         msg: "You cannot react on your own post!",
                          //         toastLength: Toast.LENGTH_SHORT,
                          //         gravity: ToastGravity.BOTTOM,
                          //         fontSize: 15)
                          //     :
                          (rxn == 'whatever'
                              ? {react("noreact"), counter['whatever']--}
                              : {react("whatever"), counter['whatever']++})
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 23,
                              width: 23,
                              child: SvgPicture.asset(
                                "images/whatever.svg",
                                color: rxn == "whatever"
                                    ? colorPrimaryBlue
                                    : postIcons,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                counter['whatever'].toString(),
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
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () => {
                          // widget.userPost.user.id == widget.curUser.id
                          //     ? Fluttertoast.showToast(
                          //         msg: "You cannot react on your own post!",
                          //         toastLength: Toast.LENGTH_SHORT,
                          //         gravity: ToastGravity.BOTTOM,
                          //         fontSize: 15)
                          //     :
                          (rxn == 'hated'
                              ? {react("noreact"), counter['hated']--}
                              : {react("hated"), counter['hated']++})
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 23,
                              width: 23,
                              child: SvgPicture.asset(
                                "images/hated.svg",
                                color: rxn == "hated"
                                    ? colorPrimaryBlue
                                    : postIcons,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                counter['hated'].toString(),
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
                SizedBox(
                  width: 20,
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
          ],
        ),
      ),
    );
  }
}
