import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../Widgets/RoundedButton.dart';

import '../main.dart';
import '../model/user.dart';
import '../contants/constants.dart';

import 'package:rsocial2/auth.dart';
import 'login_page.dart';
import 'otp_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Regex Expression to validate indian mobile numbers
  RegExp regex = new RegExp(regexForPhone);

  // The initial date that will be shown by the date picker
  DateTime selectedDate = DateTime.now();

  // To check the gender while registering
  bool isMale = true;

  // To check whether the user has selected a date from the date picker
  bool isDateSelected = false;

  // Initial year for date picker
  final int initialYear = 1900;

  // Final year for the date picker
  final int finalYear = 2025;

  // Global key for the form, used for validation of the form
  final _formKey = GlobalKey<FormState>();

  // The entered phone number by the user which is passed to the next screen as a parameter
  String phoneNumber;

  // First Name
  String fname;

  // Last Name
  String lname;

  // Gender
  String gender;

  // This function is used to select date from date picker
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final TapGestureRecognizer _gestureRecognizerTerm = TapGestureRecognizer()
    ..onTap = () {
      debugPrint("Hello World");
    };
  final TapGestureRecognizer _gestureRecognizerPrivacy = TapGestureRecognizer()
    ..onTap = () {
      debugPrint("Hello dskjfsd");
    };
  // final TapGestureRecognizer _gestureRecognizerSign = TapGestureRecognizer()
  //   ..onTap = () {
  //     Navigator.pushReplacement(context,
  //         PageTransition(type: PageTransitionType.leftToRight, child: Wage()));
  //   };

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                onChanged: (value) {
                                  fname = value;
                                },
                                validator: (value) {
                                  value = value.trim();
                                  if (value.isEmpty) {
                                    return "Please fill your first Name";
                                  }
                                  if (value.contains(" ")) {
                                    return "Can't contain spaces";
                                  }
                                  if (!RegExp(r'^([A-Za-z])+$')
                                      .hasMatch(value)) {
                                    return "can only contains letters";
                                  }

                                  return null;
                                },
                                decoration: kInputField.copyWith(
                                    hintText: "First name",
                                    hintStyle: TextStyle(
                                        color:
                                            Color(0xff263238).withOpacity(0.5),
                                        fontSize: 16,
                                        fontFamily: "Lato",
                                        fontWeight: FontWeight.w300))

                                // InputDecoration(
                                //     hintText: "First name",
                                //     hintStyle: TextStyle(
                                //         color: colorHintText.withOpacity(0.5),
                                //         fontFamily: "Lato",
                                //         fontWeight: FontWeight.w300)),
                                ),
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
                              onChanged: (value) {
                                lname = value;
                              },
                              validator: (value) {
                                value = value.trim();
                                if (value.isEmpty) {
                                  return "Please fill your Last Name";
                                }
                                if (value.contains(" ")) {
                                  return "Can't contain spaces";
                                }
                                if (!RegExp(r'^([A-Za-z])+$').hasMatch(value)) {
                                  return "can only contains letters";
                                }

                                return null;
                              },
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
                // Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 24.0),
                //     child: IntlPhoneField(
                //       validator: (value) {
                //         if (value == null ||
                //             value.isEmpty ||
                //             value.length != 10) {
                //           return "Please enter a valid phone number";
                //         }
                //         return "blabal";
                //         if (!regex.hasMatch(value))
                //           return "Please enter a valid phone number";
                //         return null;
                //       },
                //       decoration: InputDecoration(
                //         labelText: 'Phone Number',
                //         border: OutlineInputBorder(
                //           borderSide: BorderSide(),
                //         ),
                //       ),
                //       initialCountryCode: 'IN',
                //       onChanged: (phone) {
                //         phoneNumber = phone.completeNumber;
                //         print(phone.completeNumber);
                //       },
                //     )
                //
                //     // child: TextFormField(
                //     //   controller: _phoneController,
                //     //   keyboardType: TextInputType.number,
                //     //   decoration: kInputField.copyWith(
                //     //       hintText: "Mobile Number",
                //     //       // labelText: "Email or Mobile Number",
                //     //       labelStyle: TextStyle(
                //     //           color: Color(0xff263238).withOpacity(0.5),
                //     //           fontFamily: "Lato",
                //     //           fontSize: 16,
                //     //           fontWeight: FontWeight.w300)),
                //     // ),
                //     ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: RichText(
                    text: TextSpan(
                      text: "By Signing up, you agree to the ",
                      style: TextStyle(
                          color: Color(0xff263238), fontFamily: "Lato"),
                      children: [
                        TextSpan(
                            text: "Terms of Service",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                            recognizer: _gestureRecognizerTerm),
                        TextSpan(
                            text: " and ",
                            style: TextStyle(
                              color: Colors.black,
                            )),
                        TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                            recognizer: _gestureRecognizerPrivacy),
                        TextSpan(text: ".")
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                RoundedButton(
                  text: "Sign Up",
                  textColor: Colors.white,
                  color: colorButton,
                  onPressed: () {
                    print("hello");
                    if (_formKey.currentState.validate() && isDateSelected) {
                      // To check if the country code has already been added
                      if (phoneNumber.length == 10)
                        phoneNumber = '+91$phoneNumber';

                      // Creating current user
                      currentUser = User(
                          fname: fname,
                          lname: lname,
                          mobile: phoneNumber,
                          dob: dateFormatting(selectedDate),
                          gender: isMale ? 'M' : 'F');

                      print(currentUser);
                      print(currentUser.fname);
                      print(currentUser.mobile);
                      // Alert box to proceed for verification (otp)
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
                              // Navigator.pop(
                              //   context,
                              // );
                              // print('Phone number is: ' + phoneNumber);
                              // Navigator.push(
                              //     context,
                              //     PageTransition(
                              //         settings: RouteSettings(name: "Otp_Page"),
                              //         type: PageTransitionType.rightToLeft,
                              //         child:
                              //             OtpPage(currentUser: currentUser)));
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

                  // AlertDialog(
                  //   title: Text("Verify Phone"),
                  //   titleTextStyle: TextStyle(
                  //       fontFamily: "Lato",
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.black,
                  //       fontSize: 20),
                  //   content: Text(
                  //       "We'll text your verification code to +91 9999999999. Standard SMS fees may apply."),
                  //   actions: <Widget>[
                  //     FlatButton(
                  //       child: Text(
                  //         "Edit",
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
                  //     FlatButton(
                  //       child: Text(
                  //         "Proceed",
                  //         style: TextStyle(
                  //             color: colorButton,
                  //             fontFamily: "Lato",
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //       onPressed: () {
                  //         Navigator.pop(
                  //           context,
                  //         );
                  //         Navigator.push(
                  //             context,
                  //             PageTransition(
                  //                 type: PageTransitionType.rightToLeft,
                  //                 child: OtpPage()));
                  //       },
                  //     ),
                  //   ],
                  // );

                  elevation: 0,
                ),
                SizedBox(
                  height: 24,
                ),
                Padding(
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
