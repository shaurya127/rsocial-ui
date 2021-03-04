import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/post_tile.dart';
import 'package:rsocial2/helper.dart';

import '../contants/config.dart';
import '../model/post.dart';
import 'bottom_nav_bar.dart';
import 'package:http/http.dart' as http;

class DisplayPost extends StatefulWidget {
  String postId;
  DisplayPost({this.postId});

  @override
  _DisplayPostState createState() => _DisplayPostState();
}

class _DisplayPostState extends State<DisplayPost> {
  bool isLoading = false;
  Post_Tile post_tile;
  @override
  void initState() {
    super.initState();
    getPost();
  }

  Future<void> getPost() async {
    setState(() {
      isLoading = true;
    });
    var user = await authFirebase.currentUser();
    var token = await user.getIdToken();
    var id = curUser.id;

    final response = await getFunc(
        url: storyEndPoint + "$id/${widget.postId}", token: token);

    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];

      Post post;
      if (responseMessage['StoryType'] == "Investment")
        post = Post.fromJsonI(responseMessage);
      else
        post = Post.fromJsonW(responseMessage);
      if (post != null) {
        //print(post.investedWithUser);
        post_tile = Post_Tile(
          showPopup: false,
          curUser: curUser,
          userPost: post,
          photoUrl: curUser.photoUrl,
        );
      }
      setState(() {
        isLoading = false;
      });
      //print(posts.length);
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Post",
          style: TextStyle(fontFamily: 'Lato', color: Colors.white),
        ),
      ),
      body: !isLoading
          ? ListView(
              children: <Widget>[
                post_tile,
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
