import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:rsocial2/config.dart';
import 'package:rsocial2/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rsocial2/Screens/investment.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../post.dart';
import '../user.dart';
import 'investment.dart';
import 'package:http/http.dart' as http;

import 'login_page.dart';

class Wage extends StatefulWidget {
  User currentUser;

  Wage({this.currentUser});

  @override
  _WageState createState() => _WageState();
}

class _WageState extends State<Wage> {
  bool boldInput = false;
  bool italics = false;
  String storytext;
  bool underline = false;
  bool isSelected = false;
  File file;
  List<String> list = new List();
  List<File> fileList = new List();
  String orientation = "wage";
  var textController = new TextEditingController();
  bool isLoading = false;

  handleTakePhoto() async {
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    if (file != null) {
      final bytes = file.readAsBytesSync();
      String img64 = base64Encode(bytes);
      setState(() {
        fileList.add(file);
        list.add(img64);
      });
    }
  }

  handleChooseFromGallery() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = file.readAsBytesSync();
      String img64 = base64Encode(bytes);
      setState(() {
        fileList.add(file);
        list.add(img64);
      });
    }
    print(list);
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "post");
  }

  createPost(String storyText, List<String> list) async {
    if (storyText == null && list.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please enter text or upload pic",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);
      return;
    }
    setState(() {
      isLoading = true;
    });

    if (list.isNotEmpty || storyText != null) {
      var url = storyEndPoint + "createwage";
      var user = await FirebaseAuth.instance.currentUser();
      DocumentSnapshot doc = await users.document(user.uid).get();
      if (doc == null) {
        print("Doc is null in create Post in wage.dart");
        throw Exception();
      }
      var uid = doc['id'];
      print(uid);
      print(storyText);
      print("Post starts");
      Post post = Post(id: uid, storyText: storyText, fileUpload: list);
      var token = await user.getIdToken();
      print(jsonEncode(post.toJsonWage()));
      print(token);
      var response = await http.post(
        url,
        encoding: Encoding.getByName("utf-8"),
        body: jsonEncode(post.toJsonWage()),
        headers: {
          "Authorization": "Bearer: $token",
          "Content-Type": "application/json",
        },
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        print('Response body is: ${response.body}');
        textController.clear();
        setState(() {
          fileList.clear();
        });
        Fluttertoast.showToast(
            msg: "Uploaded wage story!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);
      } else {
        setState(() {
          isLoading = false;
        });
        print(response.statusCode);
      }
    } else
      setState(() {
        print("Empty");
        isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        //appBar: customAppBar(context, "Get Set Earn"),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  orientation = "wage";
                                });
                              },
                              child: Container(
                                child: SvgPicture.asset(
                                  "images/group2773.svg",
                                  color: orientation == "wage"
                                      ? Color(0xff4dbae6)
                                      : colorGreyTint.withOpacity(0.3),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 18,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  orientation = "invest";
                                });
                              },
                              child: Container(
                                child: SvgPicture.asset(
                                  "images/group2771.svg",
                                  color: orientation == "invest"
                                      ? Color(0xff4dbae6)
                                      : colorGreyTint.withOpacity(0.3),
                                ),
                              ),
                            )
                          ],
                        ),
                        orientation == "wage"
                            ? Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 11.0),
                                    child: Text(
                                      "Create a Wage Story",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Lato",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0, right: 25, top: 32),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color:
                                              colorGreyTint.withOpacity(0.03),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          border: Border.all(
                                              color: colorGreyTint,
                                              width: 0.5)),
                                      child: Column(
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              // Row(
                                              //   children: <Widget>[
                                              //     IconButton(
                                              //       icon: Icon(Icons.format_bold),
                                              //       onPressed: () {
                                              //         setState(() {
                                              //           boldInput = !boldInput;
                                              //         });
                                              //       },
                                              //     ),
                                              //     IconButton(
                                              //       icon: Icon(Icons.format_italic),
                                              //       onPressed: () {
                                              //         setState(() {
                                              //           italics = !italics;
                                              //         });
                                              //       },
                                              //     ),
                                              //     IconButton(
                                              //       icon: Icon(Icons.format_underlined),
                                              //       onPressed: () {
                                              //         setState(() {
                                              //           boldInput = !boldInput;
                                              //         });
                                              //       },
                                              //     ),
                                              //   ],
                                              // ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 24,
                                                    top: 12,
                                                    right: 24),
                                                child: TextFormField(
                                                  controller: textController,
                                                  onTap: () {
                                                    setState(() {
                                                      isSelected = false;
                                                    });
                                                  },
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: boldInput
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                                  maxLength: 150,
                                                  maxLines: 6,
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText:
                                                          "Type about your post@ ...",
                                                      hintStyle: TextStyle(
                                                        fontFamily: "Lato",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                        color: colorGreyTint,
                                                      )),
                                                ),
                                              ),
                                              Container(
                                                height: fileList.length != 0
                                                    ? 250
                                                    : 0,
                                                child: Swiper(
                                                    loop: false,
                                                    pagination:
                                                        SwiperPagination(),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: fileList.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Stack(
                                                        children: <Widget>[
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                image: DecorationImage(
                                                                    image: FileImage(
                                                                        fileList[
                                                                            index]),
                                                                    fit: BoxFit
                                                                        .cover)),
                                                            height: 250,
                                                          ),
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            8)),
                                                                color: Colors
                                                                    .red
                                                                    .withOpacity(
                                                                        0.2)),
                                                            child: IconButton(
                                                              icon: Icon(
                                                                Icons.clear,
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  fileList
                                                                      .removeAt(
                                                                          index);
                                                                  list.removeAt(
                                                                      index);
                                                                });
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                    }),
                                              )
                                            ],
                                          ),
                                          Divider(
                                            height: 2,
                                            color: Colors.black,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              IconButton(
                                                icon: Icon(
                                                  Icons.photo,
                                                  color: colorGreyTint,
                                                  size: 23,
                                                ),
                                                onPressed: () {
                                                  handleChooseFromGallery();
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.camera_alt,
                                                  color: colorGreyTint,
                                                  size: 23,
                                                ),
                                                onPressed: () {
                                                  handleTakePhoto();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 60, bottom: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        FaIcon(
                                          FontAwesomeIcons.coins,
                                          color: colorCoins,
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Text(
                                          "Earn: 50",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Lato"),
                                        )
                                      ],
                                    ),
                                  ),
                                  RoundedButton(
                                    color: Color(0xff4dbae6),
                                    textColor: Colors.white,
                                    text: "Time to Brag",
                                    onPressed: () {
                                      storytext = textController.text;
                                      createPost(storytext, list);
                                    },
                                  )
                                ],
                              )
                            : Investment()
                      ],
                    ),
                  ),
                ],
              ));
  }
}
