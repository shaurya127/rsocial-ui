import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rsocial2/auth.dart';
import '../constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../user.dart';

AppBar customAppBar(context, String title, String lollarAmount, String photoUrl,
    String socialStanding) {
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
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(photoUrl)),
                  shape: BoxShape.circle),
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
    title: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontFamily: "Lato",
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
    ),
  );
}
