import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Widgets/post_tile.dart';

import '../post.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;

class Landing_Page extends StatefulWidget {
  @override
  _Landing_PageState createState() => _Landing_PageState();
}

class _Landing_PageState extends State<Landing_Page> {
  var photourl;
  List<Post> posts = [];
  bool isLoading =true;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "Landing_Page");
    getUserPosts();
  }

  getUserPosts() async
  {
    var user = await FirebaseAuth.instance.currentUser();
    photourl = user.photoUrl;
    DocumentSnapshot doc = await users.document(user.uid).get();
    if (doc == null)
      print("error from get user post");
    var id = doc['id'];
    final url =
        "https://t43kpz2m5d.execute-api.ap-south-1.amazonaws.com/story/${id}/all";
    var token = await user.getIdToken();
    //print(token);
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    });
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
      //print("msg id ${msg}");
      for (int i=0;i<msg.length;i++) {
        //print("msg $i is ${msg[i]}");
        Post post;
        if(msg[i]['StoryType']=="Investment")
          post = Post.fromJsonI(msg[i]);
        else
          post = Post.fromJsonW(msg[i]);
        if(post!=null)
          {
            print(post.investedWithUser);
            posts.add(post);
          }
      }
      print(posts.length);
      setState(() {
        isLoading=false;
      });
    }
      else {
        print(response.statusCode);
        throw Exception();
      }
  }

  buildPosts()
  {
    setState(() {
      isLoading=true;
    });
    if(posts.isEmpty)
      {
        setState(() {
          isLoading=false;
        });
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Welcome to your timeline",
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff263238)
                  ),
                ),
                Text(
                  "It's empty now, but it won't be for long.",
                  style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 15,
                      color: Color(0xff263238)
                  ),
                ),
              ],
            ),
          )
        );
      }
    else{
      List<Post_Tile> postTiles = [];
      //print(posts.length);
      for(int i=0;i<posts.length;i++)
        {
          Post_Tile tile = Post_Tile(userPost: posts[i],photoUrl:photourl);
          postTiles.add(tile);
        }
      setState(() {
        isLoading=false;
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
      body: isLoading? Center(
        child: CircularProgressIndicator(),
    ) : buildPosts()
    );
  }
}
