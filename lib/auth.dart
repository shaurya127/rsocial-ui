import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'package:rsocial2/Widgets/disabled_reaction_button.dart';
import 'package:rsocial2/deep_links.dart';
import 'Widgets/post_tile.dart';
import 'model/user.dart' as user;

import 'Screens/bottom_nav_bar.dart';
import 'Screens/create_account_page.dart';
import 'package:http/http.dart' as http;

import 'Screens/display_post.dart';
import 'Screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

user.User currentUser;
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
    User user = _auth.currentUser;
    print("Hello");
    if (user == null) {
      isAuthenticated = false;
    } else {
      DocumentSnapshot doc = await users.doc(user.uid).get();
      isAuthenticated = doc.exists ? true : false;
    }

    //isAuthenticated = await _auth.currentUser() == null ? false : true;
    setState(() {});
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
  void initState() {
    // TODO: implement initState
    super.initState();
    isUserAuthenticated();
    checkForDynamicLinks();
  }

  void checkForDynamicLinks() async {
    setState(() {
      findingLink = true;
    });
    initDynamicLinks();
    setState(() {
      findingLink = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isAuthenticated == null
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
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
