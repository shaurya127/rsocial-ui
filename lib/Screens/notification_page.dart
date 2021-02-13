import 'package:flutter/material.dart';

import '../constants.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  TabController _tabController2;

  @override
  void initState() {
    super.initState();
    _tabController2 = new TabController(vsync:this,length: 2 );
  }

  @override
  void dispose() {
    _tabController2.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        indicatorColor:colorPrimaryBlue,
        indicatorWeight: 3,
        labelColor: colorPrimaryBlue,
        labelStyle: TextStyle(
            fontSize: 16,
          fontFamily: 'Lato'
        ),
        unselectedLabelColor: colorGreyTint,
        unselectedLabelStyle: TextStyle(
            fontSize: 16,
            fontFamily: 'Lato'
        ),
        controller: _tabController2,
        tabs: <Tab>[
          Tab(
            text: "Platform",
          ),
          Tab(
            text: "User",
          ),

        ],
      ),
      body: TabBarView(
        children: <Widget>[
          Container(
            color: Colors.grey.withOpacity(0.1),
          ),
          Container(
            color: Colors.grey.withOpacity(0.1),
          ),
        ],
        controller: _tabController2,
      ),
    );
  }
}
