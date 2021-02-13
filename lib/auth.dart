import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'model/user.dart';

import 'Screens/bottom_nav_bar.dart';
import 'Screens/create_account_page.dart';
import 'package:http/http.dart' as http;

import 'Screens/display_post.dart';
import 'Screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

User currentUser;
String postId;
String inviteSenderId;

class AuthScreen extends StatefulWidget {
  FirebaseAnalytics analytics;
  FirebaseAnalyticsObserver observer;

  AuthScreen({this.observer, this.analytics});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool isAuthenticated = null;
  bool findingLink = true;

  void isUserAuthenticated() async {
    FirebaseUser user = await _auth.currentUser();
    print("Hello");
    if (user == null) {
      isAuthenticated = false;
    } else {
      DocumentSnapshot doc = await users.document(user.uid).get();
      isAuthenticated = doc.exists ? true : false;
    }

    //isAuthenticated = await _auth.currentUser() == null ? false : true;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isUserAuthenticated();
    initDynamicLinks();
  }

  void initDynamicLinks() async {
    setState(() {
      findingLink = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    //final Uri deepLink = data?.link;

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        print(
            "the postid is:${deepLink.queryParameters['postid']}"); // <- prints 'abc'
        postId = deepLink.queryParameters['postid'];
        inviteSenderId = deepLink.queryParameters['sender'];
        prefs.setString('inviteSenderId', inviteSenderId);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      postId = deepLink.queryParameters['postid'];
      inviteSenderId = deepLink.queryParameters['sender'];
    }

    setState(() {
      findingLink = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isAuthenticated == null
        ? Scaffold(body: Center(child: CircularProgressIndicator())
            // ColorizeAnimatedTextKit(
            //     onTap: () {
            //       print("Tap Event");
            //     },
            //     text: [
            //       "Loading",
            //     ],
            //     textStyle: TextStyle(fontSize: 50.0, fontFamily: "Horizon"),
            //     colors: [
            //       Colors.purple,
            //       Colors.blue,
            //       Colors.yellow,
            //       Colors.red,
            //     ],
            //     textAlign: TextAlign.start,
            //     alignment: AlignmentDirectional.topStart // or Alignment.topLeft
            //     ),
            )
        : (findingLink
            ? Scaffold(body: Center(child: CircularProgressIndicator()))
            : (isAuthenticated
                ? BottomNavBar(
                    currentUser: currentUser,
                    isNewUser: false,
                    sign_in_mode: "",
                  )
                : CreateAccount()));
  }
}
