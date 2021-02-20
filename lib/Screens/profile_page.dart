import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rsocial2/Screens/all_connections.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/login_page.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:http/http.dart' as http;
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/Widgets/error.dart';
import 'package:rsocial2/Widgets/invest_post_tile.dart';
import 'package:rsocial2/Widgets/platform_post_tile.dart';
import 'package:rsocial2/Widgets/post_tile.dart';
import 'package:rsocial2/Widgets/request_button.dart';
import 'package:rsocial2/Widgets/selectButton.dart';
import 'package:rsocial2/auth.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Function callBack;
  String text;
  Profile({this.currentUser, this.photoUrl, this.user, this.reactionCallback});
}

class _ProfileState extends State<Profile> {
  String postOrientation = "wage";
  bool isLoading = false;
  List<Post> postsW = [];
  List<Post> postsI = [];
  List<InvestPostTile> InvestTiles = [];
  List<Post_Tile> WageTiles = [];
  List<Post> platformPost = [];
  List<PlatformPostTile> platformTiles = [];
  TextEditingController bioController = TextEditingController();
  bool isEditable = false;
  File file;
  String encodedFile = null;
  bool isPlatformLoading = true;
  bool isUserPostFail = false;
  bool isPlatformPostFail = false;
  bool isPhotoEditedComplete = false;
  final key = GlobalKey<AnimatedListState>();
  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

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

  getUser() async {
    print("get user started");
    var user = await FirebaseAuth.instance.currentUser();
    var token;

    var id = curUser.id;
    final url = userEndPoint + "get";

    var response;
    try {
      token = await user.getIdToken();

      response = await http.post(url,
          encoding: Encoding.getByName("utf-8"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            //"Accept": "*/*"
          },
          body: jsonEncode({"id": id, "email": user.email}));
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

      curUser = User.fromJson(msg);
      await saveData();
    } else {
      print(response.statusCode);
    }
  }

  String newBio;

  @override
  void initState() {
    super.initState();

    getUserPosts();
    getPlatformPosts();
    print("init fired");
    isEditable = false;
    isLoading = false;
    bioController.text =
        widget.user.bio != null ? widget.user.bio : "here comes the bio";
  }

  handleTakePhoto() async {
    // File file = await ImagePicker.pickImage(
    //   source: ImageSource.camera,
    //   maxHeight: 675,
    //   maxWidth: 960,
    // );
    Navigator.pop(context);
    var status = await Permission.camera.status;

    if (status.isGranted || status.isUndetermined) {
      PickedFile pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        // maxHeight: 675,
        // maxWidth: 960,
      );
      if (pickedFile != null) {
        file = File(pickedFile.path);
        if (file != null) {
          print("File size");
          print(file.lengthSync());

          if (file.lengthSync() > 5000000) {
            print("not allowed");
            var alertBox = AlertDialogBox(
              title: 'Error',
              content: 'Images must be less than 5MB',
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

    if (status.isGranted || status.isUndetermined) {
      try {
        PickedFile pickedFile = await ImagePicker().getImage(
          source: ImageSource.gallery,
          // maxHeight: 675,
          // maxWidth: 960,
        );
        if (pickedFile != null) {
          file = File(pickedFile.path);
          if (file != null) {
            print("File size");
            print(file.lengthSync());
            if (file.lengthSync() > 5000000) {
              print("not allowed");
              var alertBox = AlertDialogBox(
                title: 'Error',
                content: 'Images must be less than 5MB',
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

  getUserPosts() async {
    setState(() {
      widget.isLoading = true;
    });
    print("get user post fired");
    var user = await FirebaseAuth.instance.currentUser();
    final url = storyEndPoint + "${widget.user.id}";
    var token = await user.getIdToken();
    //print(token);
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
        isUserPostFail = true;
      });
      return;
    }

    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      //print("body is $body");
      //print(body1);
      var msg = body1['message'];
      //print(msg.length);
      //print("msg id ${msg}");
      for (int i = 0; i < msg.length; i++) {
        //print("msg $i is ${msg[i]}");
        Post post;
        if (msg[i]['StoryType'] == "Investment")
          post = Post.fromJsonI(msg[i]);
        else
          post = Post.fromJsonW(msg[i]);
        if (post != null) {
          if (msg[i]['StoryType'] == "Investment")
            postsI.add(post);
          else
            postsW.add(post);
        }
      }
      print("get user post finished");
      // print(postsW.length);
      // print(postsI.length);
      // buildInvestPosts();
      // buildWagePosts();
      setState(() {
        widget.isLoading = false;
      });
      setState(() { });
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  getPlatformPosts() async {
    setState(() {
      isPlatformLoading = true;
    });

    var user = await FirebaseAuth.instance.currentUser();
    final url = storyEndPoint + 'platformactivity';
    var token = await user.getIdToken();
    //print(token);
    var response;
    try {
      response = await http.post(url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "id": widget.user.id,
          }));
    } catch (e) {
      setState(() {
        isPlatformLoading = false;
        isPlatformPostFail = true;
      });
    }
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['statusCode'] == 200) {
      var body = jsonResponse['body'];
      var body1 = jsonDecode(body);

      //print("body is $body");
      //print(body1);
      var msg = body1['message'];
      print("Platform Posts");
      print(msg);
      for (int i = 0; i < msg.length; i++) {
        Post post;
        if (msg[i]['StoryType'] == "Investment")
          post = Post.fromJsonI(msg[i]);
        else
          post = Post.fromJsonW(msg[i]);
        if (post != null) {
          platformPost.add(post);
        }
      }
      setState(() {
        isPlatformLoading = false;
      });
    }
  }

  buildWagePosts() {
    print("build wage post started");
    WageTiles = [];

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
      setState(() {
        widget.isLoading = true;
      });
      //print(posts.length);
      for (int i = 0; i < postsW.length; i++) {
        Post_Tile tile = Post_Tile(
          onPressDelete:()=>deletePost(i,"wage"),
            curUser: widget.currentUser,
            userPost: postsW[i],
            photoUrl: curUser.id == widget.user.id
                ? curUser.photoUrl
                : widget.user.photoUrl);
        WageTiles.add(tile);
      }
      setState(() {
        widget.isLoading = false;
      });
      print("build wage post ended");
      return ListView(
        children: WageTiles,
      );
    }
  }

  buildInvestPosts() {
    print("build invest post started");
    InvestTiles = [];

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
      setState(() {
        widget.isLoading = true;
      });
      //print(posts.length);
      for (int i = 0; i < postsI.length; i++) {
        print("Invest reaction");
        print(postsI[i].reactedBy.length);
        InvestPostTile tile = InvestPostTile(
          onPressDelete: ()=>deletePost(i,"invest"),
            curUser: widget.currentUser,
            userPost: postsI[i],
            photoUrl: curUser.id == widget.user.id
                ? curUser.photoUrl
                : widget.user.photoUrl);
        InvestTiles.add(tile);
      }
      setState(() {
        widget.isLoading = false;
      });
      print("build invest post ended");
      return ListView(
        children: InvestTiles,
      );
    }
  }

  buildplatformInteraction() {
    platformTiles = [];
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
      for (int i = 0; i < platformPost.length; i++) {
        PlatformPostTile tile = PlatformPostTile(
            curUser: widget.currentUser,
            userPost: platformPost[i],
            photoUrl: curUser.id == widget.user.id
                ? curUser.photoUrl
                : widget.user.photoUrl);
        platformTiles.add(tile);
      }

      return ListView(
        children: platformTiles,
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

  buildPlatformPosts() {
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
        ],
      ),
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
            var user = await FirebaseAuth.instance.currentUser();
            var token = await user.getIdToken();
            String url = userEndPoint + 'update';
            print(encodedFile);
            if (encodedFile == null) {
              try {
                response = await http.put(
                  url,
                  encoding: Encoding.getByName("utf-8"),
                  body: jsonEncode({'id': curUser.id, 'bio': newBio}),
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
                  url,
                  encoding: Encoding.getByName("utf-8"),
                  body: jsonEncode({
                    'id': curUser.id,
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
                  url,
                  encoding: Encoding.getByName("utf-8"),
                  body: jsonEncode({
                    'id': curUser.id,
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
              // print(msg);
              curUser = User.fromJson(msg);
              //print("id is: ${msg['id']}");

              //getUserPosts();
              // curUser.bio = user.bio;
              // print(user.photoUrl);
              // setState(() {
              //   if (user.photoUrl != null) curUser.photoUrl = user.photoUrl;
              // });
              if (curUser != null) {
                //  print("This is curUser photoUrl");
                //  print(curUser.photoUrl);
                bioController.text = newBio;
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
    // if (isLoading) bioController.text = newBio;
    // print("hello hello");
    // print(curUser.photoUrl);
    // print(curUser.id == widget.user.id);
    // print(widget.user.photoUrl);
    newBio = bioController.text;
    List<Widget> list = [
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.user.id == curUser.id
                    ? GestureDetector(
                        onTap: () {
                          if (isEditable) {
                            selectImage(context);
                          }
                        },
                        child: CircleAvatar(
                            radius: 50,
                            backgroundImage: !isEditable
                                ? curUser.photoUrl != ''
                                    ? NetworkImage(curUser.photoUrl)
                                    : AssetImage('images/avatar.jpg')
                                : file != null
                                    ? FileImage(
                                        file,
                                      )
                                    : curUser.photoUrl != ''
                                        ? NetworkImage(curUser.photoUrl)
                                        : AssetImage('images/avatar.jpg')),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundImage: widget.user.photoUrl == ''
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
                      color: colorGreyTint, fontSize: 15, fontFamily: 'Lato'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 1,
                    height: 15,
                    color: colorGreyTint,
                  ),
                ),
                Container(
                  height: 15,
                  width: 15,
                  padding: EdgeInsets.only(right: 2),
                  child: SvgPicture.asset(
                    "images/social-standing.svg",
                    color: colorGreyTint,
                  ),
                ),
                Text(
                  "${widget.user.socialStanding}",
                  style: TextStyle(
                      color: colorGreyTint, fontSize: 15, fontFamily: 'Lato'),
                ),
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
                      color: colorGreyTint, fontSize: 15, fontFamily: 'Lato'),
                ),
              ],
            ),
            SizedBox(
              height: 12,
            ),
            widget.user.id == curUser.id && isEditable
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
                        border: InputBorder.none, hintText: 'Enter your bio'),
                  )
                : Text(
                    bioController.text,
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

  // onBackPressed() {
  //   widget.investingWithPageCallback();
  // }
  Future<bool> back() async {
    if (isEditable) {
      setState(() {
        isEditable = false;
        file = null;
        encodedFile = null;
        bioController.text = curUser.bio;
      });
    } else if (widget.user.id == curUser.id && isPhotoEditedComplete) {
      //getUser();

      Navigator.pop(context, "hello world");
    } else {
      Navigator.pop(context, "hello world");
    }
  }

  void deletePost(int index,String type) async {
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
      if(type=="invest")
        {
          setState(() {
            postsI.removeAt(index);
          });
        }
      else if(type=='wage')
        {
          setState(() {
            postsW.removeAt(index);
          });
        }
      getUserPosts();
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
    print(isEditable);
    return WillPopScope(
        onWillPop: back,
        child: Scaffold(
            // Here app bar to be updated
            appBar: customAppBar(
                context, widget.user.id == curUser.id ? false : true),
            body: ModalProgressHUD(
              inAsyncCall: isLoading,
              child: NestedScrollView(
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
                                    text: "Wage",
                                    orientation: 'wage',
                                    curOrientation: postOrientation),
                                SelectButton(
                                    onTap: () {
                                      setState(() {
                                        this.postOrientation = "invest";
                                      });
                                    },
                                    text: "Investment",
                                    orientation: 'invest',
                                    curOrientation: postOrientation),
                                SelectButton(
                                    onTap: () {
                                      setState(() {
                                        this.postOrientation = "platform";
                                      });
                                    },
                                    text: "Platform",
                                    orientation: 'platform',
                                    curOrientation: postOrientation),
                                // Container(
                                //   child: GestureDetector(
                                //     onTap: () {
                                //       setPostOrientation("wage");
                                //     },
                                //     child: Column(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.spaceBetween,
                                //       children: <Widget>[
                                //         Text(
                                //           kProfilePageWageTab,
                                //           style: TextStyle(
                                //             fontFamily: "Lato",
                                //             fontSize: 15,
                                //             color: postOrientation == 'wage'
                                //                 ? Theme.of(context).primaryColor
                                //                 : Colors.grey,
                                //           ),
                                //         ),
                                //         SizedBox(
                                //           height: 5,
                                //         ),
                                //         Container(
                                //           width: 50,
                                //           height: 2,
                                //           color: postOrientation == 'wage'
                                //               ? Theme.of(context).primaryColor
                                //               : Colors.white,
                                //         )
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                // Container(
                                //   child: GestureDetector(
                                //     onTap: () {
                                //       setPostOrientation("invest");
                                //     },
                                //     child: Column(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.spaceBetween,
                                //       children: <Widget>[
                                //         Text(
                                //           kProfilePageInvestmentTab,
                                //           style: TextStyle(
                                //             fontFamily: "Lato",
                                //             fontSize: 15,
                                //             color: postOrientation == 'invest'
                                //                 ? Theme.of(context).primaryColor
                                //                 : Colors.grey,
                                //           ),
                                //         ),
                                //         SizedBox(
                                //           height: 5,
                                //         ),
                                //         Container(
                                //           width: 50,
                                //           height: 2,
                                //           color: postOrientation == 'invest'
                                //               ? Theme.of(context).primaryColor
                                //               : Colors.white,
                                //         )
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                // Container(
                                //   child: GestureDetector(
                                //     onTap: () {
                                //       setPostOrientation("platform");
                                //     },
                                //     child: Column(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.spaceBetween,
                                //       children: <Widget>[
                                //         Text(
                                //           kProfilePagePlatformTab,
                                //           style: TextStyle(
                                //             fontFamily: "Lato",
                                //             fontSize: 15,
                                //             color: postOrientation == 'platform'
                                //                 ? Theme.of(context).primaryColor
                                //                 : Colors.grey,
                                //           ),
                                //         ),
                                //         SizedBox(
                                //           height: 5,
                                //         ),
                                //         Container(
                                //           width: 50,
                                //           height: 2,
                                //           color: postOrientation == 'platform'
                                //               ? Theme.of(context).primaryColor
                                //               : Colors.white,
                                //         )
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Expanded(
                              child: widget.isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : isUserPostFail
                                      ? ErrWidget(
                                          tryAgainOnPressed: () {
                                            setState(() {
                                              isUserPostFail = false;
                                              widget.isLoading = true;
                                            });
                                            getUserPosts();
                                          },
                                          showLogout: false,
                                        )
                                      : (postOrientation == 'wage'
                                          ? buildWagePosts()
                                          : (postOrientation == 'invest'
                                              ? buildInvestPosts()
                                              : (isPlatformLoading
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : isPlatformPostFail
                                                      ? ErrWidget(
                                                          tryAgainOnPressed:
                                                              () {
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
                                                      : buildplatformInteraction())))),
                        ],
                      ),
              ),
            )));
  }
}
