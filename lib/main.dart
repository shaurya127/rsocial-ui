import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/userInfoGoogle.dart';
import 'package:rsocial2/auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:rsocial2/constants.dart';
import 'package:rsocial2/user.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: colorStatusBar, // status bar color
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  // Future<String> _getId() async {
  //   var deviceInfo = DeviceInfoPlugin();
  //   // if (Platform.isIOS) {
  //   //   // import 'dart:io'
  //   //   var iosDeviceInfo = await deviceInfo.iosInfo;
  //   //   return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  //   // } else {
  //   var androidDeviceInfo = await deviceInfo.androidInfo;
  //   return androidDeviceInfo.id; // unique ID on Android
  //   // }
  // }

  // void printId() async {
  //   print(await FirebaseMessaging().getToken());
  // }

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    //printId();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null)
          {
            FocusManager.instance.primaryFocus.unfocus();
          }
      },
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: <NavigatorObserver>[observer],
          theme: ThemeData(
            //visualDensity: VisualDensity.adaptivePlatformDensity,
            //brightness: Brightness.light,
            primaryColor: colorPrimaryBlue,
          ),
          home: AuthScreen(analytics: analytics, observer: observer)),
    );
  }
}
