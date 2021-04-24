import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/helper.dart';
import 'package:rsocial2/model/notification.dart';
import 'package:rsocial2/model/user.dart' as user;

import '../contants/constants.dart';
import 'package:rsocial2/Widgets/Notification_tile.dart';

import 'bottom_nav_bar.dart';

class NotificationPage extends StatefulWidget {
  user.User curUser;
  NotificationPage({this.curUser});
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  List<NotificationModel> readNotification = [];
  List<NotificationModel> unreadNotification = [];
  List<NotificationModel> allNotification = [];
  //TabController _tabController2;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getNotifications();
    //_tabController2 = new TabController(vsync: this, length: 2);
  }

  getNotifications() async {
    setState(() {
      isLoading = true;
    });

    var response;
    try {
      var user = FirebaseAuth.instance.currentUser;
      var token = await user.getIdToken();

      response = await postFunc(
          url: userEndPoint + "getnotification",
          token: token,
          body: jsonEncode({
            //"id": "bb6c5841ba0d4f5597506ff3b61b91d3"
            //"id": "bb6c5841ba0d4f5597506ff3b61b91d3",
            "id": widget.curUser.id,
          }));

      print("Inside get notification");
      if (response == null) {
        print("response is null");
      }
    } catch (e) {
      isLoading = false;
    }
    print("NOTIFICATION:${response.body}");
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];

      print(responseMessage['True']);
      if (responseMessage['True'] != null) {
        for (int i = 0; i < responseMessage['True'].length; i++) {
          readNotification
              .add(NotificationModel.fromJson(responseMessage['True'][i]));
          print(readNotification[i].text);
        }
      }
      if (responseMessage['False'] != null) {
        for (int i = 0; i < responseMessage['False'].length; i++) {
          unreadNotification
              .add(NotificationModel.fromJson(responseMessage['False'][i]));
        }
      }
      print(readNotification.length);

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // _tabController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: TabBar(
    //     indicatorColor: colorPrimaryBlue,
    //     indicatorWeight: 3,
    //     labelColor: colorPrimaryBlue,
    //     labelStyle: TextStyle(fontSize: 16, fontFamily: 'Lato'),
    //     unselectedLabelColor: colorGreyTint,
    //     unselectedLabelStyle: TextStyle(fontSize: 16, fontFamily: 'Lato'),
    //     controller: _tabController2,
    //     tabs: <Tab>[
    //       Tab(
    //         text: "Platform",
    //       ),
    //       Tab(
    //         text: "User",
    //       ),
    //     ],
    //   ),
    //   body: TabBarView(
    //     children: <Widget>[
    //       Container(
    //         color: Colors.grey.withOpacity(0.1),
    //      child: Padding(
    //        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    //        child: ListView(
    //         children: <Widget>[
    //           NotificationTile(name: "aisha",notification: " created a wage story",),
    //           NotificationTile(name: "aisha",notification: " rgaerg",),
    //           NotificationTile(name: "aisha",notification: " agfawegf",),
    //           NotificationTile(name: "aisha",notification: "qga3g34",),
    //         ],
    //        ),
    //      ),
    //       ),
    //       Container(
    //         color: Colors.redAccent.withOpacity(0.1),
    //       ),
    //     ],
    //     controller: _tabController2,
    //   ),
    // );
    return Scaffold(
        body: isLoading
            ? LinearProgressIndicator()
            : readNotification.length != 0 || unreadNotification.length != 0
                ? buildNotificationList()
                : Container(
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Nothing to see here... yet.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 27,
                              fontFamily: "Lato"),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              "This where all the actions about your RSocial happens. You'll like here.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 17,
                                  color: colorUnselectedBottomNav),
                            ),
                          ),
                        )
                      ],
                    )),
                  ));
  }

  buildNotificationList() {
    allNotification = [];
    List<NotificationTile> tiles = [];
    allNotification.addAll(unreadNotification);
    allNotification.addAll(readNotification);
    allNotification.sort((noti1, noti2) {
      return noti2.dateTime.compareTo(noti1.dateTime);
    });
    for (int i = 0; i < allNotification.length; i++) {
      print(allNotification[i].dateTime.toLocal());
      tiles.add(NotificationTile(
        read: allNotification[i].readFlag,
        name: allNotification[i].text,
        senderId: allNotification[i].senderId,
        notificationId: allNotification[i].id,
        datetime: allNotification[i].dateTime,
      ));
    }

    return ListView(children: tiles);
  }
}
