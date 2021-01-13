import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/auth.dart';
import '../constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../user.dart';

AppBar customAppBar(context, String title, String lollarAmount, String photoUrl,
    String socialStanding,
    [bool canShowProfile = true]) {
  showProfile(BuildContext context, User user, String photourl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          currentUser: curUser,
          photoUrl: photourl,
          user: user,
        ),
      ),
    );
  }

  return AppBar(
    backgroundColor: colorButton,
    iconTheme: IconThemeData(color: Colors.white),
    actions: [
      Padding(
        padding: const EdgeInsets.only(left: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              "images/group2772.svg",
              color: Colors.white,
              height: 23,
            ),
            Text(
              lollarAmount,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: "Lato"),
            )
          ],
        ),
      ),
      SizedBox(
        width: 10,
      ),
      Padding(
        padding: const EdgeInsets.only(right: 24, top: 4),
        child: Stack(
          children: <Widget>[
            GestureDetector(
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: curUser.photoUrl != ""
                            ? NetworkImage(curUser.photoUrl)
                            : AssetImage("images/avatar.jpg"),
                        fit: BoxFit.cover),
                    shape: BoxShape.circle),
              ),
              onTap: () {
                if (canShowProfile)
                  showProfile(context, curUser, curUser.photoUrl);
              },
            ),
            Positioned(
              left: 0,
              top: 35,
              child: Container(
                height: 17,
                // width: 40,
                decoration: BoxDecoration(
                    border: Border.all(color: Color(0xff37B44B)),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    //shape: BoxShape.circle,
                    color: Color(0xff37B44B)),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                      child: Text(socialStanding,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
    ],
    titleSpacing: 0,
    title: SvgPicture.asset(
      "images/rsocial-text.svg",
      height: 90,
      width: 90,
    ),
  );
}
