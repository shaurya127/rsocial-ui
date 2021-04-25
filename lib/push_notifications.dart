import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rsocial2/Screens/display_post.dart';
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
      _fcm.requestPermission();
    }

    String token = await _fcm.getToken();
    print("FirebaseMessaging token: $token");
    _fcm.onTokenRefresh.listen((token) async {
      auth.FirebaseAuth _authInstance = auth.FirebaseAuth.instance;
      auth.User user = _authInstance.currentUser;
      print(user);

      var id;
      if (user != null) {
        try {
          var authToken = await user.getIdToken();
          DocumentSnapshot doc = await users.doc(user.uid).get();
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
          await users.doc(user.uid).update({"token": token});
        } catch (e) {}
      }
    });
    //When app is terminated
    RemoteMessage remoteMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage != null) {
      Map<String, dynamic> message = remoteMessage.data;
      print("onMessage: $message");
      if (Platform.isAndroid || Platform.isIOS) {
        String data = message["uuid"];
        PushNotificationMessage notification = PushNotificationMessage(
          title: remoteMessage.notification.title,
          body: remoteMessage.notification.body,
          notificationType: data.startsWith("post")
              ? NotificationType.Post
              : NotificationType.Profile,
          id: data.startsWith("post")
              ? data.substring(4, data.length)
              : data.substring(7, data.length),
        );
        FlutterAppBadger.removeBadge();
        await Future.delayed(Duration(seconds: 5));
        if (notification.notificationType == NotificationType.Post) {
          navigatorKey.currentState.push(MaterialPageRoute(builder: (ctx) {
            return DisplayPost(
              postId: notification.id,
            );
          }));
        } else {
          navigatorKey.currentState.push(MaterialPageRoute(builder: (ctx) {
            return Profile(
                currentUser: curUser ?? savedUser,
                user: User(id: notification.id));
          }));
        }
      }
    }
    //Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      Map<String, dynamic> message = remoteMessage.data;
      print("onMessage: $message");

      if (Platform.isAndroid || Platform.isIOS) {
        String data = message["uuid"];
        PushNotificationMessage notification = PushNotificationMessage(
          title: remoteMessage.notification.title,
          body: remoteMessage.notification.body,
          notificationType: data.startsWith("post")
              ? NotificationType.Post
              : NotificationType.Profile,
          id: data.startsWith("post")
              ? data.substring(4, data.length)
              : data.substring(7, data.length),
        );

        //Here you can add the count when you get a notification you can increase the number by one
        FlutterAppBadger.updateBadgeCount(1);
        // UI
        int count = 0;
        showSimpleNotification(
          GestureDetector(
            onTap: () {
              count++;
              if (count > 1) {
                return;
              }
              if (notification.notificationType == NotificationType.Post) {
                navigatorKey.currentState
                    .push(MaterialPageRoute(builder: (ctx) {
                  return DisplayPost(
                    postId: notification.id,
                  );
                }));
              } else {
                navigatorKey.currentState
                    .push(MaterialPageRoute(builder: (ctx) {
                  return Profile(
                    currentUser: curUser ?? savedUser,
                    user: User(id: notification.id),
                  );
                }));
              }
            },
            child: Container(
                child: Text(
              notification.title,
              style: TextStyle(
                  fontFamily: 'Lato',
                  color: colorPrimaryBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            )),
          ),
          position: NotificationPosition.top,
          background: Colors.white,
          autoDismiss: true,
          duration: Duration(seconds: 5),
          leading: Container(
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0, top: 8, bottom: 8),
              child: SvgPicture.asset(
                "images/rsocial-logo2.svg",
                height: 25,
              ),
            ),
          ),
          subtitle: Text(
            notification.body,
            style: TextStyle(
              fontFamily: 'Lato',
              color: colorPrimaryBlue,
              fontSize: 15,
            ),
          ),
        );
      }
    });
    //Handle notifications when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      Map<String, dynamic> message = remoteMessage.data;
      print("onMessage: $message");

      if (Platform.isAndroid || Platform.isIOS) {
        String data = message["uuid"];
        PushNotificationMessage notification = PushNotificationMessage(
          title: remoteMessage.notification.title,
          body: remoteMessage.notification.body,
          notificationType: data.startsWith("post")
              ? NotificationType.Post
              : NotificationType.Profile,
          id: data.startsWith("post")
              ? data.substring(4, data.length)
              : data.substring(7, data.length),
        );

        if (notification.notificationType == NotificationType.Post) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(navigatorKey.currentContext).push(MaterialPageRoute(
              builder: (context) => DisplayPost(
                postId: notification.id,
              ),
            ));
          });
        } else {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(navigatorKey.currentContext).push(MaterialPageRoute(
                builder: (context) => Profile(
                      currentUser: curUser ?? savedUser,
                      user: User(id: notification.id),
                    )));
          });
        }
      }
    });

    // _fcm.configure(
    //   //App in foreground
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");

    //     if (Platform.isAndroid || Platform.isIOS) {
    //       String data = message["data"]["uuid"];
    //       PushNotificationMessage notification = PushNotificationMessage(
    //         title: message['notification']['title'],
    //         body: message['notification']['body'],
    //         notificationType: data.startsWith("post")
    //             ? NotificationType.Post
    //             : NotificationType.Profile,
    //         id: data.startsWith("post")
    //             ? data.substring(4, data.length)
    //             : data.substring(7, data.length),
    //       );

    //       //Here you can add the count when you get a notification you can increase the number by one
    //       FlutterAppBadger.updateBadgeCount(1);
    //       // UI
    //       int count = 0;
    //       showSimpleNotification(
    //         GestureDetector(
    //           onTap: () {
    //             count++;
    //             if (count > 1) {
    //               return;
    //             }
    //             if (notification.notificationType == NotificationType.Post) {
    //               navigatorKey.currentState
    //                   .push(MaterialPageRoute(builder: (ctx) {
    //                 return DisplayPost(
    //                   postId: notification.id,
    //                 );
    //               }));
    //             } else {
    //               navigatorKey.currentState
    //                   .push(MaterialPageRoute(builder: (ctx) {
    //                 return Profile(
    //                   currentUser: curUser ?? savedUser,
    //                   user: User(id: notification.id),
    //                 );
    //               }));
    //             }
    //           },
    //           child: Container(
    //               child: Text(
    //             notification.title,
    //             style: TextStyle(
    //                 fontFamily: 'Lato',
    //                 color: colorPrimaryBlue,
    //                 fontSize: 18,
    //                 fontWeight: FontWeight.bold),
    //           )),
    //         ),
    //         position: NotificationPosition.top,
    //         background: Colors.white,
    //         autoDismiss: true,
    //         duration: Duration(seconds: 5),
    //         leading: Container(
    //           child: Padding(
    //             padding: const EdgeInsets.only(right: 18.0, top: 8, bottom: 8),
    //             child: SvgPicture.asset(
    //               "images/rsocial-logo2.svg",
    //               height: 25,
    //             ),
    //           ),
    //         ),
    //         subtitle: Text(
    //           notification.body,
    //           style: TextStyle(
    //             fontFamily: 'Lato',
    //             color: colorPrimaryBlue,
    //             fontSize: 15,
    //           ),
    //         ),
    //       );
    //     }
    //   },
    //   //App Terminated
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //     if (Platform.isAndroid || Platform.isIOS) {
    //       String data = message["data"]["uuid"];
    //       PushNotificationMessage notification = PushNotificationMessage(
    //         title: message['notification']['title'],
    //         body: message['notification']['body'],
    //         notificationType: data.startsWith("post")
    //             ? NotificationType.Post
    //             : NotificationType.Profile,
    //         id: data.startsWith("post")
    //             ? data.substring(4, data.length)
    //             : data.substring(7, data.length),
    //       );
    //       //Here you can remove the badge you created when it's launched
    //       FlutterAppBadger.removeBadge();
    //       //navigatorKey.currentState.
    //       await Future.delayed(Duration(seconds: 5));
    //       // Navigate to a particular page
    //       // SchedulerBinding.instance.addPostFrameCallback((_) {
    //       //   Navigator.of(navigatorKey.currentContext).push(MaterialPageRoute(
    //       //     builder: (context) => DisplayPost(
    //       //       postId: notification.id,
    //       //     ),
    //       //   ));
    //       // });
    //       if (notification.notificationType == NotificationType.Post) {
    //         navigatorKey.currentState.push(MaterialPageRoute(builder: (ctx) {
    //           return DisplayPost(
    //             postId: notification.id,
    //           );
    //         }));
    //       } else {
    //         navigatorKey.currentState.push(MaterialPageRoute(builder: (ctx) {
    //           return Profile(
    //               currentUser: curUser ?? savedUser,
    //               user: User(id: notification.id));
    //         }));
    //       }
    //     }
    //   },
    //   //App in background
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");

    //     if (Platform.isAndroid || Platform.isIOS) {
    //       String data = message["data"]["uuid"];
    //       PushNotificationMessage notification = PushNotificationMessage(
    //         title: message['notification']['title'],
    //         body: message['notification']['body'],
    //         notificationType: data.startsWith("post")
    //             ? NotificationType.Post
    //             : NotificationType.Profile,
    //         id: data.startsWith("post")
    //             ? data.substring(4, data.length)
    //             : data.substring(7, data.length),
    //       );

    //       // if (notification.notificationType == "friendAccept" ||
    //       //     notification.notificationType == "friendRequest") {
    //       if (notification.notificationType == NotificationType.Post) {
    //         SchedulerBinding.instance.addPostFrameCallback((_) {
    //           Navigator.of(navigatorKey.currentContext).push(MaterialPageRoute(
    //             builder: (context) => DisplayPost(
    //               postId: notification.id,
    //             ),
    //           ));
    //         });
    //       } else {
    //         SchedulerBinding.instance.addPostFrameCallback((_) {
    //           Navigator.of(navigatorKey.currentContext).push(MaterialPageRoute(
    //               builder: (context) => Profile(
    //                     currentUser: curUser ?? savedUser,
    //                     user: User(id: notification.id),
    //                   )));
    //         });
    //       }

    //       // FlutterAppBadger.removeBadge();
    //       // await Future.delayed(Duration(seconds: 2));

    //       // navigatorKey.currentState.push(MaterialPageRoute(builder: (ctx) {
    //       //   return DisplayPost(
    //       //     postId: notification.id,
    //       //   );
    //       // }));
    //       //   final jsonUser = jsonDecode(message['data']['user']);
    //       //   var body = jsonUser['body'];
    //       //   var body1 = jsonDecode(body);
    //       //   var msg = body1['message'];
    //       //   User user = User.fromJson(msg);
    //       //   print(user.fname);

    //       //   if (user != null) {}
    //       //}
    //     }
    //   },
    // );
  }
}
