import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';

import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/profile_pic.dart';

import '../constants.dart';
import '../user.dart';
import 'bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';

class BioPage extends StatefulWidget {
  User currentUser;

  BioPage({this.currentUser});

  @override
  _BioPageState createState() => _BioPageState();
}

class _BioPageState extends State<BioPage> {
  String bio;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "Bio_Page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: ListView(children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment(-1, 0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: colorButton,
                    ),
                    onPressed: () {
                      return Navigator.pop(context);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                child: Image.asset("images/logo2.png"),
              ),
              SizedBox(
                height: 40,
              ),
              Center(
                child: Text(
                  "Describe yourself",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      fontFamily: "Lato"),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                "What makes you special ?",
                style: TextStyle(
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
              ),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                    onChanged: (value) {
                      widget.currentUser.bio = value;
                    },
                    minLines: 7,
                    maxLines: 7,
                    maxLength: 250,
                    style: TextStyle(fontSize: 19),
                    decoration: kInputField.copyWith(
                        hintText: "Your Bio...",
                        hintStyle: TextStyle(
                            color: Color(0xff263238).withOpacity(0.5),
                            fontSize: 16,
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w300))),
              ),
              SizedBox(
                height: 32,
              ),
              RoundedButton(
                text: "Continue",
                elevation: 0,
                onPressed: () async {
                  if (bio != null) {
                    widget.currentUser.bio = bio;
                  }

                  FirebaseAnalytics().setUserProperty(
                      name: 'Wrote_Bio_or_not', value: "wrote_bio");
                  return Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          settings: RouteSettings(name: "Landing_Page"),
                          builder: (BuildContext context) => BottomNavBar(
                                currentUser: widget.currentUser,
                                isNewUser: true,
                              )),
                      (Route<dynamic> route) => false);
                },
              ),
              SizedBox(
                height: 32,
              ),
              InkWell(
                onTap: () async {
                  FirebaseAnalytics().setUserProperty(
                      name: 'Wrote_Bio_or_not', value: "skipped_bio");
                  //widget.analytics.logEvent(name: 'setUserProp_success');
                  return Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          settings: RouteSettings(name: "Landing_Page"),
                          builder: (BuildContext context) => BottomNavBar(
                                currentUser: widget.currentUser,
                                isNewUser: true,
                              )),
                      (Route<dynamic> route) => false);
                },
                child: Text(
                  "Skip for now",
                  style: TextStyle(
                      color: colorButton,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
        ]));
  }
}
