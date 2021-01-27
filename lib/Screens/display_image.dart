import 'package:flutter/material.dart';

class DisplayImage extends StatefulWidget {
  String url;
  DisplayImage({this.url});
  @override
  _DisplayImageState createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                widget.url
              )
            )
          ),
        ),
      ),
    );
  }
}
