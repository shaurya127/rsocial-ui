import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/error.dart';
import 'package:rsocial2/Widgets/post_tile.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/contants/constants.dart';

import '../helper.dart';
import '../model/post.dart';
import '../model/user.dart';
import 'bottom_nav_bar.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;

class Landing_Page extends StatefulWidget {
  User curUser;
  bool isLoading;
  bool hasNoPosts;
  ScrollController scrollController;
  bool isErrorLoadingPost;
  Function reactionCallback;

  Landing_Page(
      {this.curUser,
      this.isLoading,
      this.isErrorLoadingPost,
      this.reactionCallback,
      this.hasNoPosts,
      this.scrollController});

  @override
  _Landing_PageState createState() => _Landing_PageState();
}

class _Landing_PageState extends State<Landing_Page> {
  final key = GlobalKey<AnimatedListState>();
  var photourl;

  //List<Post> posts = [];
  bool isLoading = false;
  bool isPostLoadFail = false;
  int length;
  bool isFailedUserPost = false;
  int page = 0;
  bool startLoadingTile=false;

  @override
  void initState() {
    print("Init state of landing page called");
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "Landing_Page");
    if (widget.isErrorLoadingPost) isPostLoadFail = true;
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent) {
        if (storiesStillLeft) {
          setState(() {
            page = page + 10;
          });
          print("i was called with $page and $storiesStillLeft");
          getUserPosts(curUser != null
              ? curUser.id
              : (savedUser != null ? savedUser.id : null));
        }
      }
    });
  }

  Future<void> getUserPosts(String id) async {
    print("getUserPostFired");
    FirebaseUser user;
    user = await authFirebase.currentUser();
    var token = await user.getIdToken();
    if (id == null) {
      try {
        user = await authFirebase.currentUser();
        DocumentSnapshot doc = await users.document(user.uid).get();
        if (doc == null) print("error from get user post");
        id = doc['id'];
      } catch (e) {
        setState(() {
          widget.isLoading=false;
          isFailedUserPost = true;
        });
      }
    }

    var response = await postFunc(
        url: storyEndPoint + "all",
        token: token,
        body: jsonEncode({"id": id, "start_token": page}));

    if (response == null) {
      setState(() {
        isFailedUserPost = true;
      });
      return true;
    }

    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];

      var responseStories = responseMessage['stories'];
      var storiesLeft = responseMessage['still_left'];

      List<Post> posts = [];
      if (responseMessage != []) {
        for (int i = 0; i < responseStories.length; i++) {
          Post post;
          if (responseStories[i]['StoryType'] == "Investment")
            post = Post.fromJsonI(responseStories[i]);
          else
            post = Post.fromJsonW(responseStories[i]);
          if (post != null) {
            //print(post.investedWithUser);
            posts.add(post);
          }
        }
      }
      setState(() {
        widget.isLoading=false;
        startLoadingTile=false;
        isFailedUserPost=false;
        postsGlobal.addAll(posts);
        storiesStillLeft = storiesLeft;
        print("now setting stories left to $storiesLeft and $storiesStillLeft");
      });
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  buildPosts() {
    print("build started");
    print(postsGlobal.length);
    setState(() {
      widget.isLoading = true;
    });
    if (widget.hasNoPosts) {
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
    }
    else if(isFailedUserPost && postsGlobal.length==0){
      print("i am here!!!");
      print(postsGlobal.length);
      return ErrWidget(
        tryAgainOnPressed: () {
          setState(() {
            widget.isLoading = true;
            isFailedUserPost = false;
          });
          getPostOnRefresh();
        },
        showLogout: false,
      );
    }
    else {
      setState(() {
        widget.isLoading = false;
      });

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: postsGlobal.length +
                  1, // Add one more item for progress indicator
              itemBuilder: (BuildContext context, int index) {
                if (index == postsGlobal.length) {
                  if(isFailedUserPost && postsGlobal.length!=0)
                    return ErrWidget(
                      tryAgainOnPressed: () {
                        setState(() {
                          startLoadingTile = true;
                          isFailedUserPost = false;
                        });
                        getUserPosts(curUser!=null?curUser.id:savedUser.id);
                      },
                      showLogout: false,
                      text: "",
                    );
                  else if ((storiesStillLeft == true && postsGlobal.length != 0) || startLoadingTile)
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  else
                    return SizedBox();
                } else {
                  return new Post_Tile(
                      curUser: curUser,
                      onPressDelete: () => deletePost(index),
                      userPost: postsGlobal[index],
                      photoUrl: photourl,
                      reactionCallback: reactionCallback);
                }
              },
              controller: widget.scrollController,
            ),

            //     AnimatedList(
            //   key: key,
            //   initialItemCount: length,
            //   itemBuilder: (context, index, animation) => Post_Tile(
            //       curUser: curUser,
            //       onPressDelete: () => deletePost(index),
            //       userPost: postsGlobal[index],
            //       photoUrl: photourl,
            //       reactionCallback: reactionCallback),
            // )
          ),
        ],
      );
    }
  }

  Future<void> getPostOnRefresh() async {
    setState(() {
      page = 0;
      postsGlobal.clear();
    });
    return getUserPosts(curUser != null
        ? curUser.id
        : (savedUser != null ? savedUser.id : null));
  }

  getPostOnDelete() async {
    setState(() {
      page = 0;
      widget.isLoading = true;
      postsGlobal.clear();
    });
    getUserPosts(curUser != null
        ? curUser.id
        : (savedUser != null ? savedUser.id : null));
    setState(() {
      widget.isLoading = false;
    });
  }

  void deletePost(int index) async {
    var url = storyEndPoint + 'delete';
    var user = await FirebaseAuth.instance.currentUser();
    var token = await user.getIdToken();

    var response;
    Navigator.pop(context);

    response = await http.post(
      url,
      encoding: Encoding.getByName("utf-8"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"id": curUser.id, "StoryId": postsGlobal[index].id}),
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      // print("post length 1 id ${postsGlobal.length}");
      // print("post length 1 id ${postsGlobal[0].user.fname}");
      // key.currentState.removeItem(
      //     index, (context, animation) => slideIt(context, index, animation),
      //     duration: const Duration(milliseconds: 500));
      // print("post length 2 id ${postsGlobal.length}");
      final item = postsGlobal.removeAt(index);
      // print("post length 3 id ${postsGlobal.length}");
      // print("post length 3 id ${postsGlobal[0].user.fname}");
      // print("post length 3 id ${postsGlobal[1].user.fname}");
      // setState(() {
      // });
      //buildPosts();
      getPostOnRefresh();
    } else
      Fluttertoast.showToast(
          msg: "Error deleting post please try again later",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);
  }

  reactionCallback() {
    if (widget.reactionCallback != null) widget.reactionCallback();
  }

  slideIt(BuildContext context, int index, animation) {
    var item = postsGlobal.removeAt(index);
    print("in slide it ${item.user.fname}");

    return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset(0, 0),
        ).animate(animation),
        child: Post_Tile(
          curUser: curUser,
          photoUrl: "",
          onPressDelete: () => deletePost(index),
          userPost: item,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.withOpacity(0.2),
        body:
        // isPostLoadFail == true
        //     ? ErrWidget(
        //         tryAgainOnPressed: () {
        //           setState(() {
        //             this.isPostLoadFail = false;
        //           });
        //           getUserPosts(curUser != null
        //               ? curUser.id
        //               : (savedUser != null ? savedUser.id : null));
        //         },
        //         showLogout: false,
        //       )
        //     :
        (widget.isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: getPostOnRefresh, child: buildPosts())));
  }
}
