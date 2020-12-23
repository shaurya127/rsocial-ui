import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Screens/profile_pic.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:rsocial2/auth.dart';

import '../authLogic.dart';
import '../constants.dart';
import '../user.dart';
import 'create_account_page.dart';

class UserInfoFacebook extends StatefulWidget {
  final User currentUser;
  @override
  _UserInfoFacebookState createState() => _UserInfoFacebookState();

  UserInfoFacebook({this.currentUser});
}

class _UserInfoFacebookState extends State<UserInfoFacebook> {
  DateTime selectedDate;

  final _formKey = GlobalKey<FormState>();

  // To check the gender while registering
  bool isMale = true;

  // To check whether the user has selected a date from the date picker
  bool isDateSelected = false;

  // Initial year for date picker
  final int initialYear = 1900;

  // Final year for the date picker
  final int finalYear = 2025;

  @override
  void initState() {
    selectedDate = widget.currentUser.dob != null
        ? stringToDateTime(widget.currentUser.dob)
        : DateTime.now();
  } // This function is used to select date from date picker

  selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: (context),
        initialDate: DateTime.now(),
        firstDate: DateTime(initialYear),
        lastDate: DateTime(finalYear));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  DateTime stringToDateTime(String dob) {
    return DateTime.parse(dob.substring(6, 10) +
        "-" +
        dob.substring(3, 5) +
        "-" +
        dob.substring(0, 2));
  }

  // Formatting the date in dd/mm/yyyy format
  String dateFormatting(DateTime selectedDate) {
    String date = selectedDate.toString().split(" ")[0];
    String res = date.substring(8, 10) +
        "/" +
        date.substring(5, 7) +
        "/" +
        date.substring(0, 4);
    return res;
  }

  Future<bool> onBackPressed() async {
    FirebaseAuth _authInstance = FirebaseAuth.instance;

    FirebaseUser user = await _authInstance.currentUser();
    if (user != null) {
      if (user.providerData[1].providerId == 'google.com') {
        await googleSignIn.disconnect();
      } else if (user.providerData[0].providerId == 'facebook.com') {
        await fblogin.logOut();
      }
    }
    await _authInstance.signOut();
    Navigator.pop(context, true);

    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            settings: RouteSettings(name: "Profile_pic_page"),
            builder: (BuildContext context) => CreateAccount()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
          body: ListView(
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: 150,
                            child: TextFormField(
                                initialValue: widget.currentUser.fname != null
                                    ? widget.currentUser.fname
                                    : "",
                                enabled: false,
                                decoration: kInputField.copyWith(
                                    hintText: "First name",
                                    hintStyle: TextStyle(
                                        color:
                                            Color(0xff263238).withOpacity(0.5),
                                        fontSize: 16,
                                        fontFamily: "Lato",
                                        fontWeight: FontWeight.w300))),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            width: 150,
                            child: TextFormField(
                              enabled: false,
                              initialValue: widget.currentUser.lname != null
                                  ? widget.currentUser.lname
                                  : "",
                              decoration: kInputField.copyWith(
                                  hintText: "Last name",
                                  hintStyle: TextStyle(
                                      color: Color(0xff263238).withOpacity(0.5),
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.w300)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            isDateSelected = true;
                            selectDate(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.5)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 17),
                                child: Text(dateFormatting(selectedDate),
                                    style: isDateSelected
                                        ? TextStyle(
                                            fontFamily: "Lato",
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal)
                                        : TextStyle(
                                            color:
                                                colorHintText.withOpacity(0.5),
                                            fontFamily: "Lato",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Container(
                              width: 150,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  border: Border.all(color: Colors.grey)),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isMale = true;
                                        });
                                      },
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                            color: isMale
                                                ? colorButton
                                                : Colors.white,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft:
                                                    Radius.circular(8))),
                                        child: Center(
                                            child: Text(
                                          "Male",
                                          style: TextStyle(
                                              fontFamily: "Lato",
                                              fontWeight: FontWeight.bold,
                                              color: isMale
                                                  ? Colors.white
                                                  : Colors.black),
                                        )),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isMale = false;
                                        });
                                      },
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                            color: !isMale
                                                ? colorButton
                                                : Colors.white,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                bottomRight:
                                                    Radius.circular(8))),
                                        child: Center(
                                            child: Text(
                                          "Female",
                                          style: TextStyle(
                                              fontFamily: "Lato",
                                              fontWeight: FontWeight.bold,
                                              color: !isMale
                                                  ? Colors.white
                                                  : Colors.black),
                                        )),
                                      ),
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 24.5,
                ),
                RoundedButton(
                  text: "Continue",
                  textColor: Colors.white,
                  color: colorButton,
                  onPressed: () {
                    print("hello");
                    if (_formKey.currentState.validate() && isDateSelected) {
                      widget.currentUser.dob = dateFormatting(selectedDate);
                      widget.currentUser.gender = isMale ? 'M' : 'F';

                      return Navigator.push(
                          context,
                          PageTransition(
                              settings: RouteSettings(name: "Profile_Pic_Page"),
                              type: PageTransitionType.rightToLeft,
                              child: ProfilePicPage(
                                  currentUser: widget.currentUser)));
                    }
                    return null;
                  },
                  elevation: 0,
                ),
                SizedBox(
                  height: 32,
                ),
                InkWell(
                  onTap: () async {
                    // FirebaseAnalytics().setUserProperty(
                    //     name: 'Upload_pic_or_not', value: "skipped_pic");
                    //widget.analytics.logEvent(name: "pic_Status_uploaded");
                    return Navigator.push(
                        context,
                        PageTransition(
                            settings: RouteSettings(name: "Profile_Pic_Page"),
                            type: PageTransitionType.rightToLeft,
                            child: ProfilePicPage(
                                currentUser: widget.currentUser)));
                  },
                  child: Text(
                    "Skip for now",
                    style: TextStyle(
                        color: colorButton,
                        fontFamily: "Lato",
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
