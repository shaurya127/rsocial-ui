import 'package:flutter/material.dart';

class AlertDialogBox extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  AlertDialogBox(
      {@required this.title, @required this.content, @required this.actions});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(title),
        titleTextStyle: TextStyle(
            fontFamily: "Lato",
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20),
        content: Text(content),
        actions: actions);
  }
}
