import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/model/user.dart';
import 'bottom_nav_bar.dart';

class UserOnboarding extends StatefulWidget {
  User currentUser;
  // int ind/ex;
  UserOnboarding(this.currentUser);

  @override
  _UserOnboardingState createState() => _UserOnboardingState();
}

class _UserOnboardingState extends State<UserOnboarding> {
  static const String url =
      "https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/";
  int count = 0;
  // List<CircleAvatar> dots=new List();

  final List imgList = [
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/001.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/002.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/003.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/004.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/005.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/006.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/007.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/008.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/009.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/010.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/011.jpeg',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/012.jpeg',
  ];

  int index=0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                settings: RouteSettings(name: "Landing_Page"),
                builder: (BuildContext context) => BottomNavBar(
                      currentUser: widget.currentUser,
                      isNewUser: true,
                    )),
            (Route<dynamic> route) => false);
      },
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.center,
            color: Colors.black87.withOpacity(0.8),
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
                itemCount: 12,
                itemBuilder: (context,i){
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                    radius: 7.0,
                  backgroundColor: i==index?colorButton:Colors.white,
                ),
              );

                // radius:
            }),

          ),
          appBar: AppBar(
            elevation: 0.1,
            backgroundColor: Colors.black87.withOpacity(0.8),
            iconTheme: IconThemeData(color: Colors.white),
            actions: [
              FlatButton(
                  onPressed: () {
                    return Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            settings: RouteSettings(name: "Landing_Page"),
                            builder: (BuildContext context) => BottomNavBar(
                                  currentUser: widget.currentUser,
                                  isNewUser: true,
                                )),
                        (Route<dynamic> route) => false);
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Lato",
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  )),
            ],
          ),
          body: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: double.infinity,
                      imageUrl: imgList[index],
                      placeholder: _loader,
                      errorWidget: _error,
                    ),
                  ),
                ],
              );
            },
            loop: false,
            itemCount: 12,
            layout: SwiperLayout.DEFAULT,
            // index: index,
            onIndexChanged: (int i){
              setState(() {
                print(index);
                index=i;
              });
            },

            // onIndexChanged:
            // pagination: SwiperPagination(
            //     alignment: Alignment.bottomCenter,
            //     builder: DotSwiperPaginationBuilder(
            //       color: Colors.grey[400],
            //       size: 12,
            //       activeColor: Colors.red,
            //     )),
            controller: SwiperController(),
            containerHeight: 10,
          ),
        ),
      ),
    );
  }

  Widget _loader(BuildContext context, String url) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _error(BuildContext context, String url, dynamic error) {
    print(error);
    return Center(
      child: Icon(Icons.error_outline),
    );
  }
}
