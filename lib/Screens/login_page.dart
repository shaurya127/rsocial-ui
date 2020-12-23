import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:rsocial2/Screens/register_page.dart';
import 'package:rsocial2/Widgets/provider_button.dart';

import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/auth.dart';

import '../Widgets/RoundedButton.dart';
import '../constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../user.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'bottom_nav_bar.dart';
import 'otp_page.dart';
import '../authLogic.dart';

final googleSignIn = GoogleSignIn();
final fblogin = FacebookLogin();
final users = Firestore.instance.collection('users');

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
  User _currentUser;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: remoteConfig != null
          ? Container(
              child: Text('wait'),
            )
          : isLoading
              ? CircularProgressIndicator()
              : ListView(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: Image.asset("images/logo2.png"),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: TextFormField(
                              onChanged: (value) {
                                phoneNumber = value;
                                print(phoneNumber);
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length != 10 ||
                                    !regex.hasMatch(value)) {
                                  return "Please enter a valid phone number";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: kInputField.copyWith(
                                  hintText: "Mobile Number",
                                  // labelText: "Email or Mobile Number",
                                  labelStyle: TextStyle(
                                      color: Color(0xff263238).withOpacity(0.5),
                                      fontFamily: "Lato",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300)),
                            ),
                          ),

                          SizedBox(
                            height: 24,
                          ),
                          RoundedButton(
                            text: "Sign in",
                            //remoteConfig.getString('button_text'),
                            textColor: Colors.white,
                            color: colorButton,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                // To check if the country code has already been added
                                if (phoneNumber.length == 10)
                                  phoneNumber = '+91$phoneNumber';

                                var alertBox = AlertDialog(
                                  title: Text("Verify Phone"),
                                  titleTextStyle: TextStyle(
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 20),
                                  content: Text(phoneNumber.length == 10
                                      ? "We'll text your verification code to +91-$phoneNumber. Standard SMS fees may apply."
                                      : "We'll text your verification code to $phoneNumber. Standard SMS fees may apply."),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        "Edit",
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
                                    FlatButton(
                                      child: Text(
                                        "Proceed",
                                        style: TextStyle(
                                            color: colorButton,
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                        );

                                        print(
                                            'Phone number is: ' + phoneNumber);
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                settings: RouteSettings(
                                                    name: "Otp_Page"),
                                                type: PageTransitionType
                                                    .rightToLeft,
                                                child: OtpPage(
                                                  currentUser: currentUser,
                                                )));
                                      },
                                    ),
                                  ],
                                );
                                showDialog(
                                    context: (context),
                                    builder: (context) {
                                      return alertBox;
                                    });
                              }
                            },
                            elevation: 0,
                          ),
                          // RoundedButton(
                          //   text: "Sign In",
                          //   textColor: Colors.white,
                          //   color: colorButton,
                          //   onPressed: () {},
                          //   elevation: 0,
                          // ),
                          SizedBox(
                            height: 24,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Divider(
                                height: 1,
                                thickness: 4,
                              ),
                              Text("Or"),
                              Divider(
                                height: 1,
                                thickness: 1,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 24,
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
                            title: "Sign in with Facebook",
                            iconLocation: "images/facebook.svg",
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
                            title: "Sign in with Google",
                            iconLocation: "images/google.svg",
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
                                text: "Don't have an account ? ",
                                style: TextStyle(
                                    color: Color(0xff263238),
                                    fontFamily: "Lato",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16),
                                children: [
                                  TextSpan(
                                      text: "Sign Up",
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
                                                  child: RegisterPage()));
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
                  ],
                ),
    );
  }
}
