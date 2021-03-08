import 'dart:ui';

import 'package:flutter/material.dart';

class NotificationTile extends StatefulWidget {
  final String name;
  final String notification;
  NotificationTile({this.name,this.notification});

  @override
  _NotificationTileState createState() => _NotificationTileState();
}


class _NotificationTileState extends State<NotificationTile> {

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  leading: CircleAvatar(
                    backgroundImage:  AssetImage("images/avatar.jpg"),
                  ),
                  title:Row(children: <Widget>[
                    Text(
                      widget.name ,
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),

                    Text(
                      widget.notification,
                      style: TextStyle(
                        fontFamily: "Lato",

                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),

                  ],),
                  subtitle: Text("1 hour"),
                  trailing: Icon(Icons.more_horiz)
                ),
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
    );
  }
}
