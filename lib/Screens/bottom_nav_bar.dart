import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
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
import 'package:rsocial2/model/notification.dart';
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
import '../model/user.dart' as userModel;
import 'package:rsocial2/Screens/landing_page.dart';
import 'package:rsocial2/Screens/nav_drawer.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'dart:developer';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import './notification_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../model/connection.dart';
import '../providers/data.dart';
import '../main.dart';
import '../model/post.dart';

import 'create_account_page.dart';
import 'display_post.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final googleSignIn = GoogleSignIn();
final fblogin = FacebookLogin();
var authFirebase = FirebaseAuth.instance;
userModel.User curUser;
userModel.User savedUser;
PackageInfo packageInfo;
List postsGlobal = [];
bool storiesStillLeft;
bool muted = false;

//SharedPreferences prefs;

class BottomNavBar extends StatefulWidget {
  userModel.User currentUser;
  bool isNewUser;
  String sign_in_mode;

  BottomNavBar({
    @required this.currentUser,
    @required this.isNewUser,
    @required this.sign_in_mode,
  });

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool isFailedUserPost = false;
  bool isFailedGetAllUser = false;
  bool isFailedGetUser = false;

  List _screens;
  List<NotificationModel> readNotification = [];
  List<NotificationModel> unreadNotification = [];
  bool isPosted = false;
  int _currentIndex = 0;
  bool isLoadingPost = false;
  bool isForward = true;
  bool isNewUserFailed = false;
  bool showNotification = false;
  userModel.User Ruser;
  bool storiesLeft = true;
  ScrollController _scrollController = ScrollController();
  final List<int> backStack = [0];
  bool refreshLandingPage = false;
  callback() {
    ////print("callback called");
    setState(() {});
  }

  yollarCallback() async {
    setState(() {
      _currentIndex = 4;
    });
  }

  feedbackCallback() async {
    setState(() {
      _currentIndex = 0;
    });
  }

  reactionCallback() async {
    await getRCashDetails();
    setState(() {});
  }

  refreshCallback() async {
    refreshLandingPage = false;
    getRCashDetails();
  }

  void isPostedCallback() {
    //print("IsPostedCallback called");
    setState(() {
      _currentIndex = 0;
      refreshLandingPage = true;
    });

    // getAllPosts(curUser != null
    //     ? curUser.id
    //     : savedUser != null
    //         ? savedUser.id
    //         : null);
  }

  createNgetUser() async {
    setState(() {
      isLoading = true;
    });
    var url = userEndPoint + 'create';
    var user = FirebaseAuth.instance.currentUser;

    var token = await user.getIdToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String inviteId = prefs.getString('inviteSenderId');
    if (inviteId != null || inviteSenderId != null)
      widget.currentUser.inviteSenderId =
          inviteId == null ? inviteSenderId : inviteId;

    if (widget.currentUser != null) {
      var response;
      var messagingToken;
      try {
        messagingToken = await getFirebaseMessagingToken();
      } catch (e) {}

      try {
        var uri = Uri.parse(url);
        response = await http.post(
          uri,
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
          isLoading = false;
          isNewUserFailed = true;
        });
        return;
      }

      if (response.statusCode == 200) {
        var responseMessage =
            jsonDecode((jsonDecode(response.body))['body'])['message'];

        var responseUserData =
            jsonDecode((jsonDecode(response.body))['body'])['userdata'];

        prefs.remove('inviteSenderId');
        var id;
        if (responseMessage != "UserAlreadyExists") {
          id = responseMessage['id'];

          //print(widget.sign_in_mode);

          // Updating Messagingtoken in Cloud Firestore
          try {
            await users.doc(user.uid).set({"id": id, "token": messagingToken});
          } catch (e) {}

          curUser = userModel.User.fromJson(responseMessage);
        } else {
          id = responseUserData['id'];
          await getUser(id);
        }
        setState(() {
          isLoading = false;
        });

        if (curUser == null) {
          return;
        }

        getAllPosts(id);
      } else {
        logout(context);
      }
    }
  }

  getUser(String id) async {
    var user = authFirebase.currentUser;
    var token = await user.getIdToken();

    DocumentSnapshot doc = await users.doc(user.uid).get();

    if (doc.data == null) {
      if (id == null) {
        await authFirebase.signOut();
        return Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => CreateAccount()),
            (Route<dynamic> route) => false);
      } else {
        try {
          var messagingToken = await getFirebaseMessagingToken();
          await users.doc(user.uid).set({"id": id, "token": messagingToken});
        } catch (e) {}
      }
    }
    if (id == null) id = doc['id'];

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
    //print("----------------------------------");
    //print(response.body);
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

      setState(() {
        //print("USERRR:${User.fromJson(responseMessage)}");
        curUser = userModel.User.fromJson(responseMessage);
      });

      if (curUser != null) saveData();

      await getSocialStanding();

      //print(curUser.lollarAmount);
      //print(curUser.id);
      setState(() {});
    } else {
      //print(response.statusCode);
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
    //print("get user finished");
    prefs.setString('id', curUser.id);
    prefs.setString('FName', curUser.fname);
    prefs.setString('LName', curUser.lname);
    prefs.setInt('socialStanding', curUser.socialStanding ?? 0);
    prefs.setInt('yollarAmount', curUser.lollarAmount);
    prefs.setInt('totalConnections', curUser.connectionCount);
    prefs.setString('profilePhoto', curUser.photoUrl);
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    savedUser = userModel.User(
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

  getAllPosts(String id) async {
    //print("Inside get all posts");
    int start = 0;
    //print("getUserPostFired");
    setState(() {
      isLoadingPost = true;
      //isLoading = false;
    });
    User user;
    user = authFirebase.currentUser;
    var token = await user.getIdToken();

    if (id == null) {
      try {
        user = authFirebase.currentUser;
        DocumentSnapshot doc = await users.doc(user.uid).get();
        if (doc == null) print("error from get user post");
        id = doc['id'];
      } catch (e) {
        //print("inside try");
        setState(() {
          isFailedUserPost = true;
        });
      }
    }

    var response = await postFunc(
        url:
            "https://t43kpz2m5d.execute-api.ap-south-1.amazonaws.com/story/home",
        token: token,
        body: jsonEncode({"id": id, "start_token": start}));
    print("TOKEN $token");
    print("ID $id");
    print("START $start");
    if (response == null) {
      setState(() {
        isFailedUserPost = true;
      });
      return true;
    }

    if (response.statusCode == 200) {
      print(response.body);
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];
      print(responseMessage);
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
            ////print(post.investedWithUser);
            posts.add(post);
          }
        }
      }
      setState(() {
        postsGlobal.addAll(posts);
        isLoadingPost = false;
        storiesLeft = storiesStillLeft;
      });
    } else {
      //print(response.statusCode);
      throw Exception();
    }
  }

  getRCashDetails() async {
    var user = authFirebase.currentUser;
    var token = await user.getIdToken();
    var id;
    if (curUser == null) {
      id = savedUser.id;
    } else {
      id = curUser.id;
    }
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
      var Ruser = userModel.User.fromJson(responseMessage);
      if (curUser != null) {
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
  }

  checkSavedUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('id')) getData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  getSocialStanding() async {
    //print("Get social standing triggered");
    var token;
    try {
      var user = authFirebase.currentUser;
      token = await user.getIdToken();
    } catch (e) {
      return;
    }
    var id = curUser != null
        ? curUser.id
        : savedUser != null
            ? savedUser.id
            : null;
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
        curUser.lollarAmount = responseMessage['yollar'];
        curUser.socialStanding = responseMessage['rank'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        if (savedUser != null) {
          savedUser.socialStanding = curUser.socialStanding;
          savedUser.lollarAmount = curUser.lollarAmount;
        }
        prefs.setInt('socialStanding', curUser.socialStanding);
        prefs.setInt('yollarAmount', curUser.lollarAmount);
      } catch (e) {
        //print("Exception " + e + "in social standing");
      }
    }
  }

  getNotifications() async {
    setState(() {
      isLoading = true;
    });

    var response;
    try {
      var user = FirebaseAuth.instance.currentUser;
      var token = await user.getIdToken();
      var id = curUser != null
          ? curUser.id
          : savedUser != null
              ? savedUser.id
              : null;
      if (id == null) {
        try {
          user = authFirebase.currentUser;
          DocumentSnapshot doc = await users.doc(user.uid).get();
          if (doc == null) print("error from get user post");
          id = doc['id'];
        } catch (e) {
          //print("inside try");
        }
      }
      response = await postFunc(
          url: userEndPoint + "getnotification",
          token: token,
          body: jsonEncode({
            //"id": "bb6c5841ba0d4f5597506ff3b61b91d3",
            "id": id,
          }));
      print("NOTIFICATION:${response.body}");
      //print("Inside get notification");
      if (response == null) {}
    } catch (e) {
      isLoading = false;
    }
    //print(response.statusCode);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];

      //print(responseMessage['True']);
      if (responseMessage['True'] != null) {
        for (int i = 0; i < responseMessage['True'].length; i++) {
          readNotification
              .add(NotificationModel.fromJson(responseMessage['True'][i]));
          //print(readNotification[i].text);
        }
      }
      if (responseMessage['False'] != null) {
        for (int i = 0; i < responseMessage['False'].length; i++) {
          unreadNotification
              .add(NotificationModel.fromJson(responseMessage['False'][i]));
        }
      }
      //print(readNotification.length);
      if (unreadNotification.isNotEmpty) {
        showNotification = true;
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    //print("post id is this: $postId");

    super.initState();
    getPackageInfo();
    checkSavedUserData();

    if (widget.isNewUser) {
      setState(() {
        isLoading = true;
      });
      createNgetUserAwait();
    } else {
      getAllPosts(curUser != null
          ? curUser.id
          : savedUser != null
              ? savedUser.id
              : null);

      getUserAwait();
      //  getAllUsers();
      //getRCashDetails();

      if (postId == null) {
        initDynamicLinks();
        //print("found id : $postId");
      } else {
        // Future.delayed(Duration(seconds: 5));
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => DisplayPost(
        //       postId: postId,
        //     ),
        //   ),
        // );
      }
    }

    const time = const Duration(minutes: 5);

    Timer.periodic(time, (Timer timer) async {
      await getSocialStanding();
      setState(() {});
    });
    getNotifications();
  }

  Future<void> initDynamicLinks() async {
    // setState(() {
    //   findingLink=true;
    // });
    // final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    // final Uri deepLink = data?.link;

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        ////print("the postid is:${deepLink.queryParameters['postid']}");// <- //prints 'abc'
        postId = deepLink.queryParameters['postid'];
        if (postId != null) {
          // SchedulerBinding.instance.addPostFrameCallback((_) {
          //   Navigator.of(navigatorKey.currentContext).push(MaterialPageRoute(
          //     builder: (context) => DisplayPost(
          //       postId: deepLink.queryParameters['postid'],
          //     ),
          //   ));
          // });
          // Future.delayed(Duration.zero).then((value) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DisplayPost(postId: deepLink.queryParameters['postid'])));
          // });
        }
      }
    }, onError: (OnLinkErrorException e) async {
      //print('onLinkError');
      //print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    print("LINK: $deepLink");
    if (deepLink != null) {
      //postId = deepLink.queryParameters['postid'];
      if (postId != null) {
        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   Navigator.of(navigatorKey.currentContext).push(MaterialPageRoute(
        //     builder: (context) => DisplayPost(
        //       postId: deepLink.queryParameters['postid'],
        //     ),
        //   ));
        // });
        // Future.delayed(Duration.zero).then((value) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DisplayPost(postId: deepLink.queryParameters['postid'])));
        //});
      }
    }

    // setState(() {
    //   findingLink=false;
    // });
  }

  Future<String> getFirebaseMessagingToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    //print(token);
    return token;
  }

  createNgetUserAwait() async {
    await createNgetUser();
  }

  getUserAwait() async {
    await getUser(null);
  }

  void navigateTo(int index) {
    backStack.add(index);
    setState(() {
      _currentIndex = index;
      if (index == 3) {
        showNotification = false;
      }
    });
  }

  void navigateBack(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 3) {
        showNotification = false;
      }
    });
  }

  Future<bool> customPop(BuildContext context) {
    //print("CustomPop is called");
    //print("_backstack = $backStack");
    if (backStack.length > 1) {
      backStack.removeAt(backStack.length - 1);
      navigateBack(backStack[backStack.length - 1]);
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    //print("Build of bottom nav bar worked");

    // Screens to be present, will be switched with the help of bottom nav bar
    _screens = [
      Landing_Page(
          curUser: curUser,
          hasNoPosts: postsGlobal.length == 0 ? true : false,
          isLoading: isLoadingPost,
          isErrorLoadingPost: isFailedUserPost,
          scrollController: _scrollController,
          reactionCallback: reactionCallback,
          refresh: refreshLandingPage,
          refreshCallback: refreshCallback),
      Search_Page(
        currentUser: curUser,
      ),
      Wage(
        currentUser: curUser,
        isPostedCallback: isPostedCallback,
      ),
      NotificationPage(
        curUser: curUser,
      ),
      RcashScreen(
        Ruser: Ruser,
        reactionCallback: reactionCallback,
      )
    ];
    return isNewUserFailed
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child: ErrWidget(
              tryAgainOnPressed: () {
                //print("HEY");
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
                    //print("HI");
                    setState(() {
                      isLoading = true;
                      isFailedGetUser = false;
                      isFailedGetAllUser = false;
                      isFailedUserPost = false;
                    });
                    getUserAwait();

                    getAllPosts(curUser != null
                        ? curUser.id
                        : savedUser != null
                            ? savedUser.id
                            : null);
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
    //print("My saved user");
    // //print(savedUser.id);
    // //print(curUser.id);
    return postId == null
        ? WillPopScope(
            onWillPop: () {
              return customPop(context);
            },
            child: Scaffold(
              appBar: customAppBar(context),
              drawer: Nav_Drawer(
                yollarCallback: yollarCallback,
                feedbackCallback: feedbackCallback,
              ),
              body: _screens[_currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  if (Provider.of<Data>(context, listen: false).isRefreshing) {
                    return;
                  }
                  navigateTo(index);
                  setState(() => _currentIndex = index);
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  }
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                unselectedItemColor: colorUnselectedBottomNav.withOpacity(0.5),
                elevation: 5,
                items: [
                  "images/Home.svg",
                  "images/high-five.svg",
                  Icons.add_circle_outline_sharp,
                  "images/Notification.svg",
                  "images/yollar_outline.svg"
                ]
                    .asMap()
                    .map((key, value) {
                      if (key == 3) {
                        return MapEntry(
                          key,
                          BottomNavigationBarItem(
                              title: Text(
                                "",
                                style: TextStyle(
                                  fontSize: 0,
                                  color: _currentIndex == key
                                      ? colorButton
                                      : colorUnselectedBottomNav
                                          .withOpacity(0.5),
                                  fontFamily: "Lato",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon: Padding(
                                padding:
                                    const EdgeInsets.only(top: 2, bottom: 3.5),
                                child: Stack(
                                  children: [
                                    if (showNotification)
                                      Positioned(
                                        right: 1,
                                        top: 2,
                                        child: CircleAvatar(
                                          radius: 3,
                                          backgroundColor: Colors.red,
                                        ),
                                      ),
                                    SvgPicture.asset(
                                      value,
                                      color: _currentIndex != key
                                          ? colorUnselectedBottomNav
                                              .withOpacity(0.5)
                                          : colorPrimaryBlue,
                                      height: 25,
                                    ),
                                  ],
                                ),
                              )),
                        );
                      }
                      return MapEntry(
                        key,
                        BottomNavigationBarItem(
                            title: Text(
                              "",
                              style: TextStyle(
                                fontSize: 0,
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
                                      height: 25,
                                    ),
                                  )
                                : key == 4 || key == 1 || key == 0 || key == 3
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2, bottom: 3.5),
                                        child: SvgPicture.asset(
                                          value,
                                          color: _currentIndex != key
                                              ? colorUnselectedBottomNav
                                                  .withOpacity(0.5)
                                              : colorPrimaryBlue,
                                          height: 25,
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
                                          size: 35,
                                        ),
                                      )),
                      );
                    })
                    .values
                    .toList(),
              ),
            ),
          )
        : DisplayPost(
            postId: postId,
          );
  }
}
