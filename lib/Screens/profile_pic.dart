import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';

import 'package:rsocial2/Screens/bio_page.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/auth.dart';

import '../constants.dart';
import '../user.dart';
import 'bio_page.dart';

class ProfilePicPage extends StatefulWidget {
  User currentUser;
  ProfilePicPage({@required this.currentUser});
  @override
  _ProfilePicPageState createState() => _ProfilePicPageState();
}

class _ProfilePicPageState extends State<ProfilePicPage> {
  File file;
  String encodedFile;

  handleChooseFromGallery() async {
    var status = await Permission.storage.status;

    if (status.isGranted || status.isUndetermined) {
      try {
        PickedFile pickedFile = await ImagePicker().getImage(
          source: ImageSource.gallery,
        );
        if (pickedFile != null) {
          final File file = File(pickedFile.path);
          if (file != null) {
            if (file.lengthSync() > 5000000) {
              print("not allowed");
              var alertBox = AlertDialogBox(
                title: 'Error',
                content: 'Images must be less than 5MB',
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Back'),
                  )
                ],
              );
              showDialog(context: context, builder: (context) => alertBox);
              return;
            }

            this.file = file;
            final bytes = file.readAsBytesSync();
            print(base64Encode(bytes));
            this.encodedFile = base64Encode(bytes);
            print("This is encoded file:  ${this.encodedFile}");
            setState(() {});
          }
        }
      } on PlatformException catch (e) {
        if (e.code == 'photo_access_denied') {
          print(e);

          var alertBox = AlertDialogBox(
            title: "Gallery Permission",
            content: "This app needs gallery access to take photos",
            actions: <Widget>[
              FlatButton(
                child: Text("Settings"),
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
              ),
              FlatButton(
                child: Text("Deny"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
          showDialog(context: context, builder: (context) => alertBox);
        }
      }
    } else {
      var alertBox = AlertDialogBox(
        title: "Gallery Permission",
        content: "This app needs gallery access to take photos",
        actions: <Widget>[
          FlatButton(
            child: Text("Settings"),
            onPressed: () {
              openAppSettings();
            },
          ),
          FlatButton(
            child: Text("Deny"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
      showDialog(context: context, builder: (context) => alertBox);
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "Profile_pic_page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: ListView(children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment(-1, 0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: colorButton,
                    ),
                    onPressed: () {
                      return Navigator.pop(context);
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                child: SvgPicture.asset(
                  "images/rsocial-logo.svg",
                  height: 90,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Center(
                child: Text(
                  kProfilePicText,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      fontFamily: "Lato"),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                kProfilePicSubtext,
                style: TextStyle(
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w400,
                    fontSize: 16),
              ),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () {
                    handleChooseFromGallery();
                  },
                  child: Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // borderRadius: BorderRadius.all(Radius.circular(8)),
                        image: file != null
                            ? DecorationImage(
                                image: FileImage(
                                  file,
                                ),
                                fit: BoxFit.cover)
                            : null,
                        border: Border.all(
                            color: file == null ? colorButton : Colors.white),
                      ),
                      child: file == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SvgPicture.asset(
                                    "images/group2848.svg",
                                    color: colorButton,
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    "Upload",
                                    style: TextStyle(
                                        color: colorButton,
                                        fontFamily: "Lato",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  )
                                ],
                              ),
                            )
                          : SizedBox.shrink()),
                ),
              ),
              SizedBox(
                height: 32,
              ),
              RoundedButton(
                text: "Continue",
                elevation: 0,
                onPressed: () async {
                  if (file != null) {
                    print("Inside continue");
                    // print(this.encodedFile);
                    // log("Encoded file ${this.encodedFile} in photoURL",
                    //     name: "bla bbbbbb");
                    print("Encoded file in photoUrl");
                    widget.currentUser.photoUrl = this.encodedFile;
                  }

                  FirebaseAnalytics().setUserProperty(
                      name: 'Upload_pic_or_not', value: "uploaded_pic");
                  return Navigator.push(
                      context,
                      PageTransition(
                          settings: RouteSettings(name: "Bio_Page"),
                          type: PageTransitionType.rightToLeft,
                          child: BioPage(currentUser: widget.currentUser)));
                },
              ),
              SizedBox(
                height: 32,
              ),
              InkWell(
                onTap: () async {
                  FirebaseAnalytics().setUserProperty(
                      name: 'Upload_pic_or_not', value: "skipped_pic");
                  //widget.analytics.logEvent(name: "pic_Status_uploaded");
                  return Navigator.push(
                      context,
                      PageTransition(
                          settings: RouteSettings(name: "Bio_Page"),
                          type: PageTransitionType.rightToLeft,
                          child: BioPage(currentUser: widget.currentUser)));
                },
                child: Text(
                  "Skip for now",
                  style: TextStyle(
                      color: colorButton,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
        ]));
  }
}
