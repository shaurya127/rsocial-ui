
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:page_transition/page_transition.dart';
// import 'file:///D:/Flutter/rsocial2/lib/Widgets/RoundedButton.dart';
// import 'file:///D:/Flutter/rsocial2/lib/Screens/bottom_nav_bar.dart';
// import 'file:///D:/Flutter/rsocial2/lib/Screens/profile_pic.dart';
//
// import '../constants.dart';
//
// class PasswordPage extends StatefulWidget {
//   @override
//   _PasswordPageState createState() => _PasswordPageState();
// }
//
// class _PasswordPageState extends State<PasswordPage> {
//   bool obscure = true;
//   bool select = false;
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
//                 "You'll need a password",
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
//               "Make sure it's 8 character or more.",
//               style: TextStyle(
//                   fontFamily: "Lato",
//                   fontWeight: FontWeight.w400,
//                   fontSize: 16),
//             ),
//             SizedBox(
//               height: 24,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: TextFormField(
//                   obscureText: obscure,
//                   decoration: kInputField.copyWith(
//                       suffixIcon: IconButton(
//                         onPressed: () {
//                           setState(() {
//                             obscure = !obscure;
//                           });
//                         },
//                         icon: obscure
//                             ? Icon(
//                                 Icons.remove_red_eye,
//                                 size: 25,
//                                 color: Colors.blue,
//                               )
//                             : FaIcon(
//                                 FontAwesomeIcons.eyeSlash,
//                                 size: 22,
//                                 color: Colors.blue,
//                               ),
//                       ),
//                       hintText: "Password",
//                       hintStyle: TextStyle(
//                           color: Color(0xff263238).withOpacity(0.5),
//                           fontSize: 16,
//                           fontFamily: "Lato",
//                           fontWeight: FontWeight.w300))
//
//                   // InputDecoration(
//                   //     hintText: "First name",
//                   //     hintStyle: TextStyle(
//                   //         color: colorHintText.withOpacity(0.5),
//                   //         fontFamily: "Lato",
//                   //         fontWeight: FontWeight.w300)),
//                   ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: TextFormField(
//                   decoration: kInputField.copyWith(
//                       hintText: "Retype Password",
//                       hintStyle: TextStyle(
//                           color: Color(0xff263238).withOpacity(0.5),
//                           fontSize: 16,
//                           fontFamily: "Lato",
//                           fontWeight: FontWeight.w300))
//
//                   // InputDecoration(
//                   //     hintText: "First name",
//                   //     hintStyle: TextStyle(
//                   //         color: colorHintText.withOpacity(0.5),
//                   //         fontFamily: "Lato",
//                   //         fontWeight: FontWeight.w300)),
//                   ),
//             ),
//             SizedBox(
//               height: 32,
//             ),
//             RoundedButton(
//               text: "Continue",
//               elevation: 0,
//               onPressed: () {
//                 return Navigator.push(
//                     context,
//                     PageTransition(
//                         type: PageTransitionType.rightToLeft,
//                         child: ProfilePicPage()));
//               },
//             )
//           ],
//         ));
//   }
// }

