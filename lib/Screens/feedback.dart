import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/contants/constants.dart';

import '../helper.dart';
import 'bottom_nav_bar.dart';

class FeedbackScreen extends StatefulWidget {
  Function callback;
  FeedbackScreen({this.callback});
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  var textController = new TextEditingController();
  bool isSelected = false;
  bool boldInput = false;
  String feedback;

  sendFeedback(String feedback) async {
    var user = await authFirebase.currentUser();
    var token = await user.getIdToken();
    var id = curUser.id;

    if (feedback == "")
      return Fluttertoast.showToast(
          msg: "Cannot send an empty feedback!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);
    else {
      var response = await postFunc(
          url: userEndPoint + "feedback",
          token: token,
          body: jsonEncode({
            "id": id,
            'fname': curUser.fname,
            'lname': curUser.lname,
            'message': feedback
          }));

      if (response == null) {
        return null;
      }
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        textController.clear();
        Fluttertoast.showToast(
            msg: "Feedback sent",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);
        widget.callback();
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: "encountered an error, please try later",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25, top: 10),
            child: Text(
              "(ou)रsocial",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'lato',
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25, top: 0),
            child: Text(
              "#ReinventingSocialTogether",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'lato',
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25, top: 32),
            child: Container(
              decoration: BoxDecoration(
                  color: colorGreyTint.withOpacity(0.03),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: colorGreyTint, width: 0.5)),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 24, top: 12, right: 24, bottom: 12),
                child: TextFormField(
                  controller: textController,
                  onTap: () {
                    setState(() {
                      isSelected = false;
                    });
                  },
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: boldInput ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLength: 150,
                  maxLines: 10,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Tell us about your experience..",
                    hintStyle: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: colorGreyTint,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: RoundedButton(
              color: colorPrimaryBlue,
              textColor: Colors.white,
              text: "Submit",
              onPressed: () {
                feedback = textController.text;
                sendFeedback(feedback.trim());
              },
            ),
          )
        ],
      ),
    );
  }
}
