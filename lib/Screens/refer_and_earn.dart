import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/model/post.dart';
import 'package:share/share.dart';

import '../contants/constants.dart';
import '../deep_links.dart';
import '../helper.dart';

class Refer_and_Earn extends StatefulWidget {
  @override
  _Refer_and_EarnState createState() => _Refer_and_EarnState();
}

class _Refer_and_EarnState extends State<Refer_and_Earn> {
  bool _isCreatingLink = false;
  int referralPoints;
  bool gettingPoints = false;
  bool failedGetPoints = false;

  Future<void> getReferralPoints() async {
    setState(() {
      gettingPoints = true;
    });

    var user = authFirebase.currentUser;
    var token = await user.getIdToken();
    var id = curUser.id;

    var response = await postFunc(
        url: userEndPoint + "referralpoints",
        token: token,
        body: jsonEncode({"id": id}));

    if (response == null) {
      setState(() {
        gettingPoints = false;
        failedGetPoints = true;
      });
      return null;
    }
    if (response.statusCode == 200) {
      var responseMessage =
          jsonDecode((jsonDecode(response.body))['body'])['message'];
      referralPoints = responseMessage;
    }
    setState(() {
      gettingPoints = false;
      failedGetPoints = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getReferralPoints();
  }

  Future<Uri> makeLink(String type, Post post) async {
    Uri uri;
    setState(() {
      _isCreatingLink = true;
    });
    uri = await createDynamicLink(type, post);
    setState(() {
      _isCreatingLink = false;
    });
    return uri;
  }

  Future<void> share(Uri uri) async {
    final RenderBox box = context.findRenderObject();
    Share.share(
      "Hey! Join me on RSocial ${uri.toString()}",
      subject: "Invitation to join me on RSocial",
      sharePositionOrigin: box.localToGlobal(
            Offset.zero,
          ) &
          box.size,
    );
    // await FlutterShare.share(
    //     title: 'Hey! Join me on RSocial',
    //     //text: '${widget.userPost.user.fname} on RSocial',
    //     linkUrl: uri.toString(),
    //     chooserTitle: 'Invite a friend with');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar to be updated
      appBar: customAppBar(
        context,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Refer a friend to earn ",
                style: TextStyle(
                  fontFamily: "Lato",
                  color: Color(0xff263238),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SvgPicture.asset(
                "images/yollar.svg",
                color: colorPrimaryBlue,
                height: 25,
              ),
              Text(
                referralPoints == null ? "-" : referralPoints.toString(),
                style: TextStyle(
                  fontFamily: "Lato",
                  color: Color(0xff263238),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "once they sign up",
              style: TextStyle(
                fontFamily: "Lato",
                color: Color(0xff263238),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "Send invite and Socialize together",
            style: TextStyle(
                fontFamily: "Lato",
                color: Color(0xff263238),
                fontSize: 16,
                fontWeight: FontWeight.w100),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
            child: RoundedButton(
              color: Color(0xff4dbae6),
              textColor: Colors.white,
              text: "Send invite",
              onPressed: !_isCreatingLink
                  ? () async {
                      print("creating link");
                      final Uri uri = await makeLink('sender', null);
                      print("invite link is: $uri");
                      share(uri);
                    }
                  : null,
            ),
          )
        ],
      ),
    );
  }
}
