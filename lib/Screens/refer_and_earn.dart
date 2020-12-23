import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';

import '../constants.dart';

class Refer_and_Earn extends StatefulWidget {
  @override
  _Refer_and_EarnState createState() => _Refer_and_EarnState();
}

class _Refer_and_EarnState extends State<Refer_and_Earn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar to be updated
      appBar: customAppBar(context, "Refer & earn", "100", "",""),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Refer a friend to earn",
                style: TextStyle(
                  fontFamily: "Lato",
                  color: Color(0xff263238),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: FaIcon(
                  FontAwesomeIcons.coins,
                  color: colorCoins,
                  size: 22,
                ),
              ),
              Text(
                "50",
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
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
