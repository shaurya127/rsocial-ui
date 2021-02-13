// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:page_transition/page_transition.dart';
//
// import 'package:rsocial2/Screens/bottom_nav_bar.dart';
// import 'package:rsocial2/Screens/password_page.dart';
// import 'package:rsocial2/Screens/profile_pic.dart';
// import 'package:rsocial2/Widgets/alert_box.dart';
//
// import '../Widgets/RoundedButton.dart';
// import '../constants.dart';
// import 'dart:async';
// import 'file:///D:/Flutter/rsocial_ui/lib/model/user.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'login_page.dart';
//
// class OtpPage extends StatefulWidget {
//   final User currentUser;
//
//   OtpPage({@required this.currentUser});
//
//   @override
//   _OtpPageState createState() => _OtpPageState(currentUser);
// }
//
// class _OtpPageState extends State<OtpPage> {
//   _OtpPageState(this.currentUser);
//
//   FocusNode pin1FocusNode;
//   FocusNode pin2FocusNode;
//   FocusNode pin3FocusNode;
//   FocusNode pin4FocusNode;
//   FocusNode pin5FocusNode;
//   FocusNode pin6FocusNode;
//
//   List<int> l = new List();
//   bool isAutoVerified = false;
//   bool iscodeSent = false;
//   bool isAutoRetrievedFailed = false;
//   User currentUser;
//   String verificationId;
//   Timer _timer;
//   int _start = 25;
//
//   String smscode = "";
//   List<TextEditingController> otpController = new List<TextEditingController>();
//
//   bool isBlockFull() {
//     for (int i = 0; i < otpLength; i++) {
//       if (l[i] == -1) {
//         return false;
//       }
//     }
//
//     return true;
//   }
//
//   final int otpLength = 6;
//   void initializeList() {
//     for (int i = 0; i < otpLength; i++) {
//       l.add(-1);
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     pin1FocusNode = FocusNode();
//     pin2FocusNode = FocusNode();
//     pin3FocusNode = FocusNode();
//     pin4FocusNode = FocusNode();
//     pin5FocusNode = FocusNode();
//     pin6FocusNode = FocusNode();
//     print("number id: ${currentUser.mobile}");
//     loginUserWithPhone(currentUser.mobile, context);
//     initializeList();
//     startTimer();
//   }
//
//   @override
//   void dispose() {
//     pin1FocusNode.dispose();
//     pin2FocusNode.dispose();
//     pin3FocusNode.dispose();
//     pin4FocusNode.dispose();
//     pin5FocusNode.dispose();
//     pin6FocusNode.dispose();
//     _timer.cancel();
//     super.dispose();
//   }
//
//   void startTimer() {
//     const oneSec = const Duration(seconds: 1);
//     _timer = new Timer.periodic(
//       oneSec,
//       (Timer timer) => setState(
//         () {
//           if (_start < 1) {
//             timer.cancel();
//           } else {
//             _start = _start - 1;
//           }
//         },
//       ),
//     );
//   }
//
//   isUserExists(FirebaseUser user) async {
//     DocumentSnapshot doc = await users.document(user.uid).get();
//     if (!doc.exists) {
//       return Navigator.push(
//           context,
//           PageTransition(
//               settings: RouteSettings(name: "Profile_pic_page"),
//               type: PageTransitionType.rightToLeft,
//               child: ProfilePicPage(currentUser: currentUser),
//           ));
//     } else {
//       return Navigator.push(
//           context,
//           PageTransition(
//               type: PageTransitionType.rightToLeft,
//               settings: RouteSettings(name: "Landing_Page"),
//               child: BottomNavBar(
//                 sign_in_mode: "RSocial_sign_in",
//                 currentUser: currentUser,
//                 isNewUser: false,
//               )));
//     }
//   }
//
//   Future<bool> loginUserWithPhone(String phone, BuildContext context) async {
//
//     PhoneVerificationCompleted verificationSuccess(FirebaseUser user) {
//       setState(() {
//         isAutoVerified = true;
//       });
//
//       print('verified');
//       print(verificationId);
//       print(smscode);
//
//       isUserExists(user);
//     }
//
//     PhoneVerificationFailed verificationUnsuccess(AuthException authexception) {
//       if (authexception.code == 'invalid-phone-number') {
//         var alertBox = AlertDialogBox(
//           title: "Invalid phone number",
//           content: "Please check your phone number",
//           actions: <Widget>[
//             FlatButton(
//               child: Text(
//                 "Back",
//                 style: TextStyle(
//                   color: colorButton,
//                   fontFamily: "Lato",
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.pop(
//                   context,
//                 );
//               },
//             ),
//           ],
//         );
//         showDialog(
//             context: (context),
//             builder: (context) {
//               return alertBox;
//             });
//       }
//     }
//
//     final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
//       this.verificationId = verId;
//       print("auto retrieve timeout");
//       setState(() {
//         isAutoRetrievedFailed = true;
//       });
//     };
//
//     FirebaseAuth _auth = FirebaseAuth.instance;
//     _auth.verifyPhoneNumber(
//         phoneNumber: phone,
//         timeout: Duration(seconds: 20),
//         verificationCompleted: verificationSuccess
//         //     (FirebaseUser user) async{
//         //   AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: null, smsCode: null)
//         //   FirebaseUser user = await _auth.signInWithCredential(credential);
//         //
//         // }
//         ,
//         verificationFailed: verificationUnsuccess,
//         codeSent: (String verificationId, [int forceResendingToken]) async {
//           this.verificationId = verificationId;
//           print("code sent");
//           print(verificationId);
//           if (verificationId != null && smscode != null) {
//             AuthCredential phoneAuthCredential =
//                 PhoneAuthProvider.getCredential(
//                     verificationId: verificationId, smsCode: smscode);
//
//             // await FirebaseAuth.instance
//             //     .signInWithCredential(phoneAuthCredential);
//             //
//             // Navigator.push(
//             //     context,
//             //     PageTransition(
//             //         type: PageTransitionType.rightToLeft,
//             //         child: BottomNavBar(currentUser: currentUser, isNewUser: )));
//           }
//         },
//         codeAutoRetrievalTimeout: autoRetrieve);
//   }
//
//   // Used when the user does manual sign in and clicks continue
//   signInManually() async {
//     // if (FirebaseAuth.instance.currentUser() != null){
//     //
//     // }
//     try {
//       AuthCredential credential = PhoneAuthProvider.getCredential(
//           verificationId: verificationId, smsCode: smscode);
//
//       FirebaseUser user =
//           await FirebaseAuth.instance.signInWithCredential(credential);
//
//       print(user);
//       if (user != null) {
//         print(user.uid);
//         DocumentSnapshot doc = await users.document(user.uid).get();
//         // If new user
//         if (!doc.exists) {
//           return Navigator.push(
//               context,
//               PageTransition(
//                   settings: RouteSettings(name: "Profile_pic_page"),
//                   type: PageTransitionType.rightToLeft,
//                   child: ProfilePicPage(
//                     currentUser: currentUser,
//                   )));
//         }
//
//         Navigator.push(
//             context,
//             PageTransition(
//                 settings: RouteSettings(name: "Landing_Page"),
//                 type: PageTransitionType.rightToLeft,
//                 child: BottomNavBar(
//                   sign_in_mode: "RSocial_sign_in",
//                   currentUser: currentUser,
//                   isNewUser: false,
//                 )));
//       }
//     } catch (e) {
//       handleErrorForManualSignIn(e);
//     }
//   }
//
//   // Error handling for sign in method
//   handleErrorForManualSignIn(PlatformException error) {
//     print("Error code ${error.code}");
//     switch (error.code) {
//       case 'ERROR_INVALID_VERIFICATION_CODE':
//         smscode = "";
//         var alertBox = AlertDialogBox(
//           title: "Invalid otp",
//           content: "Please enter the correct otp",
//           actions: <Widget>[
//             FlatButton(
//               child: Text(
//                 "Back",
//                 style: TextStyle(
//                   color: colorButton,
//                   fontFamily: "Lato",
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.pop(
//                   context,
//                 );
//               },
//             ),
//           ],
//         );
//         showDialog(
//             context: (context),
//             builder: (context) {
//               return alertBox;
//             });
//
//         break;
//       default:
//         smscode = "";
//         var alertBox = AlertDialogBox(
//           title: "Error",
//           content: "Some error occurred. Please check your internet connection",
//           actions: <Widget>[
//             FlatButton(
//               child: Text(
//                 "Back",
//                 style: TextStyle(
//                   color: colorButton,
//                   fontFamily: "Lato",
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.pop(
//                   context,
//                 );
//               },
//             ),
//           ],
//         );
//         showDialog(
//             context: (context),
//             builder: (context) {
//               return alertBox;
//             });
//
//         break;
//     }
//   }
//
//   void nextField(String value, FocusNode focusNode) {
//     if (value.length == 1) {
//       focusNode.requestFocus();
//     }
//   }
//
//   void previousField(String value, FocusNode focusNode) {
//     focusNode.requestFocus();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.white,
//         resizeToAvoidBottomInset: false,
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             SizedBox(
//               height: 20,
//             ),
//             Align(
//               alignment: Alignment(-1, 0),
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.arrow_back_ios,
//                     color: colorButton,
//                   ),
//                   onPressed: () {
//                     return Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 40,
//             ),
//             Container(
//               child: Image.asset("images/logo2.png"),
//             ),
//             SizedBox(
//               height: 40,
//             ),
//             Center(
//               child: Text(
//                 "We sent you a code",
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 24,
//                     fontFamily: "Lato"),
//               ),
//             ),
//             SizedBox(
//               height: 12,
//             ),
//             Text(
//               "Enter it below to verify ${currentUser.mobile}",
//               style: TextStyle(
//                   fontFamily: "Lato",
//                   fontWeight: FontWeight.w400,
//                   fontSize: 16),
//             ),
//             SizedBox(
//               height: 32,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 18),
//               child: Row(
//                 children: <Widget>[
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SizedBox(
//                         child: TextFormField(
//                           maxLength: 1,
//                           focusNode: pin1FocusNode,
//                           autofocus: true,
//                           keyboardType: TextInputType.number,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20,
//                           ),
//                           decoration: kOtpInput,
//                           onChanged: (value) {
//                             try {
//                               value.isEmpty
//                                   ? l[0] = -1
//                                   : l[0] = int.parse(value);
//                               setState(() {
//                                 isBlockFull();
//                               });
//                             } catch (e) {
//                               print("Error at 1");
//                             }
//
//                             nextField(value, pin2FocusNode);
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SizedBox(
//                         child: TextFormField(
//                           maxLength: 1,
//                           focusNode: pin2FocusNode,
//                           keyboardType: TextInputType.number,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20,
//                           ),
//                           decoration: kOtpInput,
//                           onChanged: (value) {
//                             try {
//                               value.isEmpty
//                                   ? l[1] = -1
//                                   : l[1] = int.parse(value);
//                               setState(() {
//                                 isBlockFull();
//                               });
//                             } catch (e) {
//                               print("Error at 2");
//                             }
//                             nextField(value, pin3FocusNode);
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SizedBox(
//                         child: TextFormField(
//                           maxLength: 1,
//                           focusNode: pin3FocusNode,
//                           keyboardType: TextInputType.number,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20,
//                           ),
//                           decoration: kOtpInput,
//                           onChanged: (value) {
//                             try {
//                               value.isEmpty
//                                   ? l[2] = -1
//                                   : l[2] = int.parse(value);
//
//                               setState(() {
//                                 isBlockFull();
//                               });
//                             } catch (e) {
//                               print("Error at 3");
//                             }
//                             nextField(value, pin4FocusNode);
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SizedBox(
//                         child: TextFormField(
//                           maxLength: 1,
//                           focusNode: pin4FocusNode,
//                           keyboardType: TextInputType.number,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20,
//                           ),
//                           decoration: kOtpInput,
//                           onChanged: (value) {
//                             try {
//                               value.isEmpty
//                                   ? l[3] = -1
//                                   : l[3] = int.parse(value);
//                               setState(() {
//                                 isBlockFull();
//                               });
//                             } catch (e) {
//                               print("Error at 4");
//                             }
//                             nextField(value, pin5FocusNode);
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SizedBox(
//                         child: TextFormField(
//                           maxLength: 1,
//                           focusNode: pin5FocusNode,
//                           keyboardType: TextInputType.number,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20,
//                           ),
//                           decoration: kOtpInput,
//                           onChanged: (value) {
//                             try {
//                               value.isEmpty
//                                   ? l[4] = -1
//                                   : l[4] = int.parse(value);
//                               setState(() {
//                                 isBlockFull();
//                               });
//                             } catch (e) {
//                               print("Error at 5");
//                             }
//                             nextField(value, pin6FocusNode);
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SizedBox(
//                         child: TextFormField(
//                           maxLength: 1,
//                           focusNode: pin6FocusNode,
//                           keyboardType: TextInputType.number,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20,
//                           ),
//                           decoration: kOtpInput,
//                           onChanged: (value) {
//                             try {
//                               value.isEmpty
//                                   ? l[5] = -1
//                                   : l[5] = int.parse(value);
//                               setState(() {
//                                 isBlockFull();
//                               });
//                             } catch (e) {
//                               print("Error at 6");
//                             }
//                             pin6FocusNode.unfocus();
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 24,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 isAutoVerified
//                     ? Text("Verified, please continue")
//                     : (isAutoRetrievedFailed
//                         ? Text("Unable to auto verify")
//                         : Text("Trying to auto verify")),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 isAutoVerified || isAutoRetrievedFailed
//                     ? SizedBox.shrink()
//                     : Text(
//                         _start < 9 ? "0: 0$_start" : "0:$_start",
//                         style: TextStyle(
//                           color: Colors.blue,
//                         ),
//                       ),
//                 isAutoVerified || isAutoRetrievedFailed
//                     ? SizedBox.shrink()
//                     : SizedBox(
//                         width: 10,
//                       ),
//                 Text(
//                   "Resend OTP",
//                   style: TextStyle(
//                       fontFamily: "Lato",
//                       fontWeight: FontWeight.bold,
//                       color: colorButton,
//                       fontSize: 15),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 32,
//             ),
//             RoundedButton(
//               text: "Continue",
//               elevation: 0,
//               color:
//                   isAutoVerified || isBlockFull() ? colorButton : Colors.grey,
//               onPressed: () async {
//                 print("continue");
//
//                 if (isAutoVerified || isBlockFull()) {
//                   for (int i = 0; i < otpLength; i++) {
//                     smscode += l[i].toString();
//                   }
//                   print("SMS:: $smscode");
//                   FirebaseUser user = await FirebaseAuth.instance.currentUser();
//                   if (user != null) {
//                     DocumentSnapshot doc = await users.document(user.uid).get();
//                     if (!doc.exists) {
//                       return Navigator.pushReplacement(
//                           context,
//                           PageTransition(
//                               type: PageTransitionType.rightToLeft,
//                               settings: RouteSettings(name: "Landing_Page"),
//                               child: ProfilePicPage(currentUser: currentUser,)
//                           ));
//                     }
//
//
//
//                     return Navigator.pushReplacement(
//                         context,
//                         PageTransition(
//                             type: PageTransitionType.rightToLeft,
//                             child: BottomNavBar(
//                               sign_in_mode: "RSocial_sign_in",
//                               currentUser: currentUser,
//                               isNewUser: false,
//                             )));
//                   } else {
//                     signInManually();
//                   }
//                 } else {
//                   print("Please enter otp");
//                 }
//               },
//             )
//           ],
//         ));
//   }
// }
//
// class CountDownTimer extends StatefulWidget {
//   @override
//   _CountDownTimerState createState() => _CountDownTimerState();
// }
//
// class _CountDownTimerState extends State<CountDownTimer> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
