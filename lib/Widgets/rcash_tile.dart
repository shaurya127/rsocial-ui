import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';

import '../constants.dart';
import '../user.dart';

class RcashTile extends StatefulWidget {
  User user;
  RcashTile({this.user});

  @override
  _RcashTileState createState() => _RcashTileState();
}

class _RcashTileState extends State<RcashTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  // leading: GestureDetector(
                  //   // onTap: () =>
                  //   // showProfile(
                  //   // context, widget.user, widget.user.photoUrl, curUser),
                  //   child: CircleAvatar(
                  //     backgroundImage: widget.user.photoUrl != ""
                  //         ? NetworkImage(
                  //             widget.user.photoUrl,
                  //           )
                  //         : AssetImage("images/avatar.jpg"),
                  //   ),
                  // ),

                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          child: Container(
                            height: 39,
                            width: 39,
                            //  color: Colors.red,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                image: DecorationImage(
                                    image: curUser.photoUrl != ""
                                        ? NetworkImage(curUser.photoUrl)
                                        : AssetImage("images/avatar.jpg"),
                                    fit: BoxFit.cover),
                                shape: BoxShape.circle),
                          ),
                          onTap: () {
                            // if (canShowProfile)
                            //   showProfile(context, curUser, curUser.photoUrl);
                          },
                        ),
                        Positioned(
                          // right: 0,
                          // bottom: 27,
                          left: 0,
                          top: 27,
                          child: Container(
                            height: 12,
                            // width: 40,
                            decoration: BoxDecoration(
                                border: Border.all(color: colorProfitPositive),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                //shape: BoxShape.circle,
                                color: colorProfitPositive),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Center(
                                  child: Text(
                                      widget.user.socialStanding.toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 7,
                                          fontWeight: FontWeight.bold))
                                  // FaIcon(
                                  //   FontAwesomeIcons.bars,
                                  //   color: colorGreenTint,
                                  //   size: 15,
                                  // ),
                                  ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  title: Text(
                    widget.user.id == curUser.id
                        ? "You"
                        : "${widget.user.fname} ${widget.user.lname}",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: nameCol,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Investment story, ",
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12,
                              color: colorGreyTint),
                        ),
                        Text(
                          "10 october",
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 9,
                              color: postIcons),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                "+3000",
                style: TextStyle(
                    color: colorProfitPositive,
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )
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
