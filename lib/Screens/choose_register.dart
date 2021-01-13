import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Screens/profile_pic.dart';
import 'package:rsocial2/Screens/register_page.dart';
import 'package:rsocial2/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rsocial2/Screens/register_page.dart';

import '../user.dart';
import 'login_page.dart';
import '../Widgets/provider_button.dart';
import 'package:rsocial2/authLogic.dart';
import 'bottom_nav_bar.dart';
import 'package:http/http.dart' as http;

class ChooseRegister extends StatefulWidget {
  @override
  _ChooseRegisterState createState() => _ChooseRegisterState();
}

class _ChooseRegisterState extends State<ChooseRegister> {
  final googleSignIn = GoogleSignIn();
  final fblogin = FacebookLogin();
  User _currentUser;
  String Sign_in_mode;
  bool isLoading = false;

  Future<bool> onBackPressed() async {
    // FirebaseAuth _authInstance = FirebaseAuth.instance;
    // FirebaseUser user = await _authInstance.currentUser();
    // if (user != null) {
    //   if (user.providerData[1].providerId == 'google.com') {
    //     await googleSignIn.disconnect();
    //   } else if (user.providerData[0].providerId == 'facebook.com') {
    //     await fblogin.logOut();
    //   }
    // }
    // await _authInstance.signOut();
    logout(context);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Container(
                    //   height: 90,
                    //   child: Image.asset(
                    //     "images/rsocial-logo.jpg",
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    Container(
                      child: SvgPicture.asset(
                        "images/rsocial-logo.svg",
                        height: 90,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ProviderButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        loginWithFacebook(_currentUser, context);
                        setState(() {
                          isLoading = false;
                        });
                      },
                      title: kFacebookButtonText,
                      iconLocation: "images/facebook_new.svg",
                      color: facebookTextColor,
                      buttonColor: facebookButtonColor,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    ProviderButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        loginWithGoogle(_currentUser, context);
                        setState(() {
                          isLoading = false;
                        });
                      },
                      title: kGoogleButtonText,
                      iconLocation: "images/google_new.svg",
                      color: googleTextColor,
                      buttonColor: googleButtonColor,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    // ProviderButton(
                    //   onPressed: () {
                    //     // signUpWithRsocial(context);
                    //   },
                    //   title: kRsocialButtonText,
                    //   iconLocation: "images/google.svg",
                    //   color: rsocialTextColor,
                    //   buttonColor: rsocialTextColor.withOpacity(0.15),
                    // ),
                  ],
                ),
              ),
      ),
    );
  }
}
