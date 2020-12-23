import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/login_page.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:http/http.dart' as http;
import 'package:rsocial2/auth.dart';
import 'package:rsocial2/user.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
  User currentUser;
  User user;
  String photoUrl;
  Profile({this.currentUser, this.photoUrl,this.user});
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  String postOrientation = "wage";

  // Future<User> getUser() async {
  //   var user = await FirebaseAuth.instance.currentUser();
  //   photourl = user.photoUrl;
  //   DocumentSnapshot doc = await users.document(user.uid).get();
  //   var id = doc['id'];
  //   final url =
  //       "https://9dhzla746i.execute-api.ap-south-1.amazonaws.com/user/${id}";
  //   //var user = await FirebaseAuth.instance.currentUser();
  //   //print("this user id is ${user.uid}");
  //   var token = await user.getIdToken();
  //   print(token);
  //   final response = await http.get(url, headers: {
  //     "Authorization": "Bearer $token",
  //     "Content-Type": "application/json",
  //   });
  //   //print(response.body);
  //   print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     final jsonUser = jsonDecode(response.body);
  //     var body = jsonUser['body'];
  //     var body1 = jsonDecode(body);
  //     print("body is $body");
  //     print(body1);
  //     var msg = body1['message'];
  //     //print("id is: ${msg['id']}");
  //     return User.fromJson(msg);
  //   } else {
  //     print(response.statusCode);
  //     throw Exception();
  //   }
  // }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Here app bar to be updated
        appBar: customAppBar(context,
            widget.currentUser.id==widget.user.id? "My Profile" : "Profile",
            widget.currentUser.lollarAmount.toString(), widget.currentUser.photoUrl,
            widget.currentUser.socialStanding.toString()),
        body:
            //FutureBuilder<User>(

            // future: getUser(),
            //builder: (context, snapshot) {
            // if (snapshot.hasData) {
            // final user = snapshot.data;
            ListView(
          //padding: EdgeInsets.all(24),
          children: <Widget>[
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
                      widget.currentUser.id==widget.user.id ? Text(
                        "Edit",
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontSize: 15,
                          color: Colors.blue,
                        ),
                      ) : Container(),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${widget.user.fname}" +
                        " ${widget.user.lname}",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xff263238),
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  widget.currentUser.id==widget.user.id ? Text(
                    "${widget.user.email}",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xff7F7F7F),
                    ),
                  ) : SizedBox.shrink(),
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
                            color: Color(0xff7F7F7F),
                          ),
                        )
                      : SizedBox.shrink(),
                  Text(
                    widget.user.bio != null
                        ? widget.user.bio
                        : "here comes the bio",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 16,
                      color: Color(0xff263238),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        setPostOrientation("wage");
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Wage story",
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
                      onTap: () => setPostOrientation("invest"),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Investment story",
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
                        children: <Widget>[
                          Text(
                            "Platform Interaction",
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
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Divider(
                height: 0.5,
                color: Colors.black,
              ),
            ),
            if (postOrientation == 'wage')
              Container(
                color: Colors.white,
                height: 1000,
                width: MediaQuery.of(context).size.width,
              )
            else if (postOrientation == 'invest')
              Container(
                color: Colors.white,
                height: 1000,
                width: MediaQuery.of(context).size.width,
              )
            else if (postOrientation == 'platform')
              Container(
                color: Colors.white,
                height: 1000,
                width: MediaQuery.of(context).size.width,
              )
          ],
        )
        //} else if (snapshot.hasError) {
        //print("error occurred");
        //}
        //return Center(child: CircularProgressIndicator());
        // },
        //),
        );
    //}
  }
}
