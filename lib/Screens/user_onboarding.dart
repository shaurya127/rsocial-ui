import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/model/user.dart';

import 'bottom_nav_bar.dart';

class UserOnboarding extends StatelessWidget {
  User currentUser;
  UserOnboarding(this.currentUser);
  final List imgList = [
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/001.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/002.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/003.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/004.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/005.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/007.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/008.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/009.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/010.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/011.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/012.gif',
    'https://rsoc-test-bucket.s3.ap-south-1.amazonaws.com/GIF/013.gif',
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                settings: RouteSettings(name: "Landing_Page"),
                builder: (BuildContext context) => BottomNavBar(
                      currentUser: currentUser,
                      isNewUser: true,
                    )),
            (Route<dynamic> route) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorButton,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  return Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          settings: RouteSettings(name: "Landing_Page"),
                          builder: (BuildContext context) => BottomNavBar(
                                currentUser: currentUser,
                                isNewUser: true,
                              )),
                      (Route<dynamic> route) => false);
                })
          ],
        ),
        body: Swiper(
          itemBuilder: (BuildContext context, int index) {
            return FadeInImage(
              height: MediaQuery.of(context).size.height - 50,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              placeholder: AssetImage('images/splashScreenAndroid.gif'),
              image: NetworkImage(imgList[index]),
            );
          },
          loop: false,
          itemCount: 12,
          itemWidth: MediaQuery.of(context).size.width,
          itemHeight: MediaQuery.of(context).size.height,
          layout: SwiperLayout.DEFAULT,
          pagination: SwiperPagination(),
          controller: SwiperController(),
          containerHeight: 50,
        ),
      ),
    );
  }
}
