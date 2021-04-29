import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:rsocial2/Screens/choose_register.dart';
import 'package:rsocial2/Screens/register_page.dart';
import 'package:rsocial2/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth.dart';
import '../contants/constants.dart';
import '../deep_links.dart';
import 'choose_register.dart';
import 'login_page.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool findingLink = false;
  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    FirebaseAnalytics().setCurrentScreen(screenName: "Create_Acc");
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
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                kCreateAccountText,
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
            text: kCreateAccountButton,
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
                      text: kCreateAccountAlready,
                      style: TextStyle(
                          color: Color(0xff263238),
                          fontFamily: "Lato",
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                      children: [
                        TextSpan(
                            text: kCreateAccountSignIn,
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        settings:
                                            RouteSettings(name: "Login_Page"),
                                        type: PageTransitionType.bottomToTop,
                                        child: LoginPage()));
                              }),
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
