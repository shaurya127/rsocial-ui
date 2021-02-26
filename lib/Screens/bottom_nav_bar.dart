import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:rsocial2/Screens/notification_page.dart';
import 'package:rsocial2/Screens/rcash_screen.dart';
import 'package:rsocial2/Widgets/disabled_reaction_button.dart';
import 'package:rsocial2/Widgets/error.dart';
import 'package:rsocial2/Widgets/post_tile.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/helper.dart';
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
import 'package:rsocial2/Screens/createPost.dart';
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
var authFirebase = FirebaseAuth.instance;
User curUser;
User savedUser;
PackageInfo packageInfo;
List postsGlobal = [];
bool storiesStillLeft;

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
  bool isLoading = false;
  String photourl;
  bool isFailedUserPost = false;
  bool isFailedGetAllUser = false;
  bool isFailedGetUser = false;

  List _screens;

  bool isPosted = false;
  int _currentIndex = 0;
  bool isLoadingPost = false;
  bool isForward = true;
  bool isNewUserFailed = false;
  User Ruser;
  bool storiesLeft = true;

  callback() {
    print("callback called");
    setState(() {});
  }

  reactionCallback() async {
    await getRCashDetails();
    setState(() {});
  }

  void isPostedCallback() {
    setState(() {
      _currentIndex = 0;
    });

    getAllPosts();
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
        // var messagingToken = await getFirebaseMessagingToken();
        //print(widget.sign_in_mode);

        var responseGet;
        try {
          // await users.document(user.uid).setData(
          //     {"id": resBody['message']['id'], "token": messagingToken});

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
            final url = storyEndPoint + "$id/all";
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

          //   final urlAll = userEndPoint + "all";
          //
          //   //var token = await user.getIdToken();
          //   //print(token);
          //   var responseAll;
          //   try {
          //     responseAll = await http.post(urlAll,
          //         headers: {
          //           "Authorization": "Bearer $token",
          //           "Content-Type": "application/json"
          //         },
          //         body: jsonEncode({"id": id, "email": user.email}));
          //   } catch (e) {
          //     setState(() {
          //       isLoading = false;
          //       isLoadingPost = false;
          //       isFailedGetAllUser = true;
          //     });
          //     return;
          //   }
          //
          //   //print(response.statusCode);
          //   if (responseAll.statusCode == 200) {
          //     final jsonUser = jsonDecode(responseAll.body);
          //     var body = jsonUser['body'];
          //     var body1 = jsonDecode(body);
          //     var msg = body1['message'];
          //     //print(msg);
          //     //print("length is ${msg.length}")
          //     for (int i = 0; i < msg.length; i++) {
          //       // print(msg[i]['PendingConnection']);
          //
          //       if (msg[i]['id'] == id) {
          //         continue;
          //       }
          //
          //       User user = User.fromJson(msg[i]);
          //
          //       //allUsers.add(user);
          //     }
          //     setState(() {
          //       isLoading = false;
          //     });
          //     // print("all the users");
          //     // print(allUsers.length);
          //     //return allUsers;
          //   } else {
          //     print(response.statusCode);
          //     throw Exception();
          //   }
          // } else {
          //   print(response.statusCode);
          //   throw Exception();
          // }

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
  }

  getUser() async {
    print("get user started");
    var user = await authFirebase.currentUser();
    var token = await user.getIdToken();

    DocumentSnapshot doc = await users.document(user.uid).get();

    if (doc.data == null) {
      await authFirebase.signOut();
      return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => CreateAccount()),
          (Route<dynamic> route) => false);
    }

    var id = doc['id'];

    var response = await postFunc(
        url: userEndPoint + "get",
        token: token,
        body: jsonEncode({"id": id, "email": user.email}));

    if (response == null) {
      setState(() {
        isLoading = false;
        isFailedGetUser = true;
      });
      return null;
    }

    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];

      if (responseMessage == 'User Not Found') {
        setState(() {
          isLoading = false;
          isFailedGetUser = true;
        });
        return null;
      }
      print("CurUser returned");
      curUser = User.fromJson(responseMessage);
      saveData();
      //print("my send requests are ${curUser.sentPendingConnection.length}");
      // if(inviteSenderId!=null)
      //   addConnection(inviteSenderId);
      // setState(() {
      //   isLoading = false;
      // });

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
    prefs.setString('id', curUser.id);
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
      id: prefs.getString('id'),
      photoUrl: prefs.getString('profilePhoto'),
      lollarAmount: prefs.getInt('yollarAmount'),
      connectionCount: prefs.getInt('totalConnections'),
      fname: prefs.getString('FName'),
      lname: prefs.getString('LName'),
      socialStanding: prefs.getInt('socialStanding'),
    );

    setState(() {});
  }

  getAllPosts() async {
    int start = 0, i = 0;
    // while (storiesLeft) {

    print("getUserPostFired");
    setState(() {
      isLoadingPost = true;
      //isLoading = false;
    });
    FirebaseUser user;
    var id;
    try {
      user = await authFirebase.currentUser();
      DocumentSnapshot doc = await users.document(user.uid).get();
      if (doc == null) print("error from get user post");
      id = doc['id'];
    } catch (e) {
      setState(() {
        isFailedUserPost = true;
      });
    }

    var token = await user.getIdToken();

    var response = await postFunc(
        url: storyEndPoint + "all",
        token: token,
        body: jsonEncode({"id": id, "start_token": start}));

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

      storiesStillLeft = responseMessage['still_left'];

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
        postsGlobal.addAll(posts);
        //isLoading = false;
        isLoadingPost = false;
        print(
            "number of stories left $storiesLeft , message id $storiesStillLeft");
        storiesLeft = storiesStillLeft;
        print("number of stories after call $storiesLeft");
        print(
            "number of stories left $storiesLeft , message id $storiesStillLeft");
      });
    } else {
      print(response.statusCode);
      throw Exception();
    }
    //  start = start + 10;
    //}
  }

  getRCashDetails() async {
    var user = await authFirebase.currentUser();
    var token = await user.getIdToken();
    var id = curUser.id;

    var response = await postFunc(
        url: userEndPoint + "getyollar",
        token: token,
        body: jsonEncode({"id": id}));

    if (response == null) {
      return null;
    }

    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];
      Ruser = User.fromJson(responseMessage);

      curUser.lollarAmount = Ruser.lollarAmount;
      curUser.totalAvailableYollar = Ruser.totalAvailableYollar;
      curUser.totalWageEarningAmount = Ruser.totalWageEarningAmount;
      curUser.totalInvestmentEarningActiveAmount =
          Ruser.totalInvestmentEarningActiveAmount;
      curUser.joiningBonus = Ruser.joiningBonus;
      curUser.totalPlatformEngagementAmount =
          Ruser.totalPlatformEngagementAmount;
      curUser.referralAmount = Ruser.referralAmount;
      curUser.totalPlatformInteractionAmount =
          Ruser.totalPlatformInteractionAmount;
      curUser.totalActiveInvestmentAmount = Ruser.totalActiveInvestmentAmount;
      curUser.totalInvestmentEarningMaturedAmount =
          Ruser.totalInvestmentEarningMaturedAmount;
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
    // const oneSec = const Duration(seconds: 3);
    // int counter = 0;
    // Timer.periodic(oneSec, (Timer timer) {
    //   setState(() {
    //     curUser.lollarAmount = 1000 * counter;
    //     counter++;
    //   });
    // });

    super.initState();
    getPackageInfo();
    getData();

    if (widget.isNewUser) {
      setState(() {
        isLoading = true;
      });
      createNgetUserAwait();
    } else {
      getAllPosts();
      getUserAwait();
      //  getAllUsers();
      //getRCashDetails();

      if (postId == null) initDynamicLinks();
    }
  }

  // Future<String> getFirebaseMessagingToken() async {
  //   var token = await _messaging.getToken();
  //   print(token);
  //   return token;
  // }

  createNgetUserAwait() async {
    await createNgetUser();
  }

  getUserAwait() async {
    await getUser();
  }

  final List<String> _labels = ["Ticker", "Bonds", "Slip", "Gong", "Yollar"];

  @override
  Widget build(BuildContext context) {
    // Provider.of<Post_Tile>(context);
    print("Build of bottom nav bar worked");

    // Screens to be present, will be switched with the help of bottom nav bar
    _screens = [
      Landing_Page(
        curUser: curUser,
        hasNoPosts: postsGlobal.length == 0 ? true : false,
        isLoading: isLoadingPost,
        isErrorLoadingPost: isFailedUserPost,
        reactionCallback: reactionCallback,
      ),

      Search_Page(),
      Wage(
        currentUser: curUser,
        isPostedCallback: isPostedCallback,
      ),
      NotificationPage(),
      RcashScreen(
        Ruser: Ruser,
        reactionCallback: reactionCallback,
      )
      //BioPage(analytics:widget.analytics,observer:widget.observer,currentUser: currentUser,),
      //ProfilePicPage(currentUser: widget.currentUser,analytics:widget.analytics,observer:widget.observer),
    ];
    print("This is my savedUser");
    print(savedUser);

    print("This is my current User");
    print(curUser);
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
        : isFailedUserPost
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
                    getAllPosts();
                    //getAllUsers();
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
                    : buildLoadedPage()
                : buildLoadedPage();
  }

  buildLoadedPage() {
    return postId == null
        ? Scaffold(
            appBar: customAppBar(context),
            drawer: Nav_Drawer(),
            body: _screens[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: onTabTapped,
              //(index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              unselectedItemColor: colorUnselectedBottomNav.withOpacity(0.5),
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
                                  : colorUnselectedBottomNav.withOpacity(0.5),
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
                                      padding: const EdgeInsets.only(
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
                                          padding: const EdgeInsets.only(
                                              top: 1, bottom: 2.5),
                                          child: SvgPicture.asset(
                                            "images/Home.svg",
                                            color: _currentIndex != key
                                                ? colorUnselectedBottomNav
                                                    .withOpacity(0.5)
                                                : colorPrimaryBlue,
                                            height: 19,
                                          ),
                                        )
                                      : key == 3
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2, bottom: 3.5),
                                              child: SvgPicture.asset(
                                                "images/Notification.svg",
                                                color: _currentIndex != key
                                                    ? colorUnselectedBottomNav
                                                        .withOpacity(0.5)
                                                    : colorPrimaryBlue,
                                                height: 19,
                                              ),
                                            )
                                          : Container(
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
                                            )),
                    ),
                  )
                  .values
                  .toList(),
            ),
          )
        : DisplayPost(
            postId: postId,
          );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
