import 'package:flutter/material.dart';
import 'package:rsocial2/contants/constants.dart';

class Nav_Drawer_Tile extends StatelessWidget {
  Function f;
  final Widget icon;
  final String title;
  Widget trailing;
  Nav_Drawer_Tile({this.title, this.icon, this.f, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: f,
          child: ListTile(
            dense: true,
            //contentPadding: EdgeInsets.all(-10),
            trailing: trailing,
            leading: icon,
            title: Container(
              transform: Matrix4.translationValues(-25, 0.0, 0.0),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  color: colorGreyTint,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
