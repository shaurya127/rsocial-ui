import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rsocial2/Screens/all_connections.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/profile_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rsocial2/Screens/refer_and_earn.dart';
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/auth.dart';
import '../authLogic.dart';
import '../constants.dart';
import '../user.dart';
import 'create_account_page.dart';
import '../Widgets/nav_drawer_tile.dart';

class Nav_Drawer extends StatefulWidget {
  User currentUser;
  String photoUrl;

  Nav_Drawer({this.currentUser, this.photoUrl});

  @override
  _Nav_DrawerState createState() => _Nav_DrawerState();
}

class _Nav_DrawerState extends State<Nav_Drawer> {
  @override
  Widget build(BuildContext context) {
    //print(widget.currentUser);
    return SafeArea(
      child: Drawer(
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          //color: Color(0xff409FC6).withOpacity(0.5),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 2),
            child: ListView(
              children: <Widget>[
                Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: SvgPicture.asset(
                    "images/rsocial-text.svg",
                  ),
                  // decoration: BoxDecoration(
                  //     image: DecorationImage(
                  //   image: AssetImage("images/logo2.png"),
                  //   //fit: BoxFit
                  // )
                  // ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: curUser.photoUrl != ""
                                    ? NetworkImage(curUser.photoUrl)
                                    : AssetImage("images/avatar.jpg"))),
                      ),
                    ),
                    title: Text(
                      widget.currentUser != null
                          ? widget.currentUser.fname +
                              " " +
                              widget.currentUser.lname
                          : "",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Nav_Drawer_Tile(
                  title: kNavDrawerAmount,
                  icon: Container(
                    height: 23,
                    width: 23,
                    child: SvgPicture.asset(
                      "images/group2834.svg",
                      color: nameCol.withOpacity(0.4),
                    ),
                  ),
                  trailing: Text(
                    curUser != null ? curUser.lollarAmount.toString() : "",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                Nav_Drawer_Tile(
                  f: (){
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AllConnections()));
                  },
                    title: kNavDrawerConnection,
                    icon: Container(
                      height: 23,
                      width: 23,
                      child: SvgPicture.asset(
                        "images/high-five.svg",
                        color: nameCol.withOpacity(0.4),
                      ),
                    ),
                    trailing: Text("${curUser.connection.length}",
                        style: TextStyle(color: Colors.grey, fontSize: 16))),
                Nav_Drawer_Tile(
                    title: kNavDrawerProfile,
                    f: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile(
                                    currentUser: widget.currentUser,
                                    photoUrl: widget.photoUrl,
                                    user: widget.currentUser,
                                  )));
                    },
                    icon: SvgPicture.asset(
                      "images/person_border.svg",
                      color: nameCol.withOpacity(0.4),
                    ),
                    trailing: IconButton(
                      alignment: Alignment.centerRight,
                      icon: Icon(Icons.chevron_right),
                    )),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 2,
                    color: Colors.grey.withOpacity(0.4),
                  ),
                ),
                Nav_Drawer_Tile(
                  title: kNavDrawerRefer,
                  f: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Refer_and_Earn()));
                  },
                  icon: Container(
                    height: 23,
                    width: 23,
                    child: SvgPicture.asset(
                      "images/refer.svg",
                      color: nameCol.withOpacity(0.4),
                    ),
                  ),
                  trailing: IconButton(
                    alignment: Alignment.centerRight,
                    icon: Icon(Icons.chevron_right),
                  ),
                ),
                Nav_Drawer_Tile(
                  title: kNavDrawerSettings,
                  icon: SvgPicture.asset(
                    "images/settings.svg",
                    color: nameCol.withOpacity(0.4),
                  ),
                  trailing: IconButton(
                    alignment: Alignment.centerRight,
                    icon: Icon(Icons.chevron_right),
                  ),
                ),
                Nav_Drawer_Tile(
                  title: kNavDrawerLogout,
                  icon: Icon(Icons.exit_to_app),
                  trailing: IconButton(
                    alignment: Alignment.centerRight,
                    icon: Icon(Icons.chevron_right),
                  ),
                  f: () {
                    logout(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
