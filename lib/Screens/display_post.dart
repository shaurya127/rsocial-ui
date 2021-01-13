import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Widgets/post_tile.dart';

import '../config.dart';
import '../post.dart';
import 'bottom_nav_bar.dart';
import 'package:http/http.dart' as http;

class DisplayPost extends StatefulWidget {

  String postId;
  DisplayPost({this.postId});

  @override
  _DisplayPostState createState() => _DisplayPostState();
}

class _DisplayPostState extends State<DisplayPost> {
  bool isLoading =false;
  Post_Tile post_tile;
  @override
  void initState() {
    super.initState();
    getUserPosts();
  }

  Future<void> getUserPosts() async {
    setState(() {
      isLoading = true;
    });
    var user = await FirebaseAuth.instance.currentUser();
    //DocumentSnapshot doc = await users.document(user.uid).get();
    //if (doc == null) print("error from get user post");
    //var id = doc['id'];
    var id = curUser.id;
    final url = storyEndPoint + "$id/${widget.postId}";
    var token = await user.getIdToken();
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    //print("body is ${response.body}");
    //print(response.statusCode);

    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      //print("body is $body");
      //print(body1);
      var msg = body1['message'];
      //print(msg.length);
      print("--------------------------------------------------");
      print("msg is ${msg}");

        //print("msg $i is ${msg[i]}");
        Post post;
        if (msg['StoryType'] == "Investment")
          post = Post.fromJsonI(msg);
        else
          post = Post.fromJsonW(msg);
        if (post != null) {
          //print(post.investedWithUser);
          post_tile = Post_Tile(curUser: curUser,userPost: post,photoUrl: curUser.photoUrl,);
        }
        setState(() {
          isLoading=false;
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
        title: Text("Post"),
      ),
      body: !isLoading ? ListView(
        children: <Widget>[
          post_tile,
        ],
      ) : Center(child: CircularProgressIndicator(),),
    );
  }
}
