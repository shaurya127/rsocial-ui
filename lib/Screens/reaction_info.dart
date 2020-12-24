
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rsocial2/Screens/search_page.dart';

import '../constants.dart';

class Reaction_Info extends StatefulWidget {
  List<Request_Tile> love;
  List<Request_Tile> like;

  Reaction_Info({this.like,this.love});
  @override
  _Reaction_InfoState createState() => _Reaction_InfoState();
}

class _Reaction_InfoState extends State<Reaction_Info> with TickerProviderStateMixin{
  //Tab tabs = [];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync:this,length: 2 );
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
        title: Text("People Who Reacted",style: TextStyle(
          //fontWeight: FontWeight.bold,
          fontSize: 18,color: Colors.white,
        ),),
        iconTheme: IconThemeData(color: Colors.white),
        bottom:PreferredSize(
          preferredSize: Size.fromHeight(57),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(top: 16,left: 16),
                child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 4,
                          color: Color(0xff4DBAE6),
                        ),
                        insets: EdgeInsets.only( right: 20,)
                    ),
                    isScrollable: true,
                    labelPadding: EdgeInsets.only(bottom: 8),
                    tabs:[
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.favorite,
                              color: Colors.pink,
                              size: 30,),
                            SizedBox(width: 5,),
                            Text("3000",style: TextStyle(
                              fontFamily: "Lato",
                              fontSize:15,color:Color(0xff4DBAE6),
                            ),),
                          ],
                        ),
                      ),
                      //SizedBox(width: 10,),
                      Row(
                        children: <Widget>[
                          Icon(Icons.thumb_up,
                            color: Colors.lightBlue,
                            size: 30,),
                          SizedBox(width: 5,),
                          Text(
                            "3000",style:TextStyle(
                            fontFamily: "Lato",
                            fontSize:15,color:Color(0xff4DBAE6),
                          ),),
                          SizedBox(width: 20),
                        ],
                      ),
                    ]
                ),
              ),
            ),
          ),
        ) ,
      ),
      body: TabBarView(
        children: <Widget>[
          widget.love.isNotEmpty ? Container(
            color: Colors.white,
            child: ListView(
              children: widget.love
            ),
          ) : Center(
            child: Text(
              "No love yet!",
              style: TextStyle(
                fontFamily: "Lato",
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          widget.like.isNotEmpty ? Container(
            color: Colors.white,
            child: ListView(
              children: widget.like,
            ),
          ) : Center(
            child: Text(
              "No likes yet!",
              style: TextStyle(
                fontFamily: "Lato",
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          )
        ],
        controller: _tabController,
      ),
    );
  }
}


