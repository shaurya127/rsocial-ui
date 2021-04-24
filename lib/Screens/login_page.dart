import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:page_transition/page_transition.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:rsocial2/Screens/choose_register.dart';
import 'package:rsocial2/Screens/register_page.dart';
import 'package:rsocial2/Widgets/provider_button.dart';

import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/auth.dart';

import '../Widgets/RoundedButton.dart';
import '../contants/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../model/user.dart' as user;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'bottom_nav_bar.dart';
import 'otp_page.dart';
import '../authLogic.dart';

final googleSignIn = GoogleSignIn();
final fblogin = FacebookLogin();
final users = FirebaseFirestore.instance.collection('users');

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}
//
// Future<RemoteConfig> setupRemoteConfig() async {
//   await Firebase.initializeApp();
//   final RemoteConfig remoteConfig = await RemoteConfig.instance;
//
//   remoteConfig.setConfigSettings(RemoteConfigSettings(
//     debugMode: true,
//   ));
//   remoteConfig.setDefaults(<String, dynamic>{
//     'button_color': Color(0xfffffff),
//     'button_text': 'Sign In'
//   });
//
//   try {
//     await remoteConfig.fetch(expiration: Duration(seconds: 0));
//     await remoteConfig.activateFetched();
//   } on FetchThrottledException catch (exception) {
//     print(exception);
//   } catch (exception) {
//     print('Unable to fetch remote config');
//   }
//   print(remoteConfig);
//   print("haha");
//   return remoteConfig;
// }

class _LoginPageState extends State<LoginPage> {
  // Regex to validate indian phone number
  RegExp regex = new RegExp(regexForPhone);
  RemoteConfig remoteConfig;

  // Global Key for validating the form
  final _formKey = GlobalKey<FormState>();

  // Variable to check whether the person is signed in or not
  bool isAuth = false;

  bool isLoading = false;

  // void getConfig() async {
  //   remoteConfig = await setupRemoteConfig();
  //   setState(() {});
  // }
  user.User _currentUser;

  @override
  void initState() {
    //  getConfig();

    // googleSignIn.onCurrentUserChanged.listen((account) {
    //   helpSign(account);
    // }).onError((err) {
    //   print(err);
    // });
  }

  // To store the phone number entered by user
  String phoneNumber;

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
        body: remoteConfig != null
            ? Container(
                child: Text('wait'),
              )
            : isLoading
                ? CircularProgressIndicator()
                : Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // SizedBox(
                          //   height: 20,
                          // ),
                          // SvgPicture.asset(
                          //   "images/rsocial-text.svg",
                          //   height: 90,
                          // ),
                          // SizedBox(
                          //   height: 20,
                          // ),
                          // Padding(
                          //   padding:
                          //       const EdgeInsets.symmetric(horizontal: 24.0),
                          //   child: TextFormField(
                          //     onChanged: (value) {
                          //       phoneNumber = value;
                          //       print(phoneNumber);
                          //     },
                          //     validator: (value) {
                          //       if (value == null ||
                          //           value.isEmpty ||
                          //           value.length != 10 ||
                          //           !regex.hasMatch(value)) {
                          //         return "Please enter a valid phone number";
                          //       }
                          //       return null;
                          //     },
                          //     keyboardType: TextInputType.number,
                          //     decoration: kInputField.copyWith(
                          //         hintText: "Mobile Number",
                          //         // labelText: "Email or Mobile Number",
                          //         labelStyle: TextStyle(
                          //             color:
                          //                 Color(0xff263238).withOpacity(0.5),
                          //             fontFamily: "Lato",
                          //             fontSize: 16,
                          //             fontWeight: FontWeight.w300)),
                          //   ),
                          // ),
                          //
                          // SizedBox(
                          //   height: 24,
                          // ),
                          // RoundedButton(
                          //   text: "Sign in",
                          //   //remoteConfig.getString('button_text'),
                          //   textColor: Colors.white,
                          //   color: colorButton,
                          //   onPressed: () {
                          //     // if (_formKey.currentState.validate()) {
                          //     //   // To check if the country code has already been added
                          //     //   if (phoneNumber.length == 10)
                          //     //     phoneNumber = '+91$phoneNumber';
                          //     //
                          //     //   var alertBox = AlertDialog(
                          //     //     title: Text("Verify Phone"),
                          //     //     titleTextStyle: TextStyle(
                          //     //         fontFamily: "Lato",
                          //     //         fontWeight: FontWeight.bold,
                          //     //         color: Colors.black,
                          //     //         fontSize: 20),
                          //     //     content: Text(phoneNumber.length == 10
                          //     //         ? "We'll text your verification code to +91-$phoneNumber. Standard SMS fees may apply."
                          //     //         : "We'll text your verification code to $phoneNumber. Standard SMS fees may apply."),
                          //     //     actions: <Widget>[
                          //     //       FlatButton(
                          //     //         child: Text(
                          //     //           "Edit",
                          //     //           style: TextStyle(
                          //     //             color: colorButton,
                          //     //             fontFamily: "Lato",
                          //     //             fontWeight: FontWeight.bold,
                          //     //           ),
                          //     //         ),
                          //     //         onPressed: () {
                          //     //           Navigator.pop(
                          //     //             context,
                          //     //           );
                          //     //         },
                          //     //       ),
                          //     //       FlatButton(
                          //     //         child: Text(
                          //     //           "Proceed",
                          //     //           style: TextStyle(
                          //     //               color: colorButton,
                          //     //               fontFamily: "Lato",
                          //     //               fontWeight: FontWeight.bold),
                          //     //         ),
                          //     //         onPressed: () {
                          //     //           Navigator.pop(
                          //     //             context,
                          //     //           );
                          //     //
                          //     //           print('Phone number is: ' +
                          //     //               phoneNumber);
                          //     //           Navigator.push(
                          //     //               context,
                          //     //               PageTransition(
                          //     //                   settings: RouteSettings(
                          //     //                       name: "Otp_Page"),
                          //     //                   type: PageTransitionType
                          //     //                       .rightToLeft,
                          //     //                   child: OtpPage(
                          //     //                     currentUser: currentUser,
                          //     //                   )));
                          //     //         },
                          //     //       ),
                          //     //     ],
                          //     //   );
                          //     //   showDialog(
                          //     //       context: (context),
                          //     //       builder: (context) {
                          //     //         return alertBox;
                          //     //       });
                          //     // }
                          //   },
                          //   elevation: 0,
                          // ),
                          // // RoundedButton(
                          // //   text: "Sign In",
                          // //   textColor: Colors.white,
                          // //   color: colorButton,
                          // //   onPressed: () {},
                          // //   elevation: 0,
                          // // ),
                          // SizedBox(
                          //   height: 24,
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: <Widget>[
                          //     Divider(
                          //       height: 1,
                          //       thickness: 4,
                          //     ),
                          //     Text("Or"),
                          //     Divider(
                          //       height: 1,
                          //       thickness: 1,
                          //     )
                          //   ],
                          // ),
                          SizedBox(
                            height: 24,
                          ),
                          Container(
                            child: SvgPicture.asset(
                              "images/rsocial-logo.svg",
                              height: 90,
                              //color: colorPrimaryBlue,
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
                            title: kFacebookButtonTextSignIn,
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
                              loginWithGoogle(_currentUser, context, true);
                              setState(() {
                                isLoading = false;
                              });
                            },
                            title: kGoogleButtonTextSignIn,
                            iconLocation: "images/google_new.svg",
                            color: googleTextColor,
                            buttonColor: googleButtonColor,
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: RichText(
                              text: TextSpan(
                                text: kLoginPageNoAccount,
                                style: TextStyle(
                                    color: colorHintText,
                                    fontFamily: "Lato",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                                children: [
                                  TextSpan(
                                      text: kLoginPageSignUp,
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  settings: RouteSettings(
                                                      name: "Register_Page"),
                                                  type: PageTransitionType
                                                      .bottomToTop,
                                                  child: ChooseRegister()));
                                        }),
                                  TextSpan(text: ".")
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          )
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
