import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rsocial2/Widgets/post_tile.dart';
import 'package:rsocial2/controller.dart';
import 'package:rsocial2/helper.dart';

import '../contants/config.dart';
import '../model/post.dart';
import 'bottom_nav_bar.dart';

class DisplayPost extends StatefulWidget {
  String postId;
  DisplayPost({this.postId});

  @override
  _DisplayPostState createState() => _DisplayPostState();
}

class _DisplayPostState extends State<DisplayPost> {
  bool isLoading = false;
  Post_Tile post_tile;
  ReusableVideoListController reusableVideoListController;
  @override
  void initState() {
    super.initState();
    getPost();
  }

  @override
  void dispose() {
    super.dispose();
    reusableVideoListController.dispose();
  }

  Future<void> getPost() async {
    try {
      setState(() {
        isLoading = true;
      });
      User user = authFirebase.currentUser;
      var token = await user.getIdToken();
      String id;
      if (curUser == null) {
        id = savedUser.id;
      } else {
        id = curUser.id;
      }
      final response = await postFunc(
        url: storyEndPoint + "getstory",
        token: token,
        body: jsonEncode(
          {
            "id": id,
            "storyId": widget.postId,
          },
        ),
      );
      if (response.statusCode == 200) {
        var responseMessage =
            jsonDecode((jsonDecode(response.body))['body'])['message'];
        Post post;
        if (responseMessage['StoryType'] == "Investment")
          post = Post.fromJsonI(responseMessage);
        else
          post = Post.fromJsonW(responseMessage);
        if (post != null) {
          int index =
              postsGlobal.indexWhere((element) => element.id == widget.postId);
          if (index != -1) {
            postsGlobal[index] = post;
          }
          reusableVideoListController = ReusableVideoListController();
          post_tile = Post_Tile(
            showPopup: false,
            curUser: curUser == null ? savedUser : curUser,
            userPost: post,
            photoUrl: curUser == null ? savedUser.photoUrl : curUser.photoUrl,
            reusableVideoListController: reusableVideoListController,
            canBuild: () => true,
          );
        }
        setState(() {
          isLoading = false;
        });
      } else {
        print(response.body.toString());
        throw Exception(["Some error has occured. Please try again later."]);
      }
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
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
