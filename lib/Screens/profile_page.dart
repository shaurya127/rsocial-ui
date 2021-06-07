import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as im;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rsocial2/Screens/all_connections.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/login_page.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:http/http.dart' as http;
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/Widgets/error.dart';
import 'package:rsocial2/Widgets/invest_post_tile.dart';
import 'package:rsocial2/Widgets/post_tile.dart';
import 'package:rsocial2/Widgets/request_button.dart';
import 'package:rsocial2/Widgets/selectButton.dart';
import 'package:rsocial2/auth.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/controller.dart';
import 'package:rsocial2/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../helper.dart';
import '../model/user.dart';

import '../contants/config.dart';
import '../model/post.dart';

class Profile extends StatefulWidget {
  Function reactionCallback;

  @override
  _ProfileState createState() => _ProfileState();
  User currentUser;
  User user;
  String photoUrl;
  bool isLoading = false;
  String previousWidget;

  String text;
  Profile({
    this.currentUser,
    this.photoUrl,
    this.user,
    this.reactionCallback,
  });
}

class _ProfileState extends State<Profile> {
  String path;
  String postOrientation = "wage";
  bool isLoading = false;
  bool isLoadingUser = true;
  List<Post> postsW = [];
  List<Post> postsI = [];
  List<Post> platformPost = [];
  TextEditingController bioController = TextEditingController();
  bool isEditable = false;
  File file;
  String encodedFile;
  bool isPlatformLoading = true;
  bool isUserPostFail = false;
  bool isPlatformPostFail = false;
  bool isPhotoEditedComplete = false;
  bool isLoadingPosts = false;
  bool isWageloading = true;
  bool isInvestLoading = true;
  bool isWagepostFail = false;
  bool isInvestPostFail = false;
  ReusableVideoListController reusableVideoListController;
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollControllerWage =
      ScrollController(keepScrollOffset: false);
  ScrollController _scrollControllerInvest =
      ScrollController(keepScrollOffset: false);
  ScrollController _scrollControllerMain =
      ScrollController(keepScrollOffset: false);
  final key = GlobalKey<AnimatedListState>();
  int page = 0;
  int pagewage = 0;
  int pageinvest = 0;
  bool platformStoriesStillLeft = true;
  bool wagePostsLeft = true;
  bool investPostsLeft = true;

  saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("get user finished");
    prefs.setString('FName', curUser.fname);
    prefs.setString('LName', curUser.lname);
    prefs.setInt('socialStanding', curUser.socialStanding);
    prefs.setInt('yollarAmount', curUser.lollarAmount);
    prefs.setInt('totalConnections', curUser.connectionCount);
    prefs.setString('profilePhoto', curUser.photoUrl);
  }

  getSocialStanding() async {
    print("Get social standing triggered");
    var token;
    try {
      var user = authFirebase.currentUser;
      token = await user.getIdToken();
    } catch (e) {
      return;
    }

    var id = widget.user.id;
    if (id == null) return;
    var response = await postFunc(
        url: userEndPoint + "socialstanding",
        token: token,
        body: jsonEncode({"id": id}));

    if (response == null) {
      return;
    }
    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];

      try {
        widget.user.lollarAmount = responseMessage['yollar'];
        widget.user.socialStanding = responseMessage['rank'];
        setState(() {});
      } catch (e) {
        print("Exception " + e + "in social standing");
      }
    }
  }

  Future<void> getUser() async {
    print(widget.user.id);
    print("get user started");
    setState(() {
      isLoadingUser = true;
    });
    var user = auth.FirebaseAuth.instance.currentUser;
    var token;

    var id = curUser == null ? savedUser.id : curUser.id;
    final url = userEndPoint + "userprofile";

    var response;
    try {
      token = await user.getIdToken();
      var uri = Uri.parse(url);
      response = await http.post(uri,
          encoding: Encoding.getByName("utf-8"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            //"Accept": "*/*"
          },
          body: jsonEncode({"id": widget.user.id}));
    } catch (e) {
      return null;
    }
    //print("This is my response: $response");
    print("Get User response");
    print(response.body);
    //print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      //print("body is $body");
      // print(body1);
      var msg = body1['message'];
      //print("id is: ${msg['id']}");
      //print(msg);
      if (msg == 'User Not Found') {
        return;
      }

      widget.user = User.fromJson(msg);
      print("Widget user bio is : ");
      print(widget.user.bio);
      if (widget.user != null) getSocialStanding();

      if (widget.user.id == (curUser == null ? savedUser.id : curUser.id))
        await saveData();
      setState(() {
        isLoadingUser = false;
      });
    } else {
      print(response.statusCode);
    }
  }

  String newBio;

  @override
  void initState() {
    super.initState();
    reusableVideoListController = ReusableVideoListController();
    if (widget.user.id != (curUser == null ? savedUser.id : curUser.id)) {
      getUser().then((_) {
        getWagePostInitial();
        getInvestPostInitial();
        getPlatformPostsInitial();
        isEditable = false;
      });
    } else {
      setState(() {
        isLoadingUser = false;
        widget.user = curUser;
      });
      getWagePostInitial();
      getInvestPostInitial();
      getPlatformPostsInitial();
      isEditable = false;
    }
    _scrollControllerWage.addListener(() {
      _scrollControllerMain.animateTo(_scrollControllerWage.offset,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
    _scrollControllerInvest.addListener(() {
      _scrollControllerMain.animateTo(_scrollControllerInvest.offset,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
    _scrollController.addListener(() {
      _scrollControllerMain.animateTo(_scrollController.offset,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });

    bioController.text =
        widget.user.bio != null ? widget.user.bio.trim() : "here comes the bio";
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (platformStoriesStillLeft) {
          setState(() {
            page = page + 10;
          });
          print("i was called with $page and $platformStoriesStillLeft");
          getPlatformPosts();
        }
      }
    });
    _scrollControllerWage.addListener(() {
      if (_scrollControllerWage.position.pixels ==
          _scrollControllerWage.position.maxScrollExtent) {
        if (wagePostsLeft) {
          setState(() {
            pagewage = pagewage + 10;
          });
          print("i was called with $pagewage and $wagePostsLeft");
          getWagePosts();
        }
      }
    });
    _scrollControllerInvest.addListener(() {
      if (_scrollControllerInvest.position.pixels ==
          _scrollControllerInvest.position.maxScrollExtent) {
        if (investPostsLeft) {
          setState(() {
            pageinvest = pageinvest + 10;
          });
          print("i was called with $pageinvest and $investPostsLeft");
          getInvestPosts();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    reusableVideoListController.dispose();
    _scrollController.dispose();
    _scrollControllerInvest.dispose();
    _scrollControllerMain.dispose();
    _scrollControllerWage.dispose();
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    var status = await Permission.camera.status;

    if (status.isGranted || status.isLimited) {
      PickedFile pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        // maxHeight: 675,
        // maxWidth: 960,
      );
      if (pickedFile != null) {
        file = await _cropImage(pickedFile.path);
        // file = File(pickedFile.path);
        if (file != null) {
          print("File size");
          print(file.lengthSync());

          if (file.lengthSync() > 5000000) {
            file = await compressImage(file);
            print("New length =" + file.lengthSync().toString());

            print("not allowed");
            if (file.lengthSync() > 5000000) {
              var alertBox = AlertDialogBox(
                title: 'Error',
                content: 'Image is too large',
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Back'),
                  )
                ],
              );
              showDialog(context: context, builder: (context) => alertBox);
              return;
            }
          }

          final bytes = file.readAsBytesSync();
          String img64 = base64Encode(bytes);
          setState(() {
            encodedFile = img64;
          });
        }
      }
    } else {
      var alertBox = AlertDialogBox(
        title: "Camera Permission",
        content: "This app needs camera access to take photos",
        actions: <Widget>[
          FlatButton(
            child: Text("Settings"),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
          ),
          FlatButton(
            child: Text("Deny"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
      showDialog(context: context, builder: (context) => alertBox);
    }
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    var status = await Permission.storage.status;

    if (status.isGranted || status.isLimited) {
      try {
        PickedFile pickedFile = await ImagePicker().getImage(
          source: ImageSource.gallery,
          // maxHeight: 675,
          // maxWidth: 960,
        );
        if (pickedFile != null) {
          file = await _cropImage(pickedFile.path);
          //file = File(pickedFile.path);
          if (file != null) {
            print("File size");
            print(file.lengthSync());
            if (file.lengthSync() > 5000000) {
              file = await compressImage(file);
              print("New length =" + file.lengthSync().toString());

              print("not allowed");
              if (file.lengthSync() > 5000000) {
                var alertBox = AlertDialogBox(
                  title: 'Error',
                  content: 'Image is too large',
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Back'),
                    )
                  ],
                );
                showDialog(context: context, builder: (context) => alertBox);
                return;
              }
            }
            final bytes = file.readAsBytesSync();
            String img64 = base64Encode(bytes);
            setState(() {
              encodedFile = img64;
            });
          }
        }
      } on PlatformException catch (e) {
        if (e.code == 'photo_access_denied') {
          print(e);

          var alertBox = AlertDialogBox(
            title: "Gallery Permission",
            content: "This app needs gallery access to take photos",
            actions: <Widget>[
              FlatButton(
                child: Text("Settings"),
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
              ),
              FlatButton(
                child: Text("Deny"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
          showDialog(context: context, builder: (context) => alertBox);
        }
      }
    } else {
      var alertBox = AlertDialogBox(
        title: "Gallery Permission",
        content: "This app needs gallery access to take photos",
        actions: <Widget>[
          FlatButton(
            child: Text("Settings"),
            onPressed: () {
              openAppSettings();
            },
          ),
          FlatButton(
            child: Text("Deny"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
      showDialog(context: context, builder: (context) => alertBox);
    }

    //  print(list);
  }

  // getUserPosts() async {
  //   postsI = [];
  //   postsW = [];
  //   setState(() {
  //     isLoadingPosts = true;
  //   });
  //   print("get user post fired");
  //   var user = auth.FirebaseAuth.instance.currentUser;
  //   final url = storyEndPoint + "${widget.user.id}";
  //   var token = await user.getIdToken();
  //   //print(token);
  //   var response;
  //   try {
  //     print("URL:$url");
  //     print("TOKEN:$token");
  //     response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //     );
  //   } catch (e) {
  //     setState(() {
  //       widget.isLoading = false;
  //       isUserPostFail = true;
  //     });
  //     return;
  //   }

  //   if (response.statusCode == 200) {
  //     final jsonUser = jsonDecode(response.body);
  //     var body = jsonUser['body'];
  //     var body1 = jsonDecode(body);
  //     //print("body is $body");
  //     //print(body1);
  //     var msg = body1['message'];
  //     //print(msg.length);
  //     //print("msg id ${msg}");
  //     for (int i = 0; i < msg.length; i++) {
  //       print("msg $i is ${msg[i]}");
  //       Post post;
  //       if (msg[i]['StoryType'] == "Investment")
  //         post = Post.fromJsonI(msg[i]);
  //       else
  //         post = Post.fromJsonW(msg[i]);
  //       if (post != null) {
  //         if (msg[i]['StoryType'] == "Investment")
  //           postsI.add(post);
  //         else
  //           postsW.add(post);
  //       }
  //     }
  //     print("get user post finished");
  //     // print(postsW.length);
  //     // print(postsI.length);
  //     // buildInvestPosts();
  //     // buildWagePosts();
  //     setState(() {
  //       isLoadingPosts = false;
  //     });
  //     setState(() {});
  //   } else {
  //     print(response.statusCode);
  //     throw Exception();
  //   }
  // }

  getPlatformPosts() async {
    var user = auth.FirebaseAuth.instance.currentUser;
    final url = storyEndPoint + 'userplatformactivity';
    var token = await user.getIdToken();
    //print(token);
    var response;
    try {
      response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          {
            "requester_id": curUser.id,
            "id": widget.user.id,
            "start_token": page,
          },
        ),
      );
    } catch (e) {
      setState(() {
        isPlatformLoading = false;
        isPlatformPostFail = true;
      });
    }

    if (response == null) {
      setState(() {
        isPlatformLoading = false;
        isPlatformPostFail = true;
      });
      return;
    }
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['statusCode'] == 200) {
      var body = jsonResponse['body'];
      var body1 = jsonDecode(body);
      List<Post> list = [];
      var msg = body1['message']['stories'];
      var platformStoriesLeft = body1['message']['still_left'];
      print("Platform Posts");
      print(msg);
      for (int i = 0; i < msg.length; i++) {
        Post post;
        if (msg[i]['StoryType'] == "Investment")
          post = Post.fromJsonI(msg[i]);
        else
          post = Post.fromJsonW(msg[i]);
        if (post != null) {
          list.add(post);
        }
      }
      setState(() {
        platformPost.addAll(list);
        platformStoriesStillLeft = platformStoriesLeft;
      });
    }
  }

  getInvestPostInitial() async {
    setState(() {
      isInvestLoading = true;
    });
    await getInvestPosts();
    setState(() {
      isInvestLoading = false;
    });
  }

  getPlatformPostsInitial() async {
    setState(() {
      isPlatformLoading = true;
    });
    await getPlatformPosts();
    setState(() {
      isPlatformLoading = false;
    });
  }

  getWagePostInitial() async {
    setState(() {
      isWageloading = true;
    });
    await getWagePosts();
    setState(() {
      isWageloading = false;
    });
  }

  Future<void> getWagePosts() async {
    var user = auth.FirebaseAuth.instance.currentUser;
    final url = storyEndPoint + "getuserwassup";
    var token = await user.getIdToken();
    var response;
    try {
      response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          {
            "requester_id": curUser.id,
            "id": widget.user.id,
            "start_token": pagewage,
          },
        ),
      );
    } catch (e) {
      setState(() {
        isWageloading = false;
        isWagepostFail = true;
      });
    }

    if (response == null) {
      setState(() {
        isWageloading = false;
        isWagepostFail = true;
      });
      return;
    }

    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];

      var responseStories = responseMessage['stories'];
      var storiesLeft = responseMessage['still_left'];

      List<Post> wageposts = [];
      if (responseMessage != []) {
        for (int i = 0; i < responseStories.length; i++) {
          Post post;
          responseStories[i]["UserId"] = {
            "id": widget.user.id,
            "FName": widget.user.fname,
            "LName": widget.user.lname,
            "ProfilePic": widget.user.photoUrl,
          };
          post = Post.fromJsonW(responseStories[i]);
          if (post != null) {
            wageposts.add(post);
          }
        }
      }
      setState(() {
        isWagepostFail = false;
        postsW.addAll(wageposts);
        wagePostsLeft = storiesLeft;
      });
    } else {
      throw Exception();
    }
  }

  Future<void> getInvestPosts() async {
    var user = auth.FirebaseAuth.instance.currentUser;
    final url = storyEndPoint + "getuserinvest";
    var token = await user.getIdToken();
    var response;
    try {
      response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          {
            "requester_id": curUser.id,
            "id": widget.user.id,
            "start_token": pageinvest,
          },
        ),
      );
    } catch (e) {
      setState(() {
        isInvestLoading = false;
        isInvestPostFail = true;
      });
    }

    if (response == null) {
      setState(() {
        isInvestLoading = false;
        isInvestPostFail = true;
      });
      return;
    }

    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];

      var responseStories = responseMessage['stories'];
      var storiesLeft = responseMessage['still_left'];

      List<Post> investposts = [];
      if (responseMessage != []) {
        for (int i = 0; i < responseStories.length; i++) {
          Post post;
          responseStories[i]["UserId"] = {
            "id": widget.user.id,
            "FName": widget.user.fname,
            "LName": widget.user.lname,
            "ProfilePic": widget.user.photoUrl,
          };
          post = Post.fromJsonI(responseStories[i]);
          if (post != null) {
            investposts.add(post);
          }
        }
      }
      setState(() {
        isInvestPostFail = false;
        postsI.addAll(investposts);
        investPostsLeft = storiesLeft;
      });
    } else {
      throw Exception();
    }
  }

  buildWagePosts() {
    if (postsW.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "No $postOrientation story yet!",
              style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorHintText),
            ),
            widget.user.id == widget.currentUser.id
                ? Text(
                    kProfilePageWage,
                    style: TextStyle(
                        fontFamily: "Lato", fontSize: 15, color: colorHintText),
                  )
                : Container()
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollControllerWage,
              itemCount:
                  postsW.length + 1, // Add one more item for progress indicator
              itemBuilder: (BuildContext context, int index) {
                if (index == postsW.length) {
                  if (wagePostsLeft == true && postsW.length != 0)
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  else
                    return SizedBox();
                } else {
                  Post_Tile tile = Post_Tile(
                    key: ValueKey(postsW[index].id),
                    canBuild: () => true,
                    onPressDelete: () =>
                        deletePost(index, "wage", postsW[index].id),
                    curUser: widget.currentUser,
                    userPost: postsW[index],
                    photoUrl: (curUser == null ? savedUser.id : curUser.id) ==
                            widget.user.id
                        ? curUser.photoUrl
                        : widget.user.photoUrl,
                    reusableVideoListController: reusableVideoListController,
                  );
                  return tile;
                }
              },
            ),
          ),
        ],
      );
    }
  }

  buildInvestPosts() {
    if (postsI.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "No $postOrientation story yet!",
              style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorHintText),
            ),
            widget.user.id == widget.currentUser.id
                ? Text(
                    kProfilePageInvestment,
                    style: TextStyle(
                        fontFamily: "Lato", fontSize: 15, color: colorHintText),
                  )
                : Container(),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollControllerInvest,
              itemCount:
                  postsI.length + 1, // Add one more item for progress indicator
              itemBuilder: (BuildContext context, int index) {
                if (index == postsI.length) {
                  if (investPostsLeft == true && postsI.length != 0)
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  else
                    return SizedBox();
                } else {
                  Post_Tile tile = Post_Tile(
                    key: ValueKey(postsI[index].id),
                    canBuild: () => true,
                    onPressDelete: () =>
                        deletePost(index, "invest", postsI[index].id),
                    curUser: widget.currentUser,
                    userPost: postsI[index],
                    photoUrl: (curUser == null ? savedUser.id : curUser.id) ==
                            widget.user.id
                        ? curUser.photoUrl
                        : widget.user.photoUrl,
                    reusableVideoListController: reusableVideoListController,
                  );
                  return tile;
                }
              },
            ),
          ),
        ],
      );
    }
  }

  buildPlatformInteraction() {
    if (platformPost.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "No $postOrientation interaction yet!",
              style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorHintText),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: platformPost.length +
                  1, // Add one more item for progress indicator
              itemBuilder: (BuildContext context, int index) {
                if (index == platformPost.length) {
                  if (platformStoriesStillLeft == true &&
                      platformPost.length != 0)
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  else
                    return SizedBox();
                } else {
                  return new Post_Tile(
                    key: ValueKey(platformPost[index].id),
                    curUser: curUser,
                    canBuild: () => true,
                    //onPressDelete: () => deletePost(index, ""),
                    userPost: platformPost[index],
                    photoUrl: "",
                    reactionCallback: reactionCallback,
                    reusableVideoListController: reusableVideoListController,
                  );
                }
              },
              controller: _scrollController,
            ),
          ),
        ],
      );
    }
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Change Profile Photo"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Take photo from Camera"),
                onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text("Upload photo from Gallery"),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  buildButton() {
    return RequestButton(
      text: curUser.userMap.containsKey(widget.user.id)
          ? curUser.userMap[widget.user.id]
          : "add",
      user: widget.user,
    );
  }

  buildEditButton() {
    if (!isEditable) {
      return GestureDetector(
        child: Text(
          "Edit",
          style: TextStyle(
              color: colorPrimaryBlue,
              decoration: TextDecoration.underline,
              fontFamily: 'Lato',
              fontSize: 15),
        ),
        onTap: () {
          setState(() {
            isEditable = true;
          });
        },
      );
      //   IconButton(
      //   icon: Icon(
      //     Icons.edit,
      //     color: colorPrimaryBlue,
      //   ),
      //   onPressed: () {
      //     setState(() {
      //       isEditable = true;
      //     });
      //   },
      // );
    } else {
      return GestureDetector(
        onTap: () async {
          if (newBio != widget.currentUser.bio || encodedFile != null) {
            setState(() {
              bioController.text = newBio;
              isLoading = true;
            });
            var response;
            var user = auth.FirebaseAuth.instance.currentUser;
            var token = await user.getIdToken();
            String url = userEndPoint + 'update';
            print("New bio");
            print(newBio);

            if (encodedFile == null) {
              try {
                response = await http.put(
                  Uri.parse(url),
                  encoding: Encoding.getByName("utf-8"),
                  body: jsonEncode({
                    'id': (curUser == null ? savedUser.id : curUser.id),
                    'bio': newBio
                  }),
                  headers: {
                    "Authorization": "Bearer: $token",
                    "Content-Type": "application/json",
                  },
                );
              } catch (e) {
                setState(() {
                  isLoading = false;
                  isEditable = false;
                  bioController.text = widget.currentUser.bio;
                });
                Fluttertoast.showToast(
                    msg: "Error occured",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    fontSize: 15);
              }
            } else if (newBio == widget.currentUser.bio) {
              try {
                response = await http.put(
                  Uri.parse(url),
                  encoding: Encoding.getByName("utf-8"),
                  body: jsonEncode({
                    'id': (curUser == null ? savedUser.id : curUser.id),
                    'profilepic': encodedFile,
                  }),
                  headers: {
                    "Authorization": "Bearer: $token",
                    "Content-Type": "application/json",
                  },
                );
                isPhotoEditedComplete = true;
                Fluttertoast.showToast(
                    msg:
                        "Profile pic is updated and changes will be visible soon.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    fontSize: 15);
              } catch (e) {
                setState(() {
                  isLoading = false;
                  isEditable = false;
                  bioController.text = widget.currentUser.bio;
                });
                Fluttertoast.showToast(
                    msg: "Error occured",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    fontSize: 15);
              }
            } else {
              try {
                response = await http.put(
                  Uri.parse(url),
                  encoding: Encoding.getByName("utf-8"),
                  body: jsonEncode({
                    'id': (curUser == null ? savedUser.id : curUser.id),
                    'profilepic': encodedFile,
                    'bio': newBio
                  }),
                  headers: {
                    "Authorization": "Bearer: $token",
                    "Content-Type": "application/json",
                  },
                );

                isPhotoEditedComplete = true;
                Fluttertoast.showToast(
                    msg:
                        "Profile pic is updated and changes will be visible soon.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    fontSize: 15);
              } catch (e) {
                setState(() {
                  isLoading = false;
                  isEditable = false;
                  bioController.text = widget.currentUser.bio;
                });
                Fluttertoast.showToast(
                    msg: "Error occured",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    fontSize: 15);
              }
            }

            //print(response);
            if (response.statusCode == 200) {
              final jsonUser = jsonDecode(response.body);
              var body = jsonUser['body'];
              var body1 = jsonDecode(body);
              //print("body is $body");
              print(body1);
              var msg = body1['message'];
              print("This is my response on bio update");
              print(msg);
              curUser = User.fromJson(msg);
              //print("id is: ${msg['id']}");
              if (curUser != null) {
                //  print("This is curUser photoUrl");
                //  print(curUser.photoUrl);
                bioController.text = newBio;
                curUser.bio = newBio;
                encodedFile = null;
                file = null;
                //print(curUser);
                // setState(() {
                //   isLoading = false;
                imageCache.clear();
                setState(() {});
              }
            } else {
              newBio = bioController.text;
              encodedFile = null;
              file = null;
            }
            setState(() {
              // curUser = user;
              // print(curUser.gender);
              // newBio = curUser.bio;
              // print(curUser.bio);
              // bioController.text = newBio;
              isLoading = false;
              isEditable = false;
            });

            //getUserPosts();
          } else {
            setState(() {
              isEditable = false;
            });
          }
        },
        child: Text(
          "Save",
          style: TextStyle(
              color: colorPrimaryBlue,
              decoration: TextDecoration.underline,
              fontFamily: 'Lato',
              fontSize: 15),
        ),
      );
    }
  }

  List<Widget> buildHeader(BuildContext context) {
    newBio = bioController.text;
    List<Widget> list = isLoadingUser
        ? [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(),
            )
          ]
        : [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      widget.user.id ==
                              (curUser == null ? savedUser.id : curUser.id)
                          ? GestureDetector(
                              onTap: () {
                                if (isEditable) {
                                  selectImage(context);
                                }
                              },
                              child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: !isEditable
                                      ? curUser.photoUrl != '' &&
                                              curUser.photoUrl != null
                                          ? NetworkImage(curUser.photoUrl)
                                          : AssetImage('images/avatar.jpg')
                                      : file != null
                                          ? FileImage(
                                              file,
                                            )
                                          : curUser.photoUrl != '' &&
                                                  curUser.photoUrl != null
                                              ? NetworkImage(curUser.photoUrl)
                                              : AssetImage(
                                                  'images/avatar.jpg')),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage: widget.user.photoUrl == '' ||
                                      widget.user.photoUrl == null
                                  ? AssetImage('images/avatar.jpg')
                                  : NetworkImage(widget.user.photoUrl)),
                      widget.currentUser.id == widget.user.id
                          ? buildEditButton()
                          : buildButton(),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${widget.user.fname}" + " ${widget.user.lname}",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: colorHintText,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  widget.currentUser.id == widget.user.id
                      ? Text(
                          "${widget.user.email}",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontSize: 15,
                            color: colorGreyTint,
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 3,
                  ),
                  widget.user.mobile != null
                      ? Text(
                          widget.user.mobile,
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontSize: 15,
                            color: colorGreyTint,
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: 15,
                        width: 15,
                        //padding: EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          "images/yollar_Icon.svg",
                          color: colorGreyTint,
                        ),
                      ),
                      Text(
                        formatNumber(widget.user.lollarAmount),
                        style: TextStyle(
                            color: colorGreyTint,
                            fontSize: 15,
                            fontFamily: 'Lato'),
                      ),
                      widget.user.socialStanding != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                width: 1,
                                height: 15,
                                color: colorGreyTint,
                              ),
                            )
                          : SizedBox.shrink(),
                      widget.user.socialStanding != null
                          ? Container(
                              height: 15,
                              width: 15,
                              padding: EdgeInsets.only(right: 2),
                              child: SvgPicture.asset(
                                "images/social-standing.svg",
                                color: colorGreyTint,
                              ),
                            )
                          : SizedBox.shrink(),
                      widget.user.socialStanding != null
                          ? Text(
                              "${widget.user.socialStanding}",
                              style: TextStyle(
                                  color: colorGreyTint,
                                  fontSize: 15,
                                  fontFamily: 'Lato'),
                            )
                          : SizedBox.shrink(),
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
                        child: SvgPicture.asset("images/high-five.svg",
                            color: colorGreyTint),
                      ),
                      Text(
                        widget.user.connection.length !=
                                    widget.user.connectionCount &&
                                widget.user.connectionCount != null
                            ? "${widget.user.connectionCount}"
                            : "${widget.user.connection.length}",
                        style: TextStyle(
                            color: colorGreyTint,
                            fontSize: 15,
                            fontFamily: 'Lato'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  widget.user.id ==
                              (curUser == null ? savedUser.id : curUser.id) &&
                          isEditable
                      ? TextField(
                          onChanged: (value) {
                            newBio = value;
                            print(newBio);
                          },

                          minLines: 1,
                          maxLines: 8,
                          textDirection: TextDirection.ltr,
                          controller: bioController,
                          enabled: isEditable,
                          //widget.user.bio != null ? widget.user.bio : "here comes the bio",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontSize: 16,
                            color: colorHintText,
                          ),
                          maxLength: 250,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your bio'),
                        )
                      : widget.user.id ==
                              (curUser == null ? savedUser.id : curUser.id)
                          ? Text(
                              bioController.text,
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 13,
                                color: colorProfileBio,
                              ),
                            )
                          : Text(
                              widget.user.bio == null || widget.user.bio.isEmpty
                                  ? "Here comes the bio"
                                  : widget.user.bio,
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 13,
                                color: colorProfileBio,
                              ),
                            ),
                  SizedBox(
                    height: widget.user.bio != null ? 3 : 0,
                  ),
                ],
              ),
            ),
          ];
    return list;
  }

  reactionCallback() {
    if (widget.reactionCallback != null) widget.reactionCallback();
  }

  Future<File> compressImage(File f) async {
    final tempDir = await getTemporaryDirectory();
    path = tempDir.path;
    im.Image imageFile = im.decodeImage(f.readAsBytesSync());
    String randomId = Uuid().v4();
    final compressedImageFile = File('$path/img_$randomId.jpg')
      ..writeAsBytesSync(im.encodeJpg(imageFile,
          quality: ((5000000 / f.lengthSync()) * 100).floor()));

    // print('$path/img_${Uuid().v4()}.jpg');

    return compressedImageFile;
  }

  Future<File> _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      aspectRatio: CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ),
      sourcePath: filePath,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (croppedImage != null) {
      //setState(() {});
      return croppedImage;
    }
    return null;
  }

  Future<bool> back() async {
    if (isEditable) {
      setState(() {
        isEditable = false;
        file = null;
        encodedFile = null;
        bioController.text = curUser.bio;
      });
    } else if (widget.user.id ==
            (curUser == null ? savedUser.id : curUser.id) &&
        isPhotoEditedComplete) {
      Navigator.pop(context, "hello world");
    } else {
      Navigator.pop(context, "hello world");
    }
  }

  void deletePost(int index, String type, String id) async {
    var url = storyEndPoint + 'delete';
    var user = auth.FirebaseAuth.instance.currentUser;
    var token = await user.getIdToken();

    var response;
    Navigator.pop(context);

    response = await http.post(
      Uri.parse(url),
      encoding: Encoding.getByName("utf-8"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(
          {"id": (curUser == null ? savedUser.id : curUser.id), "StoryId": id}),
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      if (type == "invest") {
        setState(() {
          postsI.removeAt(index);
        });
        getInvestPosts();
      } else if (type == 'wage') {
        setState(() {
          postsW.removeAt(index);
        });
        getWagePosts();
      }
    } else
      Fluttertoast.showToast(
          msg: "Error deleting post please try again later",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);
  }

  // slideIt(BuildContext context, int index, animation) {
  //   var item = postsGlobal.removeAt(index);
  //   print("in slide it ${item.user.fname}");
  //
  //   return SlideTransition(
  //       position: Tween<Offset>(
  //         begin: const Offset(-1, 0),
  //         end: Offset(0, 0),
  //       ).animate(animation),
  //       child: Post_Tile(
  //         curUser: curUser,
  //         photoUrl: "",
  //         onPressDelete: () => deletePost(index,),
  //         userPost: item,
  //       ));
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: back,
        child: Scaffold(
            // Here app bar to be updated
            appBar: customAppBar(
                context,
                widget.user.id == (curUser == null ? savedUser.id : curUser.id)
                    ? false
                    : true),
            body: ModalProgressHUD(
              inAsyncCall: isLoading,
              child: NestedScrollView(
                controller: _scrollControllerMain,
                headerSliverBuilder: (context, _) {
                  return [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        buildHeader(context),
                      ),
                    )
                  ];
                },
                body: isEditable
                    ? Column()
                    : Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 6),
                            color: Colors.white,
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                SelectButton(
                                    onTap: () {
                                      setState(() {
                                        this.postOrientation = "wage";
                                      });
                                    },
                                    text: "Wassup",
                                    orientation: 'wage',
                                    curOrientation: postOrientation),
                                SelectButton(
                                    onTap: () {
                                      setState(() {
                                        this.postOrientation = "invest";
                                      });
                                    },
                                    text: "Invest",
                                    orientation: 'invest',
                                    curOrientation: postOrientation),
                                SelectButton(
                                    onTap: () {
                                      setState(() {
                                        this.postOrientation = "platform";
                                      });
                                    },
                                    text: "Interaction",
                                    orientation: 'platform',
                                    curOrientation: postOrientation),
                              ],
                            ),
                          ),
                          Expanded(
                              child: isLoadingUser
                                  ? Container()
                                  : postOrientation == 'wage'
                                      ? isWageloading
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : isWagepostFail
                                              ? ErrWidget(
                                                  tryAgainOnPressed: () {
                                                    setState(() {
                                                      isWagepostFail = false;
                                                      isWageloading = true;
                                                    });
                                                    getWagePosts();
                                                  },
                                                  showLogout: false,
                                                )
                                              : buildWagePosts()
                                      : postOrientation == 'invest'
                                          ? isInvestPostFail
                                              ? ErrWidget(
                                                  tryAgainOnPressed: () {
                                                    setState(() {
                                                      isInvestLoading = true;
                                                      isInvestPostFail = false;
                                                    });
                                                    getInvestPosts();
                                                  },
                                                  showLogout: false,
                                                )
                                              : buildInvestPosts()
                                          : isPlatformLoading
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : isPlatformPostFail
                                                  ? ErrWidget(
                                                      tryAgainOnPressed: () {
                                                        setState(() {
                                                          isPlatformPostFail =
                                                              false;
                                                          isPlatformLoading =
                                                              true;
                                                        });
                                                        getPlatformPosts();
                                                      },
                                                      showLogout: false,
                                                    )
                                                  : buildPlatformInteraction()),
                        ],
                      ),
              ),
            )));
  }
}
