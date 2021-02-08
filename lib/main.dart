import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rsocial2/Screens/userInfoGoogle.dart';
import 'package:rsocial2/auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:rsocial2/constants.dart';
import 'package:rsocial2/user.dart';
import 'push_notifications.dart';

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
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    // Initialising push notification service
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
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
            debugShowCheckedModeBanner: false,
            navigatorObservers: <NavigatorObserver>[observer],
            theme: ThemeData(
              //visualDensity: VisualDensity.adaptivePlatformDensity,
              //brightness: Brightness.light,
              primaryColor: colorPrimaryBlue,
            ),
            home: AuthScreen(analytics: analytics, observer: observer)),
      ),
    );
  }
}
