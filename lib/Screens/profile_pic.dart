import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:image/image.dart' as im;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';

import 'package:rsocial2/Screens/bio_page.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/auth.dart';
import 'package:uuid/uuid.dart';

import '../contants/constants.dart';
import '../model/user.dart';
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
  String path;
  Future<File> _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      aspectRatio: CropAspectRatio(
        ratioX: 4,
        ratioY: 3,
      ),
      sourcePath: filePath,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (croppedImage != null) {
      //setState(() {});
      return croppedImage;
    }
  }

  Future<File> compressImage(File f) async {
    final tempDir = await getTemporaryDirectory();
    path = tempDir.path;
    im.Image imageFile = im.decodeImage(f.readAsBytesSync());
    String randomId = Uuid().v4();
    final compressedImageFile = File('$path/img_$randomId.jpg')
      ..writeAsBytesSync(im.encodeJpg(imageFile,
          quality: ((5000000 / f.lengthSync()) * 100).floor()));

    // print('$path/img_${Uuid().v4()}.jpg');

    return compressedImageFile;
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    var status = await Permission.storage.status;

    if (status.isGranted || status.isUndetermined) {
      try {
        PickedFile pickedFile = await ImagePicker().getImage(
          source: ImageSource.gallery,
        );
        if (pickedFile != null) {
          File file = await _cropImage(pickedFile.path);
          //final File file = File(pickedFile.path);
          if (file != null) {
            if (file.lengthSync() > 5000000) {
              file = await compressImage(file);
              print("New length =" + file.lengthSync().toString());

              print("not allowed");
              if (file.lengthSync() > 5000000) {
                var alertBox = AlertDialogBox(
                  title: 'Error',
                  content: 'Image is too large',
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

  handleTakePhoto() async {
    // File file = await ImagePicker.pickImage(
    //   source: ImageSource.camera,
    //   maxHeight: 675,
    //   maxWidth: 960,
    // );
    Navigator.pop(context);
    var status = await Permission.camera.status;

    if (status.isGranted || status.isUndetermined) {
      PickedFile pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        // maxHeight: 675,
        // maxWidth: 960,
      );
      if (pickedFile != null) {
        file = await _cropImage(pickedFile.path);
        // file = File(pickedFile.path);
        if (file != null) {
          print("File size");
          print(file.lengthSync());

          if (file.lengthSync() > 5000000) {
            file = await compressImage(file);
            print("New length =" + file.lengthSync().toString());

            print("not allowed");
            if (file.lengthSync() > 5000000) {
              var alertBox = AlertDialogBox(
                title: 'Error',
                content: 'Image is too large',
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
          }
          this.file = file;
          final bytes = file.readAsBytesSync();

          this.encodedFile = base64Encode(bytes);

          setState(() {});
        }
      }
    } else {
      var alertBox = AlertDialogBox(
        title: "Camera Permission",
        content: "This app needs camera access to take photos",
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

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "Profile_pic_page");
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Change Profile Photo"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Take photo from Camera"),
                onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text("Upload photo from Gallery"),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
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
                    selectImage(context);
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
