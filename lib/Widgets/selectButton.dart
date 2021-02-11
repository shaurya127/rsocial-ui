import 'package:flutter/material.dart';

class SelectButton extends StatelessWidget {
  Function onTap;
  String text;
  String orientation;
  String curOrientation;

  SelectButton(
      {@required this.onTap,
      @required this.text,
      @required this.orientation,
      @required this.curOrientation});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 18),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                color: curOrientation == orientation
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              ),
            ),
            decoration: BoxDecoration(
                color: curOrientation == orientation
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    width: 1, color: Theme.of(context).primaryColor)),
          ),
        ),
      ),
    );
  }
}

// GestureDetector(
// onTap: () => setOrientation("request"),
// child: Container(
// padding:
// EdgeInsets.symmetric(vertical: 10, horizontal: 18),
// child: Text(
// "Requests",
// style: TextStyle(
// fontFamily: 'Lato',
// fontSize: 16,
// color: Orientation == 'request'
// ? Colors.white
//     : Theme.of(context).primaryColor,
// ),
// ),
// decoration: BoxDecoration(
// color: Orientation == 'request'
// ? Theme.of(context).primaryColor
//     : Colors.white,
// borderRadius: BorderRadius.circular(12),
// border: Border.all(
// width: 1, color: Theme.of(context).primaryColor)),
// ),
// ),
