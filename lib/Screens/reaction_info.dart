import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'package:rsocial2/Widgets/request_tile.dart';

import '../constants.dart';

class Reaction_Info extends StatefulWidget {
  List<Request_Tile> love;
  List<Request_Tile> like;
  List<Request_Tile> hate;
  List<Request_Tile> whatever;

  Reaction_Info({this.like, this.love, this.whatever, this.hate});
  @override
  _Reaction_InfoState createState() => _Reaction_InfoState();
}

class _Reaction_InfoState extends State<Reaction_Info>
    with TickerProviderStateMixin {
  //Tab tabs = [];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 4);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          kReactionInfoAppBarTitle,
          style: TextStyle(
            //fontWeight: FontWeight.bold,
            fontSize: 18, color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 16),
                child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 4,
                          color: colorPrimaryBlue,
                        ),
                        insets: EdgeInsets.only(
                          right: 20,
                        )),
                    isScrollable: true,
                    labelPadding: EdgeInsets.only(bottom: 8),
                    tabs: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: <Widget>[
                            SvgPicture.asset(
                              "images/thumb_blue.svg",
                              height: 23,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.love.isNotEmpty
                                  ? widget.love.length.toString()
                                  : "0",
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 15,
                                color: colorPrimaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      //SizedBox(width: 10,),
                      Row(
                        children: <Widget>[
                          SvgPicture.asset(
                            "images/rsocial_thumbUp_blue.svg",
                            height: 23,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.like.isNotEmpty
                                ? widget.like.length.toString()
                                : "0",
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: 15,
                              color: colorPrimaryBlue,
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),

                      Row(
                        children: <Widget>[
                          SvgPicture.asset(
                            "images/rsocial_thumbDown_blue.svg",
                            height: 23,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.whatever.isNotEmpty
                                ? widget.whatever.length.toString()
                                : "0",
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: 15,
                              color: colorPrimaryBlue,
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),

                      Row(
                        children: <Widget>[
                          SvgPicture.asset(
                            "images/rsocial_punch_blue.svg",
                            height: 23,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.hate.isNotEmpty
                                ? widget.hate.length.toString()
                                : "0",
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: 15,
                              color: colorPrimaryBlue,
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          widget.love.isNotEmpty
              ? Container(
                  color: Colors.white,
                  child: ListView(children: widget.love),
                )
              : Center(
                  child: Text(
                    "No love yet!",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
          widget.like.isNotEmpty
              ? Container(
                  color: Colors.white,
                  child: ListView(
                    children: widget.like,
                  ),
                )
              : Center(
                  child: Text(
                    "No likes yet!",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
          widget.whatever.isNotEmpty
              ? Container(
                  color: Colors.white,
                  child: ListView(children: widget.whatever),
                )
              : Center(
                  child: Text(
                    "No one here!",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
          widget.hate.isNotEmpty
              ? Container(
                  color: Colors.white,
                  child: ListView(children: widget.hate),
                )
              : Center(
                  child: Text(
                    "No one here!",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
        ],
        controller: _tabController,
      ),
    );
  }
}
