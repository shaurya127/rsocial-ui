import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rsocial2/Screens/profile_page.dart';

import '../constants.dart';
import '../user.dart';

class UserTile extends StatefulWidget {
  User user;
  User curUser;

  UserTile({this.user, this.curUser});

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  showProfile(BuildContext context, User user, String photourl, User curUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          currentUser: widget.curUser,
          photoUrl: widget.user.photoUrl,
          user: widget.user,
        ),
      ),
    );
  }

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
                  leading: GestureDetector(
                    onTap: () => showProfile(context, widget.user,
                        widget.user.photoUrl, widget.curUser),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.user.photoUrl,
                      ),
                    ),
                  ),
                  title: Text(
                    "${widget.user.fname} ${widget.user.lname}",
                    style: TextStyle(
                      fontFamily: "Lato",
                      //fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: nameCol,
                    ),
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      Container(
                        height: 15,
                        width: 15,
                        padding: EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          "images/group2834.svg",
                          color: nameCol.withOpacity(0.4),
                        ),
                      ),
                      Text(
                        "${widget.user.lollarAmount}",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 1,
                          height: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        height: 15,
                        width: 15,
                        padding: EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          "images/high-five.svg",
                          color: nameCol.withOpacity(0.4),
                        ),
                      ),
                      Text(
                        "${widget.user.connection.length}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              // Row(
              //   children: <Widget>[
              //     (widget.request && widget.accepted == false)
              //         ? Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 5),
              //       child: GestureDetector(
              //         onTap: () {},
              //         child: Container(
              //           padding: EdgeInsets.symmetric(
              //               vertical: 8, horizontal: 8),
              //           child: Text(
              //             "Reject",
              //             style: TextStyle(
              //               fontFamily: "Lato",
              //               fontSize: 14,
              //               color: Orientation == 'search'
              //                   ? Colors.white
              //                   : Theme.of(context).primaryColor,
              //             ),
              //           ),
              //           decoration: BoxDecoration(
              //               color: Orientation == 'search'
              //                   ? Theme.of(context).primaryColor
              //                   : Colors.white,
              //               borderRadius: BorderRadius.circular(10),
              //               border: Border.all(
              //                   width: 1,
              //                   color: Theme.of(context).primaryColor)),
              //         ),
              //       ),
              //     )
              //         : Container(),
              //     widget.accepted == false
              //         ? Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 5),
              //       child: GestureDetector(
              //         onTap: () {
              //           if (widget.text == 'Accept')
              //             acceptConnection(widget.user.id);
              //           else if (widget.text == 'Add')
              //             addConnection(widget.user.id);
              //           else if (widget.text == 'Remove')
              //             removeConnection(widget.user.id);
              //           //addConnection(widget.user.id);
              //         },
              //         child: Container(
              //           padding: EdgeInsets.symmetric(
              //               vertical: 8, horizontal: 8),
              //           child: Text(
              //             widget.text,
              //             style: TextStyle(
              //                 fontFamily: "Lato",
              //                 fontSize: 14,
              //                 color: Colors.white),
              //           ),
              //           decoration: BoxDecoration(
              //               color: Theme.of(context).primaryColor,
              //               borderRadius: BorderRadius.circular(10),
              //               border: Border.all(
              //                   width: 1,
              //                   color: Theme.of(context).primaryColor)),
              //         ),
              //       ),
              //     )
              //         : Icon(
              //       Icons.check,
              //       size: 24,
              //       color: colorPrimaryBlue,
              //     )
              //   ],
              // )
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
