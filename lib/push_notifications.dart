import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/helper.dart';
import 'package:rsocial2/model/push_notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Screens/login_page.dart';
import 'model/user.dart';

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
    _fcm.onTokenRefresh.listen((token) async {
      FirebaseAuth _authInstance = FirebaseAuth.instance;
      FirebaseUser user = await _authInstance.currentUser();
      var authToken = await user.getIdToken();
      var id;
      if (user != null) {
        try {
          DocumentSnapshot doc = await users.document(user.uid).get();
          if (!doc.exists) {
            return;
          } else {
            if (doc['id'] != null) {
              id = doc['id'];
            } else
              return;
          }
          // Token update in backend
          var response = await postFunc(
              url: userEndPoint + "setfcmtoken",
              token: authToken,
              body: jsonEncode({"id": id, "fcmToken": token}));

          print("Response in set fcm token triggered");

          // Token update in firebase
          await users.document(user.uid).updateData({"token": token});
        } catch (e) {}
      }
    });
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        if (Platform.isAndroid) {
          PushNotificationMessage notification = PushNotificationMessage(
              title: message['notification']['title'],
              body: message['notification']['body'],
              notificationType: message['data']['notification_type']);

          //Here you can add the count when you get a notification you can increase the number by one
          FlutterAppBadger.updateBadgeCount(1);
          // UI
          showSimpleNotification(
              Container(
                  child: Text(
                notification.title,
                style: TextStyle(
                    fontFamily: 'Lato',
                    color: colorPrimaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
              position: NotificationPosition.top,
              background: Colors.white,
              autoDismiss: false,
              slideDismiss: true,
              leading: Container(
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 18.0, top: 8, bottom: 8),
                  child: SvgPicture.asset(
                    "images/rsocial-logo2.svg",
                    height: 25,
                  ),
                ),
              ),
              subtitle: Text(notification.body,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    color: colorPrimaryBlue,
                    fontSize: 15,
                  )));
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

          // // Navigate to a particular page
          // navigatorKey.currentState.push(MaterialPageRoute(
          //   builder: (_) => Profile(
          //     currentUser: curUser,
          //     user: curUser,
          //   ),
          // ));
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");

        if (Platform.isAndroid) {
          PushNotificationMessage notification = PushNotificationMessage(
              title: message['notification']['title'],
              body: message['notification']['body'],
              notificationType: message['data']['notification_type']);

          if (notification.notificationType == "friendAccept" ||
              notification.notificationType == "friendRequest") {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(navigatorKey.currentContext).push(MaterialPageRoute(
                builder: (context) => Search_Page(),
              ));
            });

            final jsonUser = jsonDecode(message['data']['user']);
            var body = jsonUser['body'];
            var body1 = jsonDecode(body);
            var msg = body1['message'];
            User user = User.fromJson(msg);
            print(user.fname);

            if (user != null) {}
          }
        }
      },
    );
  }
}
