import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/model/user.dart';

import '../helper.dart';

Map<String, bool> notificationRead = new Map();

class NotificationTile extends StatefulWidget {
  final String name;
  final String senderId;
  final String notificationId;
  final DateTime datetime;
  bool read;

  NotificationTile({
    this.name,
    this.senderId,
    this.notificationId,
    this.read,
    this.datetime,
  });

  @override
  _NotificationTileState createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  showProfile(BuildContext context, User user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          currentUser: curUser,
          user: user,
        ),
      ),
    );
    setState(() {});
  }

  String getTimeSinceNotification() {
    Duration duration = DateTime.now().difference(widget.datetime);
    if (duration.inDays == 1) {
      return "${duration.inDays} day";
    } else if (duration.inDays > 1) {
      return "${duration.inDays} days";
    } else if (duration.inHours == 1) {
      return "${duration.inHours} hour";
    } else if (duration.inHours > 1) {
      return "${duration.inDays} hours";
    } else {
      return "Now";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (notificationRead.containsKey(widget.notificationId)) {
      widget.read = notificationRead[widget.notificationId];
    }
    return GestureDetector(
      onTap: () async {
        showProfile(context, User(id: widget.senderId));
        await setNotification();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(6),
                    dense: true,
                    //contentPadding: EdgeInsets.all(-10)
                    // leading: CircleAvatar(
                    //   backgroundImage: AssetImage("images/avatar.jpg"),
                    // ),
                    tileColor:
                        widget.read ? Colors.white : Colors.lightBlue[50],
                    title: Text(
                      widget.name,
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontWeight:
                            widget.read ? FontWeight.normal : FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(getTimeSinceNotification()),
                    // trailing: Text(
                    //   widget.read == false ? "unread" : "read",
                    //   style: TextStyle(
                    //       fontFamily: 'Lato',
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.w200,
                    //       color: colorUnselectedBottomNav),
                    // )
                  ),
                ),
              ],
            ),
            Divider(
              height: 1,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  setNotification() async {
    print("set notification called");
    notificationRead[widget.notificationId] = true;

    var response;
    try {
      var user = await FirebaseAuth.instance.currentUser();
      var token = await user.getIdToken();

      response = await postFunc(
          url: userEndPoint + "setnotification",
          token: token,
          body: jsonEncode({
            "id": user.uid,
            "notificationUid": [widget.notificationId]
          }));

      if (response == null) {}
    } catch (e) {}
    print("Not");
    print(widget.notificationId);
    var responseMessage =
        jsonDecode((jsonDecode(response.body))['body'])['message'];
    print(responseMessage);
    print("setNotification completed");
  }
}
