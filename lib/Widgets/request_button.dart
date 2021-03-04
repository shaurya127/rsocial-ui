import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/login_page.dart';

import '../contants/config.dart';
import '../model/connection.dart';
import 'package:http/http.dart' as http;

import '../contants/constants.dart';
import '../model/user.dart';

class RequestButton extends StatefulWidget {
  @override
  _RequestButtonState createState() => _RequestButtonState();

  RequestButton({this.text, this.user});

  String text;
  User user;
}

class _RequestButtonState extends State<RequestButton> {
  bool isDisabled = false;

  removeConnection(String friendId) async {
    setState(() {
      isDisabled = true;
    });

    try {
      var url = userEndPoint + "removeconnection";
      var user = await FirebaseAuth.instance.currentUser();
      DocumentSnapshot doc = await users.document(user.uid).get();
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
        url,
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
        setState(() {
          curUser = User.fromJson(msg);
          widget.text = "";
          //widget.accepted = false;
        });
      }
      setState(() {
        isDisabled = false;
      });
    } catch (e) {
      setState(() {
        isDisabled = false;
      });
    }
  }

  addConnection(String friendId) async {
    print("isDisabled");
    setState(() {
      isDisabled = true;
    });
    try {
      var url = userEndPoint + "addconnection";
      var user = await FirebaseAuth.instance.currentUser();
      DocumentSnapshot doc = await users.document(user.uid).get();
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
        url,
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
        setState(() {
          curUser = User.fromJson(msg);
          widget.text = "pending";
        });
      }
      setState(() {
        isDisabled = false;
      });
    } catch (e) {
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
      var url = userEndPoint + "acceptconnection";

      var user = await FirebaseAuth.instance.currentUser();
      DocumentSnapshot doc = await users.document(user.uid).get();
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
        url,
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
        setState(() {
          curUser = User.fromJson(msg);
          widget.text = "";
          //widget.accepted = true;
        });
      }

      isDisabled = false;
    } catch (e) {
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
          padding: const EdgeInsets.only(right: 5),
          child: GestureDetector(
            onTap: () {
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
          padding: const EdgeInsets.symmetric(horizontal: 5),
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
      padding: const EdgeInsets.symmetric(horizontal: 0),
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
      padding: const EdgeInsets.symmetric(horizontal: 0),
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
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () {
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

  @override
  Widget build(BuildContext context) {
    if (isDisabled) print("I am disabled right now");

    if (widget.text == "request")
      return buildRequest();
    else if (widget.text == "pending")
      return buildPending();
    else if (widget.user.id == curUser.id)
      return SizedBox();
    else if (widget.text == "remove")
      return buildRemove();
    else if (widget.text == "add")
      return buildAdd();
    else
      return Icon(
        Icons.check,
        size: 24,
        color: colorPrimaryBlue,
      );
  }
}
