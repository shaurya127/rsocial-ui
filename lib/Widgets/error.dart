import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../authLogic.dart';
import '../constants.dart';

class ErrWidget extends StatefulWidget {
  Function tryAgainOnPressed;
  bool showLogout = false;
  ErrWidget({this.tryAgainOnPressed, this.showLogout});
  @override
  _ErrWidgetState createState() => _ErrWidgetState();
}

class _ErrWidgetState extends State<ErrWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            "images/rsocial-logo.svg",
            height: 50,
          ),
          Center(
            child: Text(
              "Some Error occurred",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                child: Text(
                  "Try again",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: widget.tryAgainOnPressed,
              ),
              SizedBox(
                width: 10,
              ),
              widget.showLogout
                  ? RaisedButton(
                      child: Text(
                        "Log out",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Lato",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        logout(context);
                      },
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
    ;
  }
}
