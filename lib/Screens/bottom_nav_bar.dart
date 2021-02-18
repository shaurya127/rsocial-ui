import 'dart:convert';
import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:rsocial2/Screens/notification_page.dart';
import 'package:rsocial2/Screens/rcash_screen.dart';
import 'package:rsocial2/Widgets/error.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../contants/config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Screens/bio_page.dart';
import 'package:rsocial2/Screens/profile_pic.dart';
import 'package:rsocial2/Screens/wage.dart';
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/auth.dart';
import 'package:rsocial2/authLogic.dart';
import '../deep_links.dart';
import '../model/user.dart';
import 'package:rsocial2/Screens/landing_page.dart';
import 'package:rsocial2/Screens/nav_drawer.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'dart:developer';
import 'package:rsocial2/Widgets/CustomAppBar.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../model/connection.dart';

import '../main.dart';
import '../model/post.dart';

import 'create_account_page.dart';
import 'display_post.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final googleSignIn = GoogleSignIn();
final fblogin = FacebookLogin();
User curUser;
User savedUser;
PackageInfo packageInfo;
List<Post> postsGlobal = [];
//SharedPreferences prefs;

class BottomNavBar extends StatefulWidget {
  User currentUser;
  bool isNewUser;
  String sign_in_mode;

  BottomNavBar(
      {@required this.currentUser,
      @required this.isNewUser,
      @required this.sign_in_mode});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  // This is our animation controller

  FirebaseMessaging _messaging = FirebaseMessaging();

  final authInstance = FirebaseAuth.instance;
  final _authInstance = FirebaseAuth.instance;
  bool isLoading = false;
  String photourl;
  bool isFailedUserPost = false;
  bool isFailedGetAllUser = false;
  bool isFailedGetUser = false;
  List<User> allUsers = [];
  bool isPosted = false;
  int _currentIndex = 0;
  bool isLoadingPost = false;
  bool isForward = true;
  bool isNewUserFailed = false;
  User Ruser;

  void isPostedCallback() {
    setState(() {
      _currentIndex = 0;
    });

    getUserPosts();
  }

  createNgetUser() async {
    var url = userEndPoint + 'create';
    var user = await FirebaseAuth.instance.currentUser();
    photourl = user.photoUrl;
    var token = await user.getIdToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String inviteId = prefs.getString('inviteSenderId');
    if (inviteId != null || inviteSenderId != null)
      widget.currentUser.inviteSenderId =
          inviteId == null ? inviteSenderId : inviteId;

    if (widget.currentUser != null) {
      var response;
      try {
        response = await http.post(
          url,
          encoding: Encoding.getByName("utf-8"),
          body: jsonEncode(widget.currentUser.toJson()),
          headers: {
            "Authorization": "Bearer: $token",
            "Content-Type": "application/json",
            "Accept": "*/*"
          },
        );
      } catch (e) {
        setState(() {
          isNewUserFailed = true;
        });
      }
      //print('Response status: ${response.statusCode}');
      log('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        // print('Response body: ${response.body}');
        // log('Response body: ${response.body}');
        var res = json.decode(response.body);

        prefs.remove('inviteSenderId');
        // prefs.setString('FName', widget.currentUser.fname);
        // prefs.setString('LName', widget.currentUser.lname);
        // prefs.setInt('socialStanding', widget.currentUser.socialStanding);
        // prefs.setInt('yollarAmount', widget.currentUser.lollarAmount);
        // prefs.setString(
        //     'totalConnections', widget.currentUser.connectionCount.toString());
        // prefs.setString('profilePhoto', widget.currentUser.photoUrl);

        var resBody = json.decode(res['body']);

        var id = resBody['message']['id'];
        var messagingToken = await getFirebaseMessagingToken();
        //print(widget.sign_in_mode);

        var responseGet;
        try {
          await users.document(user.uid).setData(
              {"id": resBody['message']['id'], "token": messagingToken});

          final url = userEndPoint + "get";

          responseGet = await http.post(url,
              headers: {
                "Authorization": "Bearer $token",
                "Content-Type": "application/json",
              },
              body: jsonEncode({"id": id, "email": user.email}));
        } catch (e) {
          setState(() {
            isLoading = false;
            isFailedGetUser = true;
          });
          return;
        }
        if (responseGet.statusCode == 200) {
          final jsonUser = jsonDecode(responseGet.body);
          var body = jsonUser['body'];
          var body1 = jsonDecode(body);

          var msg = body1['message'];
          //print("id is: ${msg['id']}");
          //print(msg);
          curUser = User.fromJson(msg);
          saveData();
          getData();
          //print("haha");
          //print(curUser);
          // setState(() {
          //   isLoading = false;
          // });
          // return curUser;
          setState(() {
            isLoadingPost = true;
            isLoading = false;
          });
          try {
            //  user = await FirebaseAuth.instance.currentUser();
            photourl = user.photoUrl;
            //print(user);
            // DocumentSnapshot doc = await users.document(user.uid).get();
            // if (doc == null) print("error from get user post");
            //id = doc['id'];
          } catch (e) {
            setState(() {
              isFailedUserPost = true;
            });
          }

          try {
            final url = storyEndPoint + "${id}/all";
            var token = await user.getIdToken();
            final response = await http.get(url, headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            });
          } catch (e) {
            setState(() {
              isLoadingPost = false;

              isFailedUserPost = true;
            });
            return;
          }
          //print("body is ${response.body}");
          //print(response.statusCode);
          //print("User posts $response");
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
            if (msg == null) {
              setState(() {
                postsGlobal = posts;
                isLoading = false;
                isLoadingPost = false;
              });

              return;
            }
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
              postsGlobal = posts;
              isLoading = false;
              isLoadingPost = false;
            });
          } else {
            print(response.statusCode);
            throw Exception();
          }

          final urlAll = userEndPoint + "all";

          //var token = await user.getIdToken();
          //print(token);
          var responseAll;
          try {
            responseAll = await http.post(urlAll,
                headers: {
                  "Authorization": "Bearer $token",
                  "Content-Type": "application/json"
                },
                body: jsonEncode({"id": id, "email": user.email}));
          } catch (e) {
            setState(() {
              isLoading = false;
              isLoadingPost = false;
              isFailedGetAllUser = true;
            });
            return;
          }

          //print(response.statusCode);
          if (responseAll.statusCode == 200) {
            final jsonUser = jsonDecode(responseAll.body);
            var body = jsonUser['body'];
            var body1 = jsonDecode(body);
            var msg = body1['message'];
            //print(msg);
            //print("length is ${msg.length}")
            for (int i = 0; i < msg.length; i++) {
              // print(msg[i]['PendingConnection']);

              if (msg[i]['id'] == id) {
                continue;
              }

              User user = User.fromJson(msg[i]);

              allUsers.add(user);
            }
            setState(() {
              isLoading = false;
            });
            // print("all the users");
            // print(allUsers.length);
            return allUsers;
          } else {
            print(response.statusCode);
            throw Exception();
          }
        } else {
          print(response.statusCode);
          throw Exception();
        }

        // if (widget.sign_in_mode == "RSocial_sign_in") {
        //   FirebaseAnalytics().setUserId(uid);
        //   FirebaseAnalytics().logEvent(name: "Signed_in_with", parameters: {
        //     "mode": widget.sign_in_mode,
        //     'phone_number': phn,
        //     'uid': uid,
        //     'id': resMessage.toString(),
        //   });
        // } else {
        //   FirebaseAnalytics().setUserId(uid);
        //   FirebaseAnalytics().logEvent(name: "Signed_in_with", parameters: {
        //     "mode": widget.sign_in_mode,
        //     'email': email,
        //     'uid': uid,
        //     'id': resMessage.toString(),
        //   });
        // }
      }
    } else {
      logout(context);
    }
  }

  getUser() async {
    print("get user started");
    var user = await FirebaseAuth.instance.currentUser();
    var token = await user.getIdToken();
    // print(token);
    // print("This is my email");
    // print(user.email);
    DocumentSnapshot doc = await users.document(user.uid).get();
    //print("This is the doc");
    //print(doc.data);

    if (doc.data == null) {
      await _authInstance.signOut();
      return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => CreateAccount()),
          (Route<dynamic> route) => false);
    }

    var id = doc['id'];
    final url = userEndPoint + "get";
    //print(url);
    //var user = await FirebaseAuth.instance.currentUser();
    //print("this user id is ${user.uid}");
    var response;
    try {
      token = await user.getIdToken();
      print(token);
      // print(id);
      // print(user.email);
      // print("blalb");
      response = await http.post(url,
          encoding: Encoding.getByName("utf-8"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            //"Accept": "*/*"
          },
          body: jsonEncode({"id": id, "email": user.email}));
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        isFailedGetUser = true;
      });
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
        setState(() {
          isLoading = false;
          isFailedGetUser = true;
        });
      }

      curUser = User.fromJson(msg);
      saveData();
      //print("my send requests are ${curUser.sentPendingConnection.length}");
      // if(inviteSenderId!=null)
      //   addConnection(inviteSenderId);
      setState(() {
        isLoading = false;
      });
      return curUser;
    } else {
      print(response.statusCode);
      setState(() {
        isLoading = false;
        isFailedGetUser = true;
      });
      var alertBox = AlertDialogBox(
        title: "Error status: ${response.statusCode}",
        content: "Server Error",
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Back",
              style: TextStyle(
                color: colorButton,
                fontFamily: "Lato",
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          ),
        ],
      );

      showDialog(context: (context), builder: (context) => alertBox);
    }
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

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    savedUser = User(
      photoUrl: prefs.getString('profilePhoto'),
      lollarAmount: prefs.getInt('yollarAmount'),
      connectionCount: prefs.getInt('totalConnections'),
      fname: prefs.getString('FName'),
      lname: prefs.getString('LName'),
      socialStanding: prefs.getInt('socialStanding'),
    );
  }

  Future<void> getUserPosts() async {
    print("getUserPostFired");
    setState(() {
      isLoadingPost = true;
      //isLoading = false;
    });
    FirebaseUser user;
    var id;
    try {
      user = await FirebaseAuth.instance.currentUser();
      photourl = user.photoUrl;
      //print(user);
      DocumentSnapshot doc = await users.document(user.uid).get();
      if (doc == null) print("error from get user post");
      id = doc['id'];
    } catch (e) {
      setState(() {
        isFailedUserPost = true;
      });
    }
    //var id = curUser.id;

    final url = storyEndPoint + "$id/all";
    var token = await user.getIdToken();

    var response;
    try {
      response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });
    } catch (e) {
      setState(() {
        isFailedUserPost = true;
      });
      return;
    }
    //print("body is ${response.body}");
    //print(response.statusCode);
    //print("User posts $response");
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
        print("msg $i is ${msg[i]}");
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
        postsGlobal = posts.reversed.toList();
        //isLoading = false;
        isLoadingPost = false;
      });
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  getAllUsers() async {
    // setState(() {
    //   isLoading = true;
    // });
    //print("==========Inside get all users ===================");
    var user;
    var id;
    try {
      user = await FirebaseAuth.instance.currentUser();

      DocumentSnapshot doc = await users.document(user.uid).get();
      id = doc['id'];

      if (doc['token'] == null) {
        var messagingToken = await getFirebaseMessagingToken();
        await users.document(user.uid).updateData({"token": messagingToken});
      }

      //var id = curUser.id;
    } catch (e) {
      setState(() {
        isFailedGetAllUser = true;
      });
    }
    final url = userEndPoint + "all";

    var token = await user.getIdToken();
    //print(token);

    final response = await http.post(url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"id": id, "email": user.email}));

    //print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      var msg = body1['message'];
      //print(msg);
      //print("length is ${msg.length}")
      for (int i = 0; i < msg.length; i++) {
        // print(msg[i]['PendingConnection']);

        if (msg[i]['id'] == id) {
          continue;
        }

        User user = User.fromJson(msg[i]);

        allUsers.add(user);
      }
      setState(() {
        isLoading = false;
      });
      // print("all the users");
      // print(allUsers.length);
      return allUsers;
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  getRCashDetails() async {
    var user = await FirebaseAuth.instance.currentUser();
    var token = await user.getIdToken();
    DocumentSnapshot doc = await users.document(user.uid).get();

    var id = doc['id'];
    final url = userEndPoint + "getyollar";

    var response;
    try {
      token = await user.getIdToken();
      //print(token);
      response = await http.post(url,
          encoding: Encoding.getByName("utf-8"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            //"Accept": "*/*"
          },
          body: jsonEncode({"id": id}));
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      return null;
    }
    print(response.body);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      var body = jsonResponse['body'];
      var body1 = jsonDecode(body);
      var msg = body1['message'];
      Ruser = User.fromJson(msg);
      setState(() {
        isLoading = false;
      });
    } else {
      print(response.statusCode);
      setState(() {
        isLoading = false;
      });
      var alertBox = AlertDialogBox(
        title: "Error status: ${response.statusCode}",
        content: "Server Error",
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Back",
              style: TextStyle(
                color: colorButton,
                fontFamily: "Lato",
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          ),
        ],
      );

      showDialog(context: (context), builder: (context) => alertBox);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  @override
  void initState() {
    super.initState();
    getPackageInfo();
    getData();
    if (widget.isNewUser) {
      setState(() {
        isLoading = true;
      });
      createNgetUserAwait();
    } else {

      getUserPosts();
      getUserAwait();
      getAllUsers();
      getRCashDetails();

      if (postId == null) initDynamicLinks();
    }
  }

  Future<String> getFirebaseMessagingToken() async {
    var token = await _messaging.getToken();
    print(token);
    return token;
  }

  createNgetUserAwait() async {
    await createNgetUser();
  }

  getUserAwait() async {
    await getUser();
  }

  final List<String> _labels = ["Ticker", "Bonds", "Slip", "Gong", "Yollar"];

  @override
  Widget build(BuildContext context) {
    print("Build of bottom nav bar worked");

    // Screens to be present, will be switched with the help of bottom nav bar
    final List _screens = [
      Landing_Page(
        curUser: curUser,
        isLoading: isLoadingPost,
        isErrorLoadingPost: isFailedUserPost,
      ),
      Search_Page(allusers: allUsers),
      Wage(
        currentUser: curUser,
        isPostedCallback: isPostedCallback,
      ),
      NotificationPage(),
      RcashScreen(
        Ruser: Ruser,
      )
      //BioPage(analytics:widget.analytics,observer:widget.observer,currentUser: currentUser,),
      //ProfilePicPage(currentUser: widget.currentUser,analytics:widget.analytics,observer:widget.observer),
    ];

    return isNewUserFailed
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child: ErrWidget(
              tryAgainOnPressed: () {
                setState(() {
                  isLoading = true;
                  isNewUserFailed = false;
                  isFailedGetUser = false;
                  isFailedGetAllUser = false;
                  isFailedUserPost = false;
                });
                createNgetUserAwait();
              },
              showLogout: true,
            )),
          )
        : isFailedGetAllUser || isFailedUserPost
            ? Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                    child: ErrWidget(
                  tryAgainOnPressed: () {
                    setState(() {
                      isLoading = true;
                      isFailedGetUser = false;
                      isFailedGetAllUser = false;
                      isFailedUserPost = false;
                    });
                    getUserAwait();
                    getUserPosts();
                    getAllUsers();
                  },
                  showLogout: true,
                )),
              )
            : savedUser == null
                ? curUser == null || isLoading
                    ? Scaffold(
                        backgroundColor: Colors.white,
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : (postId == null
                        ? Scaffold(
                            appBar: customAppBar(context),
                            drawer: Nav_Drawer(),
                            body: _screens[_currentIndex],
                            bottomNavigationBar: BottomNavigationBar(
                              currentIndex: _currentIndex,
                              onTap: (index) =>
                                  setState(() => _currentIndex = index),
                              type: BottomNavigationBarType.fixed,
                              backgroundColor: Colors.white,
                              showSelectedLabels: true,
                              showUnselectedLabels: true,
                              unselectedItemColor:
                                  colorUnselectedBottomNav.withOpacity(0.5),
                              elevation: 5,
                              items: [
                                Icons.home,
                                Icons.search,
                                Icons.add_circle_outline,
                                Icons.notifications,
                                Icons.account_balance_wallet
                                // FaIcon(FontAwesomeIcons.plus),
                                // FaIcon(FontAwesomeIcons.bell),
                                // FaIcon(FontAwesomeIcons.wallet),
                              ]
                                  .asMap()
                                  .map(
                                    (key, value) => MapEntry(
                                      key,
                                      BottomNavigationBarItem(
                                        title: Text(
                                          _labels[key],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _currentIndex == key
                                                ? colorButton
                                                : colorUnselectedBottomNav
                                                    .withOpacity(0.5),
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        icon: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            value,
                                            color: _currentIndex == key
                                                ? colorButton
                                                : colorUnselectedBottomNav
                                                    .withOpacity(0.5),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .values
                                  .toList(),
                            ),
                          )
                        : DisplayPost(
                            postId: postId,
                          ))
                : (postId == null
                    ? Scaffold(
                        appBar: customAppBar(context),
                        drawer: Nav_Drawer(),
                        body: _screens[_currentIndex],
                        bottomNavigationBar: BottomNavigationBar(
                          currentIndex: _currentIndex,
                          onTap: (index) =>
                              setState(() => _currentIndex = index),
                          type: BottomNavigationBarType.fixed,
                          backgroundColor: Colors.white,
                          showSelectedLabels: true,
                          showUnselectedLabels: true,
                          unselectedItemColor:
                              colorUnselectedBottomNav.withOpacity(0.5),
                          elevation: 5,
                          items: [
                            Icons.home,
                            Icons.search,
                            Icons.add_circle_outline,
                            Icons.notifications,
                            Icons.account_balance_wallet,

                            // FaIcon(FontAwesomeIcons.plus),
                            // FaIcon(FontAwesomeIcons.bell),
                            // FaIcon(FontAwesomeIcons.wallet),
                          ]
                              .asMap()
                              .map(
                                (key, value) => MapEntry(
                                  key,
                                  BottomNavigationBarItem(
                                      title: Text(
                                        _labels[key],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _currentIndex == key
                                              ? colorButton
                                              : colorUnselectedBottomNav
                                                  .withOpacity(0.5),
                                          fontFamily: "Lato",
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      icon: key == 1
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2, bottom: 2.5),
                                              child: SvgPicture.asset(
                                                "images/high-five.svg",
                                                color: _currentIndex != key
                                                    ? colorUnselectedBottomNav
                                                        .withOpacity(0.5)
                                                    : colorPrimaryBlue,
                                                height: 19,
                                              ),
                                            )
                                          : key == 4
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2, bottom: 3.5),
                                                  child: SvgPicture.asset(
                                                    "images/yollar_outline.svg",
                                                    color: _currentIndex != key
                                                        ? colorUnselectedBottomNav
                                                            .withOpacity(0.5)
                                                        : colorPrimaryBlue,
                                                    height: 19,
                                                  ),
                                                )
                                              : key == 0
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 1,
                                                              bottom: 2.5),
                                                      child: SvgPicture.asset(
                                                        "images/Home.svg",
                                                        color: _currentIndex !=
                                                                key
                                                            ? colorUnselectedBottomNav
                                                                .withOpacity(
                                                                    0.5)
                                                            : colorPrimaryBlue,
                                                        height: 19,
                                                      ),
                                                    )
                                                  : key == 3
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 2,
                                                                  bottom: 3.5),
                                                          child:
                                                              SvgPicture.asset(
                                                            "images/Notification.svg",
                                                            color: _currentIndex !=
                                                                    key
                                                                ? colorUnselectedBottomNav
                                                                    .withOpacity(
                                                                        0.5)
                                                                : colorPrimaryBlue,
                                                            height: 19,
                                                          ),
                                                        )
                                                      : Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 0,
                                                                  horizontal:
                                                                      16),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Icon(
                                                            value,
                                                            color: _currentIndex ==
                                                                    key
                                                                ? colorButton
                                                                : colorUnselectedBottomNav
                                                                    .withOpacity(
                                                                        0.5),
                                                            size: 24,
                                                          ),
                                                        )),
                                ),
                              )
                              .values
                              .toList(),
                        ),
                      )
                    : DisplayPost(
                        postId: postId,
                      ));
  }
}
