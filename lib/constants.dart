import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const regexForPhone = r'^[6-9][0-9]{9}$';

const colorGreenTint = Color(0xff409FC6);
const colorPrimaryBlue = Color(0xff4dbae6);
const colorButton = Color(0xff4DBAE6);
const colorGreyTint = Color(0xff7f7f7f);
const colorCoins = Color(0xffE2AF25);
const colorHintText = Color(0xff263238);
const colorUnselectedBottomNav = Color(0xff707070);
const googleTextColor = Color(0xffEA4335);
const facebookTextColor = Color(0xff285296);
const rsocialTextColor = Color(0xff4DBAE6);
const googleButtonColor = Color(0xffF5E8EA);
const facebookButtonColor = Color(0xffE6EAF4);
const postDesc = Color(0xff707070);
const nameCol = Color(0xff263238);
const subtitile = Color(0xff7F7F7F);
const postIcons = Colors.grey;

const kInputField = InputDecoration(
    //labelText: "First Name",
    border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.black))
    // focusedBorder: UnderlineInputBorder(
    //   borderSide: BorderSide(color: Colors.lightBlueAccent),
    // ),
    );

const kOtpInput = InputDecoration(
    counterText: "",
    counterStyle: TextStyle(height: double.minPositive),
    // enabledBorder: OutlineInputBorder(),
    // focusedBorder: OutlineInputBorder(),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
        borderSide: BorderSide(color: Color(0xff263238))));
