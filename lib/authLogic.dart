import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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

final googleSignIn = GoogleSignIn(scopes: [
  "https://www.googleapis.com/auth/userinfo.email",
  "https://www.googleapis.com/auth/userinfo.profile",
  "https://www.googleapis.com/auth/user.birthday.read",
  "https://www.googleapis.com/auth/user.gender.read"
]);
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
      var graphResponse, profile;
      try {
        graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,birthday&access_token=$token');
      } on PlatformException catch (e) {
        if (e.code == 'network_error') {
          var alertBox = AlertDialogBox(
            title: "Error",
            content:
                "We are unable to contact our servers. Please check your internet connection.",
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
          return;
        }
      } catch (e) {
        var alertBox = AlertDialogBox(
          title: "Error",
          content: "Some error occurred. Please try again",
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
        return;
      }
      profile = jsonDecode(graphResponse.body);
      if (profile['email'] == null || profile['email'] == "") {
        var alertBox = AlertDialogBox(
          title: "Email Not Found",
          content:
              "Email is not verified for facebook. You can either verify it first, or use another method of sign up",
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
        return;
      } else {
        try {
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
              // final graphResponse = await http.get(
              //     'https://graph.facebook.com/v2.12/me?fields=name,picture,email,birthday&access_token=$token');
              //
              // // Fetching the body which contains the required fields
              // final profile = jsonDecode(graphResponse.body);

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
        } on PlatformException catch (e) {
          if (e.code == 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL') {
            var alertBox = AlertDialogBox(
              title: "Error",
              content:
                  "This id has been already used with a different provider. Please use a different id or sign-in with the different provider",
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

          if (e.code == 'network_error') {
            var alertBox = AlertDialogBox(
              title: "Error",
              content:
                  "We are unable to contact our servers. Please check your internet connection.",
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
      }

      break;

    case FacebookLoginStatus.cancelledByUser:
      break;
    case FacebookLoginStatus.error:
      break;
  }
}

class Inf {
  String gender = null;
  String dob = null;
}

Future<Inf> getGenderBirthday() async {
  Inf inf = Inf();

  var key;
  if (Platform.isIOS) {
    key = "AIzaSyABeypdm2QEwvSSI8LpyP1lBJDRiUnURUk";
  } else if (Platform.isAndroid) {
    key = "AIzaSyDqj2ohJ_jy_9FYJWuscicm3VtBpizR4OI";
  }

  final headers = await googleSignIn.currentUser.authHeaders;
  final r = await http.get(googlePeopleApi + key,
      headers: {"Authorization": headers["Authorization"]});
  final response = jsonDecode(r.body);

  print("This is response from google gender: ");
  print(response);
  if (response["genders"] != null) {
    if (response["genders"][0]["formattedValue"] == "Male") {
      inf.gender = "M";
    } else if (response["genders"][0]["formattedValue"] == "Female") {
      inf.gender = "F";
    }
    //inf.gender = response["genders"][0]["formattedValue"] == "Male" ? "M" : "F";
    print(response['genders'][0]["formattedValue"]);
  }
  if (response['birthdays'] != null) {
    int day = response["birthdays"][0]["date"]["day"];
    int month = response["birthdays"][0]["date"]["month"];
    int year = response["birthdays"][0]["date"]["year"];
    if (day == null || month == null || year == null) {
      return inf;
    }

    String monthString = month < 10 ? "0" + month.toString() : month.toString();
    String dayString = day < 10 ? "0" + day.toString() : day.toString();
    inf.dob = dayString + "/" + monthString + "/" + year.toString();
  }

  return inf;
}

// Logic followed when logged in using google
loginWithGoogle(User _currentUser, BuildContext context) async {
  FirebaseUser user;
  FirebaseUser currentUser;
  String user_id;
  try {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleKey =
          await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleKey.idToken, accessToken: googleKey.accessToken);

      var alertBox = AlertDialog(
        //title: "",//Text("Just a second, logging you in."),

        content: Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Loading...",
                  style: TextStyle(color: colorUnselectedBottomNav),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(child: Center(child: CircularProgressIndicator())),
              ],
            )),
      );

      showDialog(
          context: (context),
          builder: (context) => alertBox,
          barrierDismissible: false);

      user = await FirebaseAuth.instance.signInWithCredential(credential);

      assert(user.getIdToken() != null);
      currentUser = await FirebaseAuth.instance.currentUser();
      assert(currentUser != null);
      print(user.uid);
      user_id = user.uid;
    }
  } on PlatformException catch (e) {
    if (e.code == 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL') {
      var alertBox = AlertDialogBox(
        title: "Error",
        content:
            "This id has been already used with a different provider. Please use a different id or sign-in with the different provider",
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

    if (e.code == 'network_error') {
      var alertBox = AlertDialogBox(
        title: "Error",
        content:
            "We are unable to contact our servers. Please check your internet connection.",
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

  if (user.uid == currentUser.uid) {
    // Checking whether user already exists in firebase
    DocumentSnapshot doc = await users.document(user.uid).get();

    final GoogleSignInAccount guser = googleSignIn.currentUser;

    // If user does not exists
    if (!doc.exists) {
      print("Hello");
      Inf inf = await getGenderBirthday();
      print(inf.gender);
      print(inf.dob);

      print(guser.photoUrl);
      print(guser.displayName);
      User curUser = User(
          fname: guser.displayName.split(" ")[0],
          lname: guser.displayName.split(" ").length == 2
              ? guser.displayName.split(" ")[1]
              : "",
          email: guser.email,
          lollarAmount: 1000,
          socialStanding: 1,
          photoUrl: guser.photoUrl,
          gender: inf.gender,
          dob: inf.dob);
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
    if (Platform.isIOS) {
      if (user.providerData[0].providerId == 'google.com') {
        try {
          await googleSignIn.disconnect();
        } on PlatformException catch (e) {
          if (e.code == 'Failed to disconnect') {
            print("Failed to disconnect");
          }
        }
      }
    } else {
      if (user.providerData[1].providerId == 'google.com') {
        try {
          await googleSignIn.disconnect();
        } on PlatformException catch (e) {
          if (e.code == 'Failed to disconnect') {
            print("Failed to disconnect");
          }
        }
      } else if (user.providerData[0].providerId == 'facebook.com') {
        await fblogin.logOut();
      }
    }
    await _authInstance.signOut();
  } else {
    // var alertBox = AlertDialogBox(
    //   title: "Error",
    //   content: "We are unable to contact our servers. Please try again.",
    //   actions: <Widget>[
    //     FlatButton(
    //       child: Text(
    //         "Back",
    //         style: TextStyle(
    //           color: colorButton,
    //           fontFamily: "Lato",
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //       onPressed: () {
    //         Navigator.pop(
    //           context,
    //         );
    //       },
    //     ),
    //   ],
    // );
    //
    // showDialog(context: (context), builder: (context) => alertBox);
  }

  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => CreateAccount()),
      (Route<dynamic> route) => false);
}
