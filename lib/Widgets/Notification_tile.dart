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
  bool read;

  NotificationTile({this.name, this.senderId, this.notificationId,this.read});

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

  @override
  Widget build(BuildContext context) {

    if(notificationRead.containsKey(widget.notificationId))
      {
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
                      //contentPadding: EdgeInsets.all(4),
                      dense: true,
                      //contentPadding: EdgeInsets.all(-10)
                      // leading: CircleAvatar(
                      //   backgroundImage: AssetImage("images/avatar.jpg"),
                      // ),
                      title: Text(
                        widget.name,
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontWeight: widget.read?FontWeight.normal:FontWeight.bold,
                          fontSize: 15,
                          fontStyle: widget.read?FontStyle.italic:FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text("1 hour"),
                      trailing: Text(
                        widget.read==false?"unread":"read",
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 12,
                            fontWeight: FontWeight.w200,
                            color: colorUnselectedBottomNav),
                      )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Divider(
                height: 1,
                color: Colors.grey,
              ),
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
            "id": "bb6c5841ba0d4f5597506ff3b61b91d3",
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
