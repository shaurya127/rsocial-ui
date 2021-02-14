import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Widgets/error.dart';
import 'package:rsocial2/Widgets/post_tile.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/contants/constants.dart';


import '../model/post.dart';
import '../model/user.dart';
import 'bottom_nav_bar.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;

class Landing_Page extends StatefulWidget {
  User curUser;
  List<Post> posts;
  bool isLoading;
  bool isErrorLoadingPost;

  Landing_Page(
      {this.curUser, this.posts, this.isLoading, this.isErrorLoadingPost});
  @override
  _Landing_PageState createState() => _Landing_PageState();
}

class _Landing_PageState extends State<Landing_Page> {
  var photourl;
  //List<Post> posts = [];
  List<Post_Tile> postTiles = [];
  bool isLoading = false;
  bool isPostLoadFail = false;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "Landing_Page");
    if (widget.isErrorLoadingPost) isPostLoadFail = true;
    //getUserPosts();
  }

  Future<void> getUserPosts() async {
    setState(() {
      widget.isLoading = true;
    });
    var user = await FirebaseAuth.instance.currentUser();
    photourl = user.photoUrl;

    var id = curUser.id;
    final url = storyEndPoint + "$id/all";
    var token = await user.getIdToken();
    var response;
    try {
      response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    } catch (e) {
      setState(() {
        widget.isLoading = false;
        isPostLoadFail = true;
      });
      return;
    }
    print("body is ${response.body}");
    //print(response.statusCode);

    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      //print("body is $body");
      //print(body1);
      var msg = body1['message'];
      //print(msg.length);
      //print("msg id ${msg}");
      List<Post> posts = [];
      for (int i = 0; i < msg.length; i++) {
        //print("msg $i is ${msg[i]}");
        Post post;
        if (msg[i]['StoryType'] == "Investment")
          post = Post.fromJsonI(msg[i]);
        else
          post = Post.fromJsonW(msg[i]);
        if (post != null) {
          //print(post.investedWithUser);
          posts.add(post);
        }
      }
      //print(posts.length);
      setState(() {
        widget.posts = posts;
        widget.isLoading = false;
      });
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  buildPosts() {
    print("build started");
    setState(() {
      widget.isLoading = true;
    });
    if (widget.posts.isEmpty) {
      setState(() {
        widget.isLoading = false;
      });
      return Scaffold(
          body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              kLandingPageEmptyText,
              style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorHintText),
            ),
            Text(
              kLandingPageEmptySubtext,
              style: TextStyle(
                  fontFamily: "Lato", fontSize: 15, color: colorHintText),
            ),
          ],
        ),
      ));
    } else {
      List<Post_Tile> postTiles = [];
      //print(posts.length);
      for (int i = 0; i < widget.posts.length; i++) {
        Post_Tile tile = Post_Tile(
            curUser: widget.curUser,
            userPost: widget.posts[i],
            photoUrl: photourl);
        postTiles.add(tile);
      }
      setState(() {
        this.postTiles = postTiles;
        widget.isLoading = false;
      });
      return ListView(
        children: postTiles.reversed.toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.withOpacity(0.2),
        body: isPostLoadFail == true
            ? ErrWidget(
                tryAgainOnPressed: () {
                  setState(() {
                    this.isPostLoadFail = false;
                  });
                  getUserPosts();
                },
                showLogout: false,
              )
            : (widget.isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: getUserPosts, child: buildPosts())));
  }
}
