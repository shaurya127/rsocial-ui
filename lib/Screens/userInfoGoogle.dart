import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Screens/create_account_page.dart';
import 'package:rsocial2/Screens/profile_pic.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../auth.dart';
import '../authLogic.dart';
import '../contants/constants.dart';
import '../model/user.dart' as user;

class UserInfoGoogle extends StatefulWidget {
  user.User currentUser;
  UserInfoGoogle({this.currentUser});
  @override
  _UserInfoGoogleState createState() => _UserInfoGoogleState();
}

class _UserInfoGoogleState extends State<UserInfoGoogle> {
  // The initial date that will be shown by the date picker
  DateTime selectedDate;

  final _formKey = GlobalKey<FormState>();

  // To check the gender while registering
  bool isMale = null;

  // To check whether the user has selected a date from the date picker
  bool isDateSelected = false;

  // Initial year for date picker
  final int initialYear = 1950;

  // Final year for the date picker
  final int finalYear = DateTime.now().year;

  // This function is used to select date from date picker
  selectDate(BuildContext context) async {
    print(DateTime(initialYear));
    print(DateTime(finalYear));
    final DateTime picked = await showDatePicker(
        context: (context),
        initialDate:
            selectedDate != null ? selectedDate : DateTime(initialYear),
        firstDate: DateTime(initialYear),
        lastDate: DateTime(finalYear));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    if (widget.currentUser.gender == null) {
      isMale = null;
    } else {
      if (widget.currentUser.gender == 'M') {
        isMale = true;
      } else
        isMale = false;
    }
    String dob = widget.currentUser.dob;

    try {
      this.selectedDate = widget.currentUser.dob != null
          ? DateTime.parse(dob.substring(6, 10) +
              "-" +
              dob.substring(3, 5) +
              "-" +
              dob.substring(0, 2))
          : DateTime(initialYear);
    } catch (E) {
      this.selectedDate = DateTime(initialYear);
    }

    if (widget.currentUser.dob != null) isDateSelected = true;
  } // Formatting the date in dd/mm/yyyy format

  String dateFormatting(DateTime selectedDate) {
    String date = selectedDate.toString().split(" ")[0];
    String res = date.substring(8, 10) +
        "/" +
        date.substring(5, 7) +
        "/" +
        date.substring(0, 4);
    print(res);
    return res;
  }

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
    //await _authInstance.signOut();
    logout(context);
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
                  child: SvgPicture.asset(
                    "images/rsocial-logo2.svg",
                    height: 50,
                  ),
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
                                child: Text(
                                    isDateSelected
                                        ? dateFormatting(selectedDate)
                                        : "Date of Birth",
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
                                            color: isMale != null && isMale
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
                                              color: isMale != null && isMale
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
                                            color: isMale != null && !isMale
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
                                              color: isMale != null && !isMale
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
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: FittedBox(
                    child: Text(
                      "By continuing you agree to our ",
                      style: TextStyle(
                        fontFamily: 'lato',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: FittedBox(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return TermsScreen();
                          }),
                        );
                      },
                      child: Text(
                        "Terms and Conditions",
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 16,
                          color: colorPrimaryBlue,
                          decoration: TextDecoration.underline,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
                    dateFormatting(selectedDate);
                    if (_formKey.currentState.validate() &&
                        isDateSelected &&
                        isMale != null) {
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

                    Fluttertoast.showToast(
                        msg: "Please fill all the details",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        fontSize: 15);

                    return null;
                  },
                  elevation: 0,
                ),
                SizedBox(
                  height: 32,
                ),
                // InkWell(
                //   onTap: () async {
                //     // FirebaseAnalytics().setUserProperty(
                //     //     name: 'Upload_pic_or_not', value: "skipped_pic");
                //     //widget.analytics.logEvent(name: "pic_Status_uploaded");
                //     return Navigator.push(
                //         context,
                //         PageTransition(
                //             settings: RouteSettings(name: "Profile_Pic_Page"),
                //             type: PageTransitionType.rightToLeft,
                //             child: ProfilePicPage(
                //                 currentUser: widget.currentUser)));
                //   },
                //   child: Text(
                //     "Skip for now",
                //     style: TextStyle(
                //         color: colorButton,
                //         fontFamily: "Lato",
                //         fontWeight: FontWeight.w400),
                //   ),
                // ),
                // SizedBox(
                //   height: 32,
                // ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class TermsScreen extends StatefulWidget {
  const TermsScreen({
    Key key,
  }) : super(key: key);

  @override
  _TermsScreenState createState() => _TermsScreenState();
}

var isLoading = true;

class _TermsScreenState extends State<TermsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorButton,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        opacity: 0.0,
        child: Stack(
          children: [
            WebView(
              initialUrl: 'https://relatotechnologies.com/tc/index.html',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (_) {
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
