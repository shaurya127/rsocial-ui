import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Screens/userInfoFacebook.dart';
import 'package:rsocial2/user.dart';
import 'Screens/bottom_nav_bar.dart';
import 'Screens/create_account_page.dart';
import 'Screens/login_page.dart';
import 'Screens/profile_pic.dart';
import 'Screens/register_page.dart';
import 'Screens/userInfoGoogle.dart';
import 'Widgets/alert_box.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;

final googleSignIn = GoogleSignIn();
final fblogin = FacebookLogin();

signUpWithRsocial(BuildContext context) {
  Navigator.push(
      context,
      PageTransition(
          settings: RouteSettings(name: "Register_Page"),
          type: PageTransitionType.rightToLeft,
          child: RegisterPage()));
}

// Logic followed when user is logged-in using facebook
loginWithFacebook(User _currentUser, BuildContext context) async {
  // These are the permissions required
  final result = await fblogin
      .logIn(['email', 'public_profile', 'user_gender', 'user_birthday']);

  switch (result.status) {
    case FacebookLoginStatus.loggedIn:
      // Getting the token
      final token = result.accessToken.token;

      AuthCredential credential =
          FacebookAuthProvider.getCredential(accessToken: token);

      final FirebaseUser user =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser currentUser =
          await FirebaseAuth.instance.currentUser();

      assert(currentUser != null);

      if (user.uid == currentUser.uid) {
        // To check if the user already exists in firebase
        DocumentSnapshot doc = await users.document(user.uid).get();

        // if user does not exists
        if (!doc.exists) {
          final graphResponse = await http.get(
              'https://graph.facebook.com/v2.12/me?fields=name,picture,email,birthday&access_token=$token');

          // Fetching the body which contains the required fields
          final profile = jsonDecode(graphResponse.body);

          // Correcting the date format to the required format
          String birthday = profile['birthday'];
          birthday = birthday.substring(3, 5) +
              "/" +
              birthday.substring(0, 2) +
              birthday.substring(5);

          // Creating a user from the information in the body
          User curUser = User(
              fname: profile['name'].split(" ")[0],
              lname: profile['name'].split(" ").length == 2
                  ? profile['name'].split(" ")[1]
                  : "",
              dob: birthday,
              email: profile['email'],
              lollarAmount: 100,
              socialStanding: 2,
              photoUrl: profile["picture"]["data"]["url"]);

          Navigator.pop(context);

          return Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  settings: RouteSettings(name: "Profile_pic_page"),
                  builder: (BuildContext context) =>
                      UserInfoFacebook(currentUser: curUser)),
              (Route<dynamic> route) => false);
        }

        // if user already exists, we go to the landing page directly

        Navigator.pop(context);

        return Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                settings: RouteSettings(name: "Landing_Page"),
                builder: (BuildContext context) => BottomNavBar(
                      currentUser: _currentUser,
                      isNewUser: false,
                      sign_in_mode: "Facebook_sign_in",
                    )),
            (Route<dynamic> route) => false);
      }

      break;

    case FacebookLoginStatus.cancelledByUser:
      break;
    case FacebookLoginStatus.error:
      break;
  }
}

// Logic followed when logged in using google
loginWithGoogle(User _currentUser, BuildContext context) async {
  final GoogleSignInAccount googleUser = await googleSignIn.signIn();

  final GoogleSignInAuthentication googleKey = await googleUser.authentication;

  AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleKey.idToken, accessToken: googleKey.accessToken);

  final FirebaseUser user =
      await FirebaseAuth.instance.signInWithCredential(credential);

  assert(user.getIdToken() != null);
  final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
  assert(currentUser != null);
  print(user.uid);
  String user_id = user.uid;

  if (user.uid == currentUser.uid) {
    // Checking whether user already exists in firebase
    DocumentSnapshot doc = await users.document(user.uid).get();

    final GoogleSignInAccount guser = googleSignIn.currentUser;

    // If user does not exists
    if (!doc.exists) {
      print(guser.photoUrl);

      User curUser = User(
          fname: guser.displayName.split(" ")[0],
          lname: guser.displayName.split(" ").length == 2
              ? guser.displayName.split(" ")[1]
              : "",
          email: guser.email,
          lollarAmount: 1000,
          socialStanding: 1,
          photoUrl: guser.photoUrl);
      Navigator.pop(context);
      FirebaseAnalytics().setUserId(user_id);

      return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              settings: RouteSettings(name: "Profile_pic_page"),
              builder: (BuildContext context) =>
                  UserInfoGoogle(currentUser: curUser)),

          // settings: RouteSettings(name: "Profile_pic_page"),
          // builder: (BuildContext context) =>
          //     ProfilePicPage(currentUser: curUser)),
          // MaterialPageRoute(
          //     settings: RouteSettings(name: "Landing_Page"),
          //     builder: (BuildContext context) => BottomNavBar(
          //           currentUser: curUser,
          //           isNewUser: true,
          //       sign_in_mode: Sign_in_mode,
          //         )),
          (Route<dynamic> route) => false);
    }

    // if user already exists, the app directly goes to the landing page

    //Navigator.pop(context);
    //widget.analytics.setUserId(user_id);
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            settings: RouteSettings(name: "Landing_Page"),
            builder: (BuildContext context) => BottomNavBar(
                  currentUser: _currentUser,
                  sign_in_mode: "Google_sign_in",
                  isNewUser: false,
                )),
        (Route<dynamic> route) => false);
  }
}

// Logout logic for the app

void logout(BuildContext context) async {
  FirebaseAuth _authInstance = FirebaseAuth.instance;
  FirebaseUser user = await _authInstance.currentUser();

  if (user != null) {
    if (user.providerData[1].providerId == 'google.com') {
      await googleSignIn.disconnect();
    } else if (user.providerData[0].providerId == 'facebook.com') {
      await fblogin.logOut();
    }
    await _authInstance.signOut();
  } else {
    var alertBox = AlertDialogBox(
      title: "Error",
      content: "We are unable to contact our servers. Please try again.",
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

  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => CreateAccount()),
      (Route<dynamic> route) => false);
}
