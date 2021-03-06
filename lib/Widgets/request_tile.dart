import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';

import '../model/connection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_svg/svg.dart';
import 'package:rsocial2/Screens/login_page.dart';
import 'package:rsocial2/Screens/profile_page.dart';

import '../contants/config.dart';
import 'package:http/http.dart' as http;

import '../contants/constants.dart';
import '../functions.dart';
import '../model/user.dart';

class Request_Tile extends StatefulWidget {
  //bool request = false;
  bool accepted = false;
  //String photourl;
  String text;
  User user;
  //User curUser;
  Request_Tile(
      {this.text,
      this.user,
      //  this.photourl,
      //this.curUser,
      this.accepted});
  @override
  _Request_TileState createState() => _Request_TileState();
}

class _Request_TileState extends State<Request_Tile> {
  // investingWithCallbackListener() {
  //   setState(() {});
  // }
  bool isDisabled = false;

  //User curUser;
  removeConnection(String friendId) async {
    setState(() {
      isDisabled = true;
    });

    try {
      var url = userEndPoint + "removebond";
      var user = auth.FirebaseAuth.instance.currentUser;
      DocumentSnapshot doc = await users.doc(user.uid).get();
      var uid = doc['id'];
      //print(uid);
      Connection connection = Connection(
        id: uid,
        friendId: friendId,
      );
      var token = await user.getIdToken();
      print(jsonEncode(connection.toJson()));
      //print(token);
      var response = await http.put(
        Uri.parse(url),
        encoding: Encoding.getByName("utf-8"),
        body: jsonEncode(connection.toJson()),
        headers: {
          "Authorization": "Bearer: $token",
          "Content-Type": "application/json",
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.body);
        final jsonUser = jsonDecode(response.body);
        var body = jsonUser['body'];
        var body1 = jsonDecode(body);
        //print("body is $body");
        // print(body1);
        var msg = body1['message'];
        curUser.userMap.remove(friendId);
        setState(() {
          widget.text = "add";
          isDisabled = false;
          //widget.accepted = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Some error occured. Please try again later",
          gravity: ToastGravity.BOTTOM);
      setState(() {
        isDisabled = false;
      });
    }
  }

  addConnection(String friendId) async {
    setState(() {
      isDisabled = true;
    });
    try {
      var url = userEndPoint + "addbond";
      var user = auth.FirebaseAuth.instance.currentUser;
      DocumentSnapshot doc = await users.doc(user.uid).get();
      var uid = doc['id'];
      //print(uid);
      Connection connection = Connection(
        id: uid,
        friendId: friendId,
      );
      var token = await user.getIdToken();
      //print(jsonEncode(connection.toJson()));
      //print(token);
      var response = await http.put(
        Uri.parse(url),
        encoding: Encoding.getByName("utf-8"),
        body: jsonEncode(connection.toJson()),
        headers: {
          "Authorization": "Bearer: $token",
          "Content-Type": "application/json",
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.body);
        final jsonUser = jsonDecode(response.body);
        var body = jsonUser['body'];
        var body1 = jsonDecode(body);
        //print("body is $body");
        // print(body1);
        var msg = body1['message'];
        curUser.userMap[friendId] = "pending";
        setState(() {
          widget.text = "pending";
        });
      }
      setState(() {
        isDisabled = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Some error occured. Please try again later",
          gravity: ToastGravity.BOTTOM);
      setState(() {
        isDisabled = false;
      });
    }
  }

  acceptConnection(String friendId) async {
    setState(() {
      isDisabled = true;
    });

    try {
      var url = userEndPoint + "acceptbond";

      var user = auth.FirebaseAuth.instance.currentUser;
      DocumentSnapshot doc = await users.doc(user.uid).get();
      var uid = doc['id'];
      print(uid);
      Connection connection = Connection(
        id: uid,
        friendId: friendId,
      );
      var token = await user.getIdToken();
      print(jsonEncode(connection.toJson()));
      //print(token);
      var response = await http.put(
        Uri.parse(url),
        encoding: Encoding.getByName("utf-8"),
        body: jsonEncode(connection.toJson()),
        headers: {
          "Authorization": "Bearer: $token",
          "Content-Type": "application/json",
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final jsonUser = jsonDecode(response.body);
        var body = jsonUser['body'];
        var body1 = jsonDecode(body);
        //print("body is $body");
        // print(body1);
        var msg = body1['message'];
        //print("id is: ${msg['id']}");
        //print(msg);
        curUser.userMap[friendId] = "remove";
        setState(() {
          widget.text = "remove";
          isDisabled = false;
          //widget.accepted = true;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Some error occured. Please try again later",
          gravity: ToastGravity.BOTTOM);
      setState(() {
        isDisabled = false;
      });
    }
  }

  buildRequest() {
    // return (widget.accepted == false)
    //     ?
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              print("isDisabled" + isDisabled.toString());
              if (isDisabled == false) removeConnection(widget.user.id);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Text(
                "Reject",
                style: TextStyle(
                    fontFamily: "Lato", fontSize: 14, color: colorPrimaryBlue),
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      width: 1, color: Theme.of(context).primaryColor)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onTap: () {
              if (isDisabled == false) acceptConnection(widget.user.id);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Text(
                "Accept",
                style: TextStyle(
                    fontFamily: "Lato", fontSize: 14, color: Colors.white),
              ),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      width: 1, color: Theme.of(context).primaryColor)),
            ),
          ),
        )
      ],
    );
    // :
    // Icon(
    //   Icons.check,
    //   size: 24,
    //   color: colorPrimaryBlue,
    // );
  }

  buildPending() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            "Pending",
            style:
                TextStyle(fontFamily: "Lato", fontSize: 14, color: Colors.grey),
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 1, color: Colors.grey)),
        ),
      ),
    );
  }

  buildAdd() {
    // return widget.accepted==false
    //     ?
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () {
          if (isDisabled == false) addConnection(widget.user.id);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            "Add",
            style: TextStyle(
                fontFamily: "Lato", fontSize: 14, color: Colors.white),
          ),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(width: 1, color: Theme.of(context).primaryColor)),
        ),
      ),
    );
    //:buildPending();
  }

  buildRemove() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () {
          print("hello 2");
          if (isDisabled == false) removeConnection(widget.user.id);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(
            "Remove",
            style: TextStyle(
                fontFamily: "Lato", fontSize: 14, color: Colors.white),
          ),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(width: 1, color: Theme.of(context).primaryColor)),
        ),
      ),
    );
  }

  showProfile(BuildContext context, User user, String photourl, User curUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          currentUser: curUser,
          photoUrl: photourl,
          user: user,
        ),
      ),
    );
  }

  // buildRequest() {
  //   // return (widget.accepted == false)
  //   //     ?
  //   return Row(
  //     children: <Widget>[
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 5),
  //         child: GestureDetector(
  //           onTap: () {},
  //           child: Container(
  //             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  //             child: Text(
  //               "Reject",
  //               style: TextStyle(
  //                   fontFamily: "Lato", fontSize: 14, color: colorPrimaryBlue),
  //             ),
  //             decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(10),
  //                 border: Border.all(
  //                     width: 1, color: Theme.of(context).primaryColor)),
  //           ),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 5),
  //         child: GestureDetector(
  //           onTap: () {
  //             acceptConnection(widget.user.id);
  //           },
  //           child: Container(
  //             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  //             child: Text(
  //               "Accept",
  //               style: TextStyle(
  //                   fontFamily: "Lato", fontSize: 14, color: Colors.white),
  //             ),
  //             decoration: BoxDecoration(
  //                 color: Theme.of(context).primaryColor,
  //                 borderRadius: BorderRadius.circular(10),
  //                 border: Border.all(
  //                     width: 1, color: Theme.of(context).primaryColor)),
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  //   // :
  //   // Icon(
  //   //   Icons.check,
  //   //   size: 24,
  //   //   color: colorPrimaryBlue,
  //   // );
  // }
  //
  // buildPending() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 5),
  //     child: GestureDetector(
  //       onTap: () {},
  //       child: Container(
  //         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  //         child: Text(
  //           "Pending",
  //           style:
  //               TextStyle(fontFamily: "Lato", fontSize: 14, color: Colors.grey),
  //         ),
  //         decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(10),
  //             border: Border.all(width: 1, color: Colors.grey)),
  //       ),
  //     ),
  //   );
  // }
  //
  // buildAdd() {
  //   // return widget.accepted==false
  //   //     ?
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 5),
  //     child: GestureDetector(
  //       onTap: () {
  //         addConnection(widget.user.id);
  //       },
  //       child: Container(
  //         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  //         child: Text(
  //           "Add",
  //           style: TextStyle(
  //               fontFamily: "Lato", fontSize: 14, color: Colors.white),
  //         ),
  //         decoration: BoxDecoration(
  //             color: Theme.of(context).primaryColor,
  //             borderRadius: BorderRadius.circular(10),
  //             border:
  //                 Border.all(width: 1, color: Theme.of(context).primaryColor)),
  //       ),
  //     ),
  //   );
  //   //:buildPending();
  // }
  //
  // buildRemove() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 5),
  //     child: GestureDetector(
  //       onTap: () {
  //         removeConnection(widget.user.id);
  //       },
  //       child: Container(
  //         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  //         child: Text(
  //           "Remove",
  //           style: TextStyle(
  //               fontFamily: "Lato", fontSize: 14, color: Colors.white),
  //         ),
  //         decoration: BoxDecoration(
  //             color: Theme.of(context).primaryColor,
  //             borderRadius: BorderRadius.circular(10),
  //             border:
  //                 Border.all(width: 1, color: Theme.of(context).primaryColor)),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // print("This is my build");
    // print(widget.text);
    widget.text = curUser.userMap.containsKey(widget.user.id)
        ? curUser.userMap[widget.user.id]
        : "add";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ListTile(
                  //contentPadding: EdgeInsets.all(4),
                  dense: true,
                  //contentPadding: EdgeInsets.all(-10)
                  leading: GestureDetector(
                    onTap: () => showProfile(
                        context, widget.user, widget.user.photoUrl, curUser),
                    child: CircleAvatar(
                      backgroundImage: widget.user.photoUrl != ""
                          ? NetworkImage(
                              widget.user.photoUrl,
                            )
                          : AssetImage("images/avatar.jpg"),
                    ),
                  ),
                  title: Text(
                    "${widget.user.fname} ${widget.user.lname}",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: nameCol,
                    ),
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      Container(
                        height: 15,
                        width: 15,
                        padding: EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          "images/yollar_Icon.svg",
                          color: nameCol.withOpacity(0.4),
                        ),
                      ),
                      Text(
                        formatNumber(widget.user.lollarAmount),
                        style: TextStyle(color: Colors.grey),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8),
                      //   child: Container(
                      //     width: 1,
                      //     height: 10,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                      // Container(
                      //   height: 15,
                      //   width: 15,
                      //   padding: EdgeInsets.only(right: 2),
                      //   child: SvgPicture.asset(
                      //     "images/social-standing.svg",
                      //     color: nameCol.withOpacity(0.4),
                      //   ),
                      // ),
                      // Text(
                      //   "${widget.user.socialStanding}",
                      //   style: TextStyle(color: Colors.grey),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 1,
                          height: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        height: 15,
                        width: 15,
                        padding: EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          "images/high-five.svg",
                          color: nameCol.withOpacity(0.4),
                        ),
                      ),
                      Text(
                        widget.user.connection.length !=
                                    widget.user.connectionCount &&
                                widget.user.connectionCount != null
                            ? "${widget.user.connectionCount}"
                            : "${widget.user.connection.length}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.text == "request")
                buildRequest()
              else if (widget.text == "pending")
                buildPending()
              else if (widget.user.id == curUser.id)
                SizedBox()
              else if (widget.text == "remove")
                buildRemove()
              else if (widget.text == "add")
                buildAdd()
              else
                Icon(
                  Icons.check,
                  size: 24,
                  color: colorPrimaryBlue,
                )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Divider(
              height: 1,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}
