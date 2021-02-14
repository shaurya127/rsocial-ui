import 'package:flutter/material.dart';
import 'package:rsocial2/contants/constants.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton(
      {@required this.onPressed,
      this.text,
      this.color = colorButton,
      this.textColor = Colors.white,
      this.elevation = 0});
  final String text;
  final Function onPressed;
  final Color color;
  final Color textColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Material(
        elevation: elevation,
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: MediaQuery.of(context).size.width,
          height: 43.0,
          child: Text(
            text,
            style: TextStyle(
                fontFamily: "Lato",
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
