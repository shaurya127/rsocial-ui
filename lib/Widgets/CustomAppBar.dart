import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/auth.dart';
import '../constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rsocial2/functions.dart';
import '../user.dart';

AppBar customAppBar(context, String title, int lollarAmount, String photoUrl,
    int socialStanding,
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
  // print("---------------");
  // print(socialStanding);
  return AppBar(
    backgroundColor: colorButton,
    iconTheme: IconThemeData(color: Colors.white),
    actions: [
      Padding(
        padding: const EdgeInsets.only(left: 10, top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              "images/yollar.svg",
              color: Colors.white,
              height: 23,
            ),
            SizedBox(
              width: 1,
            ),
            Text(curUser==null ?
              formatNumber(lollarAmount) : formatNumber(yA),
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: "Lato"),
            ),
            SizedBox(
              width: 5,
            ),
            SvgPicture.asset(
              "images/socialStanding.svg",
              color: Colors.white,
              height: 23,
            ),
            SizedBox(
              width: 1,
            ),
            Text(curUser==null ?
              formatNumber(socialStanding) : formatNumber(ss),
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
        child: GestureDetector(
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: curUser!=null ? ( curUser.photoUrl !="" ?NetworkImage(curUser.photoUrl) : AssetImage("images/avatar.jpg")):
                    (photoUrl==null? NetworkImage(photoUrl): AssetImage("images/avatar.jpg")),
                    fit: BoxFit.cover),
                shape: BoxShape.circle),
          ),
          onTap: () {
            if (canShowProfile) showProfile(context, curUser, curUser.photoUrl);
          },
        ),

        // child: Stack(
        //   children: <Widget>[
        //     GestureDetector(
        //       child: Container(
        //         height: 35,
        //         width: 35,
        //         decoration: BoxDecoration(
        //             image: DecorationImage(
        //                 image: curUser.photoUrl != ""
        //                     ? NetworkImage(curUser.photoUrl)
        //                     : AssetImage("images/avatar.jpg"),
        //                 fit: BoxFit.cover),
        //             shape: BoxShape.circle),
        //       ),
        //       onTap: () {
        //         if (canShowProfile)
        //           showProfile(context, curUser, curUser.photoUrl);
        //       },
        //     ),
        //     // Positioned(
        //     //   left: 0,
        //     //   top: 35,
        //     //   child: Container(
        //     //     height: 17,
        //     //     // width: 40,
        //     //     decoration: BoxDecoration(
        //     //         border: Border.all(color: colorProfitPositive),
        //     //         borderRadius: BorderRadius.all(Radius.circular(10)),
        //     //         //shape: BoxShape.circle,
        //     //         color: colorProfitPositive),
        //     //     child: Padding(
        //     //       padding: const EdgeInsets.all(2.0),
        //     //       child: Center(
        //     //           child: Text(curUser.socialStanding.toString(),
        //     //               style: TextStyle(
        //     //                   color: Colors.white,
        //     //                   fontSize: 10,
        //     //                   fontWeight: FontWeight.bold))
        //     //           // FaIcon(
        //     //           //   FontAwesomeIcons.bars,
        //     //           //   color: colorGreenTint,
        //     //           //   size: 15,
        //     //           // ),
        //     //           ),
        //     //     ),
        //     //   ),
        //     // )
        //   ],
        // ),
      ),
    ],
    // titleSpacing: 0,
    // title: title == ""
    //     ? SvgPicture.asset(
    //         "images/rsocial-text.svg",
    //         // height: 90,
    //         // width: 90,
    //       )
    //     : Text(
    //         title,
    //         style: TextStyle(fontFamily: 'Lato', color: Colors.white),)
  );
}
