import 'dart:async';
import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Screens/bio_page.dart';
import 'package:rsocial2/Screens/profile_pic.dart';
import 'package:rsocial2/Screens/userInfoGoogle.dart';
import 'package:rsocial2/auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/bottom_nav_bar.dart';
import 'Screens/create_account_page.dart';
import 'Screens/login_page.dart';

import 'push_notifications.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: colorStatusBar, // status bar color
  ));
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");

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
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    // Initialising push notification service
    final pushNotificationService =
        PushNotificationService(MyApp._firebaseMessaging, context);
    pushNotificationService.initialise();

    // The app will stay in potrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // This is to unfocus text fields when clicked on screen outside of the text field
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: OverlaySupport(
        child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            navigatorObservers: <NavigatorObserver>[MyApp.observer],
            theme: ThemeData(
              //visualDensity: VisualDensity.adaptivePlatformDensity,
              //brightness: Brightness.light,
              primaryColor: colorPrimaryBlue,
            ),
            home: AnimatedSplashScreen(
              splashIconSize: double.infinity,
              duration: 300,
              animationDuration: Duration(milliseconds: 300),
              splash: Image.asset(
                "images/splashScreenAndroid.gif",
                fit: BoxFit.cover,
              ),
              backgroundColor: Colors.white,
              nextScreen: AuthScreen(analytics: analytics, observer: observer),
              pageTransitionType: PageTransitionType.fade,
            )),
      ),
    );
  }
}
