import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProviderButton extends StatelessWidget {
  final Function onPressed;
  final String title;
  final String iconLocation;
  final Color color;
  final Color buttonColor;

  ProviderButton(
      {@required this.onPressed,
      @required this.title,
      @required this.iconLocation,
      @required this.color,
      @required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
            //border: Border.all(color: Color(0xff409FC6)),
            ),
        height: 43,
        child: Material(
          elevation: 0,
          color: buttonColor,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: MaterialButton(
            height: 100,
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 24),
                SvgPicture.asset(
                  iconLocation,
                  color: color,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 48.0),
                  child: Text(
                    title,
                    style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
