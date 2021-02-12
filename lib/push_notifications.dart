import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rsocial2/push_notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rsocial2/user.dart';

import 'Screens/bottom_nav_bar.dart';
import 'Screens/profile_page.dart';
import 'main.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm;
  final BuildContext context;
  PushNotificationService(this._fcm, this.context);

  Future initialise() async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    String token = await _fcm.getToken();
    print("FirebaseMessaging token: $token");

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        if (Platform.isAndroid) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: message['notification']['title'],
            body: message['notification']['body'],
          );

          //Here you can add the count when you get a notification you can increase the number by one
          FlutterAppBadger.updateBadgeCount(1);
          // UI
          showSimpleNotification(Container(child: Text(notification.body)),
              position: NotificationPosition.top, background: Colors.black);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        if (Platform.isAndroid) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: message['notification']['title'],
            body: message['notification']['body'],
          );

          //Here you can remove the badge you created when it's launched
          FlutterAppBadger.removeBadge();

          // Navigate to a particular page
          navigatorKey.currentState.push(MaterialPageRoute(
            builder: (_) => Profile(
              currentUser: curUser,
              user: curUser,
            ),
          ));
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");

        if (Platform.isAndroid) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: message['notification']['title'],
            body: message['notification']['body'],
          );

          // final jsonUser = jsonDecode(message['body']['user']);
          // var body = jsonUser['body'];
          // var body1 = jsonDecode(body);
          // var msg = body1['message'];
          // var user = User.fromJson(msg);

          // Navigate to a particular page
          navigatorKey.currentState.push(MaterialPageRoute(
            builder: (_) => Profile(
              currentUser: curUser,
              user: curUser,
            ),
          ));
        }
      },
    );
  }
}
