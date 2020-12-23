import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:rsocial2/Screens/choose_register.dart';
import 'package:rsocial2/Screens/register_page.dart';
import 'package:rsocial2/main.dart';

import '../constants.dart';
import 'choose_register.dart';
import 'login_page.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "Create_Acc");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Time to value relationships, Access your social bonds.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 82,
          ),
          RoundedButton(
            textColor: Colors.white,
            color: colorButton,
            text: "Create Account",
            onPressed: () {
              //Navigator.pop(context);
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      settings: RouteSettings(name: "Choose_Register"),
                      child: ChooseRegister()));
            },
            elevation: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account ? ",
                      style: TextStyle(
                          color: Color(0xff263238),
                          fontFamily: "Lato",
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                      children: [
                        TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        settings:
                                            RouteSettings(name: "Login_Page"),
                                        type: PageTransitionType.bottomToTop,
                                        child: LoginPage()));
                              }),
                        TextSpan(text: ".")
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
