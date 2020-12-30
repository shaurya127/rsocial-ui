import 'dart:convert';
import 'dart:io';
import 'package:flutter/rendering.dart';

import '../config.dart';
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
import 'package:rsocial2/user.dart';
import 'package:rsocial2/Screens/landing_page.dart';
import 'package:rsocial2/Screens/nav_drawer.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'dart:developer';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/constants.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../post.dart';
import 'create_account_page.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final googleSignIn = GoogleSignIn();
final fblogin = FacebookLogin();
User curUser;

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

class _BottomNavBarState extends State<BottomNavBar> {
  final authInstance = FirebaseAuth.instance;
  final _authInstance = FirebaseAuth.instance;
  bool isLoading = true;
  String photourl;
  //User curUser;
  bool isFailed = false;
  List<Post> posts = [];
  List<User> allUsers = [];
  bool isPosted = false;
  int _currentIndex = 0;
  bool isLoadingPost = false;
  void isPostedCallback() {
    setState(() {
      _currentIndex = 0;

      // isLoading = true;
    });
    getUserPosts();
  }

  createNgetUser() async {
    var url = userEndPoint + 'create';
    // log(jsonEncode(widget.currentUser.toJson()), name: "Bla bla");
    // print(jsonEncode(widget.currentUser.toJson()));
    // debugPrint(jsonEncode(widget.currentUser.toJson()));
    var user = await FirebaseAuth.instance.currentUser();
    photourl = user.photoUrl;
    var token = await user.getIdToken();
    //print("uid is ${user.uid}");
    String uid = user.uid;
    String phn = user.phoneNumber;
    String email = user.email;
    var response = await http.post(
      url,
      encoding: Encoding.getByName("utf-8"),
      body: jsonEncode(widget.currentUser.toJson()),
      headers: {
        "Authorization": "Bearer: $token",
        "Content-Type": "application/json",
        "Accept": "*/*"
      },
    );

    print('Response status: ${response.statusCode}');
    log('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      log('Response body: ${response.body}');

      var res = json.decode(response.body);

      var resBody = json.decode(res['body']);

      var id = resBody['message']['id'];

      //print(widget.sign_in_mode);
      await users.document(user.uid).setData({"id": resBody['message']['id']});

      final url = userEndPoint + "$id";

      final responseGet = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      if (responseGet.statusCode == 200) {
        final jsonUser = jsonDecode(responseGet.body);
        var body = jsonUser['body'];
        var body1 = jsonDecode(body);

        var msg = body1['message'];
        //print("id is: ${msg['id']}");
        print(msg);
        curUser = User.fromJson(msg);
        //print("haha");
        print(curUser);
        // setState(() {
        //   isLoading = false;
        // });
        return curUser;
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
  }

  Future<User> getUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    var token = await user.getIdToken();
    print(token);

    DocumentSnapshot doc = await users.document(user.uid).get();
    print("This is the doc");
    print(doc.data);

    if (doc.data == null) {
      await _authInstance.signOut();
      return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => CreateAccount()),
          (Route<dynamic> route) => false);
    }

    var id = doc['id'];
    final url = userEndPoint + "$id";
    print(url);
    //var user = await FirebaseAuth.instance.currentUser();
    //print("this user id is ${user.uid}");
    token = await user.getIdToken();
    print(token);
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    });
    //print(response.body);
    //print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      print("body is $body");
      // print(body1);
      var msg = body1['message'];
      //print("id is: ${msg['id']}");
      print(msg);
      if (msg == 'User Not Found') {
        setState(() {
          isLoading = false;
          isFailed = true;
        });
      }

      curUser = User.fromJson(msg);

      //print(curUser);
      // setState(() {
      //   isLoading = false;
      // });
      return curUser;
    } else {
      print(response.statusCode);
      setState(() {
        isLoading = false;
        isFailed = true;
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

  Future<void> getUserPosts() async {
    setState(() {
      isLoadingPost = true;
      isLoading = false;
    });
    var user = await FirebaseAuth.instance.currentUser();
    photourl = user.photoUrl;
    DocumentSnapshot doc = await users.document(user.uid).get();
    if (doc == null) print("error from get user post");
    var id = doc['id'];
    final url = storyEndPoint + "$id/all";
    var token = await user.getIdToken();
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
        this.posts = posts;
        isLoading = false;
        isLoadingPost = false;
      });
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  Future<void> getAllConnections() async {
    setState(() {
      isLoading=true;
    });
    //print("==========Inside get all connection ===================");
    var user = await FirebaseAuth.instance.currentUser();
    //
    // DocumentSnapshot doc = await users.document(user.uid).get();
    // var id = doc['id'];
    var id = curUser.id;
    final url = userEndPoint + "$id/all";

    var token = await user.getIdToken();
    //print(token);

    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    });

    //print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      var msg = body1['message'];

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
      return allUsers;
    } else {
      print(response.statusCode);
      throw Exception();
    }
  }

  @override
  void initState() {
    super.initState();
    //print(jsonEncode(widget.currentUser.toJson()));
    //print(widget.currentUser.photoUrl);
    if (widget.isNewUser) {
      setState(() {
        isLoading = true;
      });
      createNgetUser();
    } else
      // createUser();
      getUser();
    getUserPosts();
    getAllConnections();
  }

  buildFirstScreen() {
    return Scaffold(
      body: Center(
          child: RaisedButton(
              child: Text("log out"),
              onPressed: () async {
                FirebaseUser user = await _authInstance.currentUser();

                if (user != null) {
                  if (user.providerData[1].providerId == 'google.com') {
                    await googleSignIn.disconnect();
                  } else if (user.providerData[0].providerId ==
                      'facebook.com') {
                    await fblogin.logOut();
                  }
                  await _authInstance.signOut();
                } else {
                  var alertBox = AlertDialogBox(
                    title: "Error",
                    content:
                        "We are unable to contact our servers. Please try again.",
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          "Try again",
                          style: TextStyle(
                            color: colorButton,
                            fontFamily: "Lato",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            isLoading = true;
                            isFailed = false;
                          });
                          return getUser();
                        },
                      ),
                      FlatButton(
                        child: Text(
                          "Log out",
                          style: TextStyle(
                            color: colorButton,
                            fontFamily: "Lato",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          logout(context);
                        },
                      ),
                    ],
                  );

                  showDialog(
                      context: (context), builder: (context) => alertBox);
                }

                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => CreateAccount()),
                    (Route<dynamic> route) => false);
              })),
    );
  }

  final List<String> _labels = [
    "Home",
    "Search",
    "Post",
    "Notifications",
    "R cash"
  ];

  @override
  Widget build(BuildContext context) {
    // Screens to be present, will be switched with the help of bottom nav bar
    final List _screens = [
      Landing_Page(curUser: curUser, posts: posts, isLoading: isLoadingPost),
      Search_Page(allusers: allUsers),
      Wage(
        currentUser: curUser,
        isPostedCallback: isPostedCallback,
      ),
      buildFirstScreen(),
      Scaffold(),
      //BioPage(analytics:widget.analytics,observer:widget.observer,currentUser: currentUser,),
      //ProfilePicPage(currentUser: widget.currentUser,analytics:widget.analytics,observer:widget.observer),
    ];

    return isFailed
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Unable to find user"),
                  FlatButton(
                    child: Text(
                      "Try again",
                      style: TextStyle(
                        color: colorButton,
                        fontFamily: "Lato",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        isFailed = false;
                      });
                      return getUser();
                    },
                  ),
                  FlatButton(
                    child: Text(
                      "Log out",
                      style: TextStyle(
                        color: colorButton,
                        fontFamily: "Lato",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      logout(context);
                    },
                  ),
                ],
              ),
            ),
          )
        : isLoading || curUser == null
            ? Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Scaffold(
                appBar: customAppBar(
                    context,
                    "RSocial",
                    curUser != null ? curUser.lollarAmount.toString() : "",
                    curUser != null ? curUser.photoUrl : "",
                    curUser != null ? curUser.socialStanding.toString() : ""),

                drawer: Nav_Drawer(
                  currentUser: curUser,
                  photoUrl: curUser.photoUrl != null ? curUser.photoUrl : "",
                ),
                // AppBar(
                //   backgroundColor: colorGreenTint,
                //   leading: Padding(
                //     padding: const EdgeInsets.only(left: 13, top: 2),
                //     child: Stack(
                //       children: <Widget>[
                //         Container(
                //           height: 60,
                //           width: 60,
                //           decoration: BoxDecoration(
                //               image: DecorationImage(
                //                   image: AssetImage("images/circle1.png")),
                //               shape: BoxShape.circle),
                //         ),
                //         Positioned(
                //           left: 23,
                //           top: 30,
                //           child: Container(
                //             height: 21,
                //             width: 21,
                //             decoration: BoxDecoration(
                //                 border: Border.all(color: Colors.grey),
                //                 shape: BoxShape.circle,
                //                 color: Colors.white),
                //             child: Center(
                //               child: FaIcon(
                //                 FontAwesomeIcons.bars,
                //                 color: colorGreenTint,
                //                 size: 15,
                //               ),
                //             ),
                //           ),
                //         )
                //       ],
                //     ),
                //   ),
                // ),
                body:
                    // isLoading || curUser == null
                    //     ? Center(
                    //         child: CircularProgressIndicator(),
                    //       )
                    //     :
                    _screens[_currentIndex],
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
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
                                    : colorUnselectedBottomNav.withOpacity(0.5),
                                fontFamily: "Lato",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            icon: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                value,
                                color: _currentIndex == key
                                    ? colorButton
                                    : colorUnselectedBottomNav.withOpacity(0.5),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      )
                      .values
                      .toList(),
                ),
              );
  }
}
