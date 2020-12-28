import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//import 'package:fluttertoast/fluttertoast.dart';

import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Screens/login_page.dart';

import 'package:rsocial2/Screens/wage.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/config.dart';
import 'package:rsocial2/user.dart';

import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:rsocial2/Widgets/RoundedButton.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:search_widget/search_widget.dart';

import '../post.dart';
import 'package:http/http.dart' as http;

// const kAndroidUserAgent =
//     'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

class Investment extends StatefulWidget {
  User currentUser;

  Investment({this.currentUser});

  @override
  _InvestmentState createState() => _InvestmentState();
}

class _InvestmentState extends State<Investment> {
  int amount = 1000;
  bool isOne = true;
  bool boldInput = false;
  bool italics = false;
  bool underline = false;
  bool isSelected = false;
  File file;
  String search_query;
  String storyText;
  var textController = new TextEditingController();
  List<File> fileList = new List();
  List<String> selectedImgList = new List();
  List<User> selectedList = new List();
  List<String> idSelectedList = new List();
  String investedWith = "3406418ba95248e7b0d65a467e61b68d";
  List<User> list = new List();
  List<User> connections = [];
  bool isloading = false;
//   Future<void> initUserAgentState() async {
//     String userAgent, webViewUserAgent;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       userAgent = await FlutterUserAgent.getPropertyAsync('userAgent');
//       await FlutterUserAgent.init();
//       webViewUserAgent = FlutterUserAgent.webViewUserAgent;
//       print('''
// applicationVersion => ${FlutterUserAgent.getProperty('applicationVersion')}
// systemName         => ${FlutterUserAgent.getProperty('systemName')}
// userAgent          => $userAgent
// webViewUserAgent   => $webViewUserAgent
// packageUserAgent   => ${FlutterUserAgent.getProperty('packageUserAgent')}
//       ''');
//     } on PlatformException {
//       userAgent = webViewUserAgent = '<error>';
//     }
//   }

  //
  // authenticate() async {
  //   // await initUserAgentState();
  //
  //   var uri = Uri.parse("http://rsocial.in:8080/auth/realms/rsocial/");
  //   var clientId = "account";
  //   var scopes = List<String>.of([]);
  //   var port = 4200;
  //   var redirectUri = Uri.parse("http://google.com/");
  //   print("hello hello");
  //   var issuer = await Issuer.discover(uri);
  //   var client = new Client(issuer, clientId);
  //
  //   urlLauncher(String url) async {
  //     if (await canLaunch(url)) {
  //       await launch(
  //         url,
  //         forceWebView: true,
  //       );
  //     } else {
  //       throw "Could not launch url";
  //     }
  //   }
  //
  //   var authenticator = new Authenticator(
  //     client,
  //     scopes: scopes,
  //     port: port,
  //     redirectUri: redirectUri,
  //     urlLancher: urlLauncher,
  //   );
  //
  //   var c = await authenticator.authorize();
  //   closeWebView();
  //
  //   var token = await c.getTokenResponse;
  //
  //   print(token);
  //   print("Hello $token");
  //   return token;
  // }

  void getFriends() async {
    var user = await FirebaseAuth.instance.currentUser();
    //
    // // Getting doc from firebase
    DocumentSnapshot doc = await users.document(user.uid).get();
    // // Getting id of current user from firebase
    var id = doc['id'];
    //
    final url = userEndPoint + "$id";
    //
    var token = await user.getIdToken();
    //
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    });
    User curUser;
    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonUser = jsonDecode(response.body);
      var body = jsonUser['body'];
      var body1 = jsonDecode(body);
      var msg = body1['message'];
      print("These are my connections");
      print(msg);
      curUser = User.fromJson(msg);
    }
    this.list = curUser.connection;
    // if (connections.isNotEmpty) {
    //   for (int i = 0; i < connections.length; i++) {
    //     User user = User.fromJson(connections[i]);
    //     this.list.add(user);
    //   }
  }

  @override
  void initState() {
    super.initState();
    getFriends();
  }

  Widget buildSuggestions(BuildContext context, String query) {
    // show when someone searches for something

    final suggestionList = query == null || query.isEmpty || list.isEmpty
        ? list
        : list
            .where((p) => (p.fname + " " + p.lname)
                .contains(RegExp(query, caseSensitive: false)))
            .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(suggestionList[index].photoUrl),
          radius: 12,
        ),
        onTap: () {
          setState(() {
            isSelected = false;
            if (!selectedList.contains(suggestionList[index]) &&
                selectedList.length <= 5)
              selectedList.add(suggestionList[index]);
          });
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) =>
          //         Detail(listWordsDetail: suggestionList[index]),
          //   ),
          // );
        },
        title: RichText(
          text: TextSpan(
              text: (suggestionList[index].fname +
                      " " +
                      suggestionList[index].lname)
                  .substring(0, query.length),
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: (suggestionList[index].fname +
                            " " +
                            suggestionList[index].lname)
                        .substring(query.length),
                    style: TextStyle(color: Colors.grey)),
              ]),
        ),
      ),
      itemCount: suggestionList.length,
    );
  }

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
        selectedImgList.add(img64);
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
        selectedImgList.add(img64);
      });
    }
    //print(fileList);
  }

  Widget tagWidget(String title, int index, String photoUrl) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4),
      child: Container(
        decoration: BoxDecoration(
            color: colorPrimaryBlue,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: colorGreyTint,
                backgroundImage: NetworkImage(photoUrl),
                radius: 10,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                  size: 15,
                ),
                onPressed: () {
                  setState(() {
                    selectedList.removeAt(index);
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  createPost(String investmentAmount, List<String> list) async {
    setState(() {
      isloading = true;
    });
    // if (storyText != null || fileList.isNotEmpty) {
    //
    //   var url = storyEndPoint + "createinvestment";
    //   var user = await FirebaseAuth.instance.currentUser();
    //   DocumentSnapshot doc = await users.document(user.uid).get();
    //   var uid = doc['id'];
    //   print(uid);
    //
    //   for (int i = 0; i < selectedList.length; i++) {
    //     idSelectedList.add(selectedList[i].id);
    //   }
    //
    //   Post post = Post(
    //       id: uid,
    //       storyText: storyText,
    //       investedWith: idSelectedList,
    //       investedAmount: investmentAmount,
    //       duration: isOne ? 1 : 7,
    //       fileUpload: list);
    //   var token = await user.getIdToken();
    //   print(jsonEncode(post.toJsonInvest()));
    //   //print(token);
    //   var response = await http.post(
    //     url,
    //     encoding: Encoding.getByName("utf-8"),
    //     body: jsonEncode(post.toJsonInvest()),
    //     headers: {
    //       "Authorization": "Bearer: $token",
    //       "Content-Type": "application/json",
    //     },
    //   );
    //   print(response.statusCode);
    //   print(response.reasonPhrase);
    //
    //   if (response.statusCode == 200) {
    //     print('Response body is: ${response.body}');
    //     textController.clear();
    //     setState(() {
    //       amount = 1000;
    //       fileList.clear();
    //       selectedImgList.clear();
    //       idSelectedList.clear();
    //
    //       selectedList.clear();
    //     });
    //     // Fluttertoast.showToast(
    //     //     msg: "Uploaded investment story!",
    //     //     toastLength: Toast.LENGTH_SHORT,
    //     //     gravity: ToastGravity.BOTTOM,
    //     //     fontSize: 15);
    //   } else {
    //     print(response.statusCode);
    //   }
    //   setState(() {
    //     isloading = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: RoundedButton(
    //     text: "ekd",
    //     onPressed: () {
    //       return authenticate();
    //     },
    //   ),
    // );
    return isloading
        ? LinearProgressIndicator()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     GestureDetector(
              //       onTap: () {
              //         return Navigator.pushReplacement(
              //             context,
              //             PageTransition(
              //                 type: PageTransitionType.leftToRight,
              //                 child: Wage()));
              //       },
              //       child: Container(
              //         child: SvgPicture.asset(
              //           "images/group2773.svg",
              //           color: colorGreyTint.withOpacity(0.3),
              //         ),
              //       ),
              //     ),
              //     SizedBox(
              //       width: 18,
              //     ),
              //     GestureDetector(
              //       child: Container(
              //         child: SvgPicture.asset(
              //           "images/group2771.svg",
              //           color: colorPrimaryBlue,
              //         ),
              //       ),
              //     )
              //   ],
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 11.0),
                child: Text(
                  "Create an Investment Story",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              SizedBox(
                height: 32,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Investing with",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      height: selectedList != null
                          ? (selectedList.length != 0 ? 35 : 0)
                          : 0,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            selectedList != null ? selectedList.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          if (selectedList != null)
                            return tagWidget(
                                (selectedList[index].fname +
                                        " " +
                                        selectedList[index].lname)
                                    .trim(),
                                index,
                                selectedList[index].photoUrl);
                          else
                            return SizedBox.shrink();
                        },
                      ),
                    ),
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          search_query = value;
                          isSelected = true;
                        });
                      },
                      // onTap: () {
                      //   setState(() {
                      //     isSelected = true;
                      //   });
                      // },
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: colorPrimaryBlue)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: colorGreyTint.withOpacity(0.3))),
                          hintStyle: TextStyle(
                              color: colorGreyTint.withOpacity(0.6),
                              fontFamily: "Lato",
                              fontSize: 12,
                              letterSpacing: 0.75,
                              fontWeight: FontWeight.w300),
                          hintText: "Investing with ..."),
                    )
                  ],
                ),
              ),
              Container(
                height: isSelected ? 100 : 0,
                child: isSelected
                    ? buildSuggestions(context, search_query)
                    : SizedBox.shrink(),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Amount",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    Center(
                      child: Text(
                        amount.toString(),
                        style: TextStyle(
                            color: colorPrimaryBlue,
                            fontFamily: "Lato",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Slider(
                      value: amount.toDouble(),
                      divisions: 80,
                      label: amount.round().toString(),
                      min: 1000,
                      max: 9000,
                      activeColor: Color(0xff4dbae6),
                      inactiveColor: colorGreyTint,
                      onChanged: (value) {
                        setState(() {
                          amount = value.round();
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "1000",
                            style: TextStyle(
                                color: colorGreyTint,
                                fontFamily: "Lato",
                                fontSize: 12),
                          ),
                          Text(
                            "9000",
                            style: TextStyle(
                                color: colorGreyTint,
                                fontFamily: "Lato",
                                fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Duration",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isOne = true;
                            });
                          },
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: isOne
                                    ? colorPrimaryBlue
                                    : colorGreyTint.withOpacity(0.3)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "1 day",
                                  style: TextStyle(
                                      color:
                                          isOne ? Colors.white : Colors.black,
                                      fontSize: 12,
                                      fontFamily: "Lato"),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isOne = false;
                            });
                          },
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: isOne
                                    ? colorGreyTint.withOpacity(0.3)
                                    : colorPrimaryBlue),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "7 days",
                                  style: TextStyle(
                                      color:
                                          !isOne ? Colors.white : Colors.black,
                                      fontSize: 12,
                                      fontFamily: "Lato"),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25, top: 32),
                child: Container(
                  decoration: BoxDecoration(
                      color: colorGreyTint.withOpacity(0.03),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: colorGreyTint, width: 0.5)),
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
                                left: 24, top: 12, right: 24),
                            child: TextFormField(
                              controller: textController,
                              onChanged: (value) {
                                storyText = value;
                              },
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
                                  hintText: "Type about your post@ ...",
                                  hintStyle: TextStyle(
                                    fontFamily: "Lato",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: colorGreyTint,
                                  )),
                            ),
                          ),
                          Container(
                            height: fileList.length != 0 ? 250 : 0,
                            child: Swiper(
                                loop: false,
                                pagination: SwiperPagination(),
                                scrollDirection: Axis.horizontal,
                                itemCount: fileList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Stack(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            image: DecorationImage(
                                                image:
                                                    FileImage(fileList[index]),
                                                fit: BoxFit.cover)),
                                        height: 250,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(8)),
                                            color: Colors.red.withOpacity(0.2)),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              fileList.removeAt(index);
                                              selectedImgList.removeAt(index);
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
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 30),
                child: RoundedButton(
                  color: colorPrimaryBlue,
                  textColor: Colors.white,
                  text: "Start Earning",
                  onPressed: () async {
                    await createPost(amount.toString(), selectedImgList);
                  },
                ),
              )
            ],
          );
  }
}
