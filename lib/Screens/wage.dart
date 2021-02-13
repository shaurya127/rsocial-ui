import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/Widgets/selectButton.dart';
import 'file:///D:/Flutter/rsocial_ui/lib/contants/config.dart';
import 'file:///D:/Flutter/rsocial_ui/lib/contants/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rsocial2/Screens/investment.dart';
import 'package:rsocial2/functions.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:path_provider/path_provider.dart';
import '../model/post.dart';
import '../model/user.dart';
import 'investment.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as im;

class Wage extends StatefulWidget {
  User currentUser;
  Function isPostedCallback;

  Wage({this.currentUser, this.isPostedCallback});

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
  String orientation = "invest";
  var textController = new TextEditingController();
  bool isloading = false;
  String path;
  String investmentstoryText = "";
  List<File> investmentfileList = new List();
  List<String> selectedImgList = new List();
  List<User> selectedList = new List();
  List<String> idSelectedList = new List();
  List<User> investmentlist = new List();
  List<User> connections = [];
  var investmentTextController = new TextEditingController();
  List<String> imageCacheIds = [];

  int amount = 1000;
  bool isOne = true;

  String search_query;
  TextEditingController investingWithController = TextEditingController();

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

  handleTakePhoto() async {
    // File file = await ImagePicker.pickImage(
    //   source: ImageSource.camera,
    //   maxHeight: 675,
    //   maxWidth: 960,
    // );
    var status = await Permission.camera.status;

    if (status.isGranted || status.isUndetermined) {
      PickedFile pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        // maxHeight: 675,
        // maxWidth: 960,
      );
      if (pickedFile != null) {
        File file = await _cropImage(pickedFile.path);
        if (file != null) {
          print("File size");
          print(file.lengthSync());

          if (file.lengthSync() > 5000000) {
            //  if (file.lengthSync() > 5000000) {
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

          final bytes = file.readAsBytesSync();
          String img64 = base64Encode(bytes);
          setState(() {
            orientation == "wage"
                ? fileList.add(file)
                : investmentfileList.add(file);
            orientation == "wage"
                ? list.add(img64)
                : selectedImgList.add(img64);
          });
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

  Future<File> compressImage(File f) async {
    final tempDir = await getTemporaryDirectory();
    path = tempDir.path;
    im.Image imageFile = im.decodeImage(f.readAsBytesSync());
    String randomId = Uuid().v4();
    imageCacheIds.add(randomId);
    final compressedImageFile = File('$path/img_$randomId.jpg')
      ..writeAsBytesSync(im.encodeJpg(imageFile,
          quality: ((5000000 / f.lengthSync()) * 100).floor()));

    // print('$path/img_${Uuid().v4()}.jpg');

    return compressedImageFile;
  }

  handleChooseFromGallery() async {
    var status = await Permission.storage.status;

    if (status.isGranted || status.isUndetermined) {
      try {
        PickedFile pickedFile = await ImagePicker().getImage(
          source: ImageSource.gallery,
          // maxHeight: 675,
          // maxWidth: 960,
        );
        if (pickedFile != null) {
          File file = await _cropImage(pickedFile.path);
          //final File file = File(pickedFile.path);
          if (file != null) {
            print("File size");
            print(file.lengthSync());

            if (file.lengthSync() > 5000000) {
              //  if (file.lengthSync() > 5000000) {
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
            final bytes = file.readAsBytesSync();
            String img64 = base64Encode(bytes);
            setState(() {
              orientation == "wage"
                  ? fileList.add(file)
                  : investmentfileList.add(file);
              orientation == "wage"
                  ? list.add(img64)
                  : selectedImgList.add(img64);
            });
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
    //  print(list);
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

  createPostInvestment(String investmentAmount, List<String> list) async {
    if (selectedList.isEmpty) {
      Fluttertoast.showToast(
          msg: "You must invest with a bond",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);
      return;
    }

    if (double.parse(investmentAmount) == 0) {
      Fluttertoast.showToast(
          msg: "Investment amount cannot be 0",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);

      return;
    }

    if (investmentstoryText == null && investmentfileList.isEmpty ||
        (investmentstoryText.isEmpty && investmentfileList.isEmpty)) {
      Fluttertoast.showToast(
          msg: "Please upload text or photo",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);
      return;
    }

    if (investmentstoryText != null || investmentfileList.isNotEmpty) {
      setState(() {
        isloading = true;
      });
      var url = storyEndPoint + "createinvestment";
      var user = await FirebaseAuth.instance.currentUser();
      var uid = curUser.id;

      for (int i = 0; i < selectedList.length; i++) {
        idSelectedList.add(selectedList[i].id);
      }

      Post post = Post(
          id: uid,
          storyText: investmentstoryText.trim(),
          investedWith: idSelectedList,
          investedAmount: investmentAmount,
          duration: isOne ? 1 : 7,
          fileUpload: list);
      var token = await user.getIdToken();
      print(jsonEncode(post.toJsonInvest()));
      //print(token);

      var response;
      try {
        response = await http.post(
          url,
          encoding: Encoding.getByName("utf-8"),
          body: jsonEncode(post.toJsonInvest()),
          headers: {
            "Authorization": "Bearer: $token",
            "Content-Type": "application/json",
          },
        );
      } catch (e) {
        setState(() {
          isloading = false;
        });
        Fluttertoast.showToast(
            msg: "Error occurred, please check Internet connection.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);
        return;
      }

      print(response.statusCode);
      print(response.reasonPhrase);

      if (response.statusCode == 200) {
        print('Response body is: ${response.body}');
        investmentTextController.clear();
        setState(() {
          amount = 1000;
          investmentfileList.clear();
          selectedImgList.clear();
          idSelectedList.clear();
          isloading = false;
          selectedList.clear();
        });

        if (imageCacheIds.length != 0) {
          for (String i in imageCacheIds) {
            try {
              await File('$path/img_$i.jpg').delete();
            } catch (e) {}
          }
        }

        widget.isPostedCallback();
        Fluttertoast.showToast(
            msg: "Uploaded investment story!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);
      } else {
        print(response.statusCode);
        setState(() {
          isloading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "post");
    getFriends();
  }

  createPost(String storyText, List<String> list) async {
    if (storyText == null || storyText.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please enter text and upload pic",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);
      return;
    }

    if (storyText != null) {
      setState(() {
        isloading = true;
      });
      var url = storyEndPoint + "createwage";
      var user = await FirebaseAuth.instance.currentUser();
      // DocumentSnapshot doc = await users.document(user.uid).get();
      // if (doc == null) {
      //   print("Doc is null in create Post in wage.dart");
      //   throw Exception();
      // }
      // var uid = doc['id'];
      //print(uid);
      var uid = curUser.id;
      print(storyText);
      print("Post starts");
      Post post = Post(id: uid, storyText: storyText, fileUpload: list);
      var token = await user.getIdToken();
      print(jsonEncode(post.toJsonWage()));
      print(token);

      var response;
      try {
        response = await http.post(
          url,
          encoding: Encoding.getByName("utf-8"),
          body: jsonEncode(post.toJsonWage()),
          headers: {
            "Authorization": "Bearer: $token",
            "Content-Type": "application/json",
          },
        );
      } catch (e) {
        setState(() {
          isloading = false;
        });
        Fluttertoast.showToast(
            msg: "Error occurred, please check Internet connection.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);
        return;
      }

      print(response.statusCode);

      if (response.statusCode == 200) {
        print('Response body is: ${response.body}');
        textController.clear();
        setState(() {
          fileList.clear();
          isloading = false;
        });
        Fluttertoast.showToast(
            msg: "Uploaded wage story!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);
        if (imageCacheIds.length != 0) {
          for (String i in imageCacheIds) {
            try {
              await File('$path/img_$i.jpg').delete();
            } catch (e) {}
          }
        }
        widget.isPostedCallback();
      } else {
        setState(() {
          isloading = false;
        });

        print(response.statusCode);
      }
    } else
      setState(() {
        print("Empty");
        isloading = false;
      });
  }

  Widget buildSuggestions(BuildContext context, String query) {
    // show when someone searches for something

    final suggestionList =
        query == null || query.isEmpty || investmentlist.isEmpty
            ? investmentlist
            : investmentlist
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
            if (!selectedList.contains(suggestionList[index])
                //&&
                //selectedList.length == 0

                ) {
              selectedList.clear();
              selectedList.add(suggestionList[index]);
              investingWithController.clear();
            } else {
              investingWithController.clear();
              Fluttertoast.showToast(
                  msg: "You can only invest with one bond",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  fontSize: 15);
            }
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

  void getFriends() async {
    // var user = await FirebaseAuth.instance.currentUser();
    // //
    // // // Getting doc from firebase
    // DocumentSnapshot doc = await users.document(user.uid).get();
    // // // Getting id of current user from firebase
    // var id = doc['id'];
    // //
    // final url = userEndPoint + "$id";
    // //
    // var token = await user.getIdToken();
    // //
    // final response = await http.get(url, headers: {
    //   "Authorization": "Bearer $token",
    //   "Content-Type": "application/json",
    // });
    // User curUser;
    // print(response.statusCode);
    // if (response.statusCode == 200) {
    //   final jsonUser = jsonDecode(response.body);
    //   var body = jsonUser['body'];
    //   var body1 = jsonDecode(body);
    //   var msg = body1['message'];
    //   print("These are my connections");
    //   print(msg);
    //   curUser = User.fromJson(msg);
    // }
    this.investmentlist = curUser.connection;
    // if (connections.isNotEmpty) {
    //   for (int i = 0; i < connections.length; i++) {
    //     User user = User.fromJson(connections[i]);
    //     this.list.add(user);
    //   }
  }

  buildInvestment() {
    return Column(
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
        // Padding(
        //   padding: const EdgeInsets.only(top: 11.0),
        //   child: Text(
        //     "Create an Investment Story",
        //     style: TextStyle(
        //         color: Colors.black,
        //         fontFamily: "Lato",
        //         fontWeight: FontWeight.bold,
        //         fontSize: 15),
        //   ),
        //),
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
                height:
                    selectedList == null || selectedList.length == 0 ? 0 : 12,
              ),
              Container(
                height: selectedList != null
                    ? (selectedList.length != 0 ? 35 : 0)
                    : 0,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedList != null ? selectedList.length : 0,
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
                controller: investingWithController,
                onChanged: (value) {
                  setState(() {
                    search_query = value;
                    if (search_query.isEmpty)
                      isSelected = false;
                    else
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
                        borderSide:
                            BorderSide(color: colorGreyTint.withOpacity(0.3))),
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
                  formatNumber(amount),
                  style: TextStyle(
                      color: colorPrimaryBlue,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        SvgPicture.asset(
                          "images/yollar.svg",
                          color: colorPrimaryBlue,
                          height: 20,
                        ),
                        Text(
                          "1000",
                          style: TextStyle(
                              color: colorGreyTint,
                              fontFamily: "Lato",
                              fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          "images/yollar.svg",
                          color: colorPrimaryBlue,
                          height: 20,
                        ),
                        Text(
                          formatNumber(curUser.lollarAmount),
                          style: TextStyle(
                              color: colorGreyTint,
                              fontFamily: "Lato",
                              fontSize: 12),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Slider(
                value: amount.toDouble(),
                divisions: 80,
                label: amount.round().toString(),
                min: 1000,
                max: curUser.lollarAmount.toDouble(),
                activeColor: colorPrimaryBlue,
                inactiveColor: colorGreyTint,
                onChanged: (value) {
                  setState(() {
                    if (value <= curUser.lollarAmount) amount = value.round();
                  });
                },
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
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: isOne
                              ? colorPrimaryBlue
                              : colorGreyTint.withOpacity(0.3)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "1 day",
                            style: TextStyle(
                                color: isOne ? Colors.white : Colors.black,
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
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: isOne
                              ? colorGreyTint.withOpacity(0.3)
                              : colorPrimaryBlue),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "7 days",
                            style: TextStyle(
                                color: !isOne ? Colors.white : Colors.black,
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
                      padding:
                          const EdgeInsets.only(left: 24, top: 12, right: 24),
                      child: TextFormField(
                        controller: investmentTextController,
                        onChanged: (value) {
                          investmentstoryText = value;
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
                      height: investmentfileList.length != 0 ? 250 : 0,
                      child: Swiper(
                          loop: false,
                          pagination: SwiperPagination(),
                          scrollDirection: Axis.horizontal,
                          itemCount: investmentfileList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Stack(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      color: colorPrimaryBlue,
                                      image: DecorationImage(
                                          image: FileImage(
                                              investmentfileList[index]),
                                          fit: BoxFit.fill)),
                                  height: 250,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(8)),
                                      color: colorPrimaryBlue),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        investmentfileList.removeAt(index);
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

        Padding(
          padding: EdgeInsets.only(top: 60, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Earn: ",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lato"),
              ),
              SvgPicture.asset(
                "images/yollar.svg",
                color: colorPrimaryBlue,
                height: 20,
              ),
              SizedBox(
                width: 1,
              ),
              Text(
                "${formatNumber(curUser.connection.length)}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lato"),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: RoundedButton(
            color: colorPrimaryBlue,
            textColor: Colors.white,
            text: "Start Earning",
            onPressed: () async {
              await createPostInvestment(amount.toString(), selectedImgList);
            },
          ),
        )
      ],
    );
  }

  buildWage() {
    return Column(
      children: <Widget>[
        // Padding(
        //   padding: const EdgeInsets.only(top: 11.0),
        //   child: Text(
        //     "Create a Wage Story",
        //     style: TextStyle(
        //         color: Colors.black,
        //         fontFamily: "Lato",
        //         fontWeight: FontWeight.bold,
        //         fontSize: 15),
        //   ),
        // ),
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
                      padding:
                          const EdgeInsets.only(left: 24, top: 12, right: 24),
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
                                      color: colorPrimaryBlue,
                                      image: DecorationImage(
                                          image: FileImage(fileList[index]),
                                          fit: BoxFit.cover)),
                                  height: 250,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(8)),
                                      color: colorPrimaryBlue),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        fileList.removeAt(index);
                                        list.removeAt(index);
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
          padding: EdgeInsets.only(top: 60, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Earn: ",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lato"),
              ),
              SvgPicture.asset(
                "images/yollar.svg",
                color: colorPrimaryBlue,
                height: 20,
              ),
              SizedBox(
                width: 1,
              ),
              Text(
                "${curUser.connection.length}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lato"),
              ),
            ],
          ),
        ),
        RoundedButton(
          color: colorPrimaryBlue,
          textColor: Colors.white,
          text: "Time to Brag",
          onPressed: () {
            storytext = textController.text;
            createPost(storytext.trim(), list);
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        //appBar: customAppBar(context, "Get Set Earn"),
        body:
            // isLoading
            //     ? Center(child: CircularProgressIndicator())
            //     :
            ModalProgressHUD(
          inAsyncCall: isloading,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SelectButton(
                            onTap: () {
                              setState(() {
                                orientation = "invest";
                              });
                            },
                            text: "Investment",
                            orientation: "invest",
                            curOrientation: orientation),
                        SelectButton(
                            onTap: () {
                              setState(() {
                                orientation = "wage";
                              });
                            },
                            text: "Wage",
                            orientation: "wage",
                            curOrientation: orientation),
                      ],
                    ),
                    orientation == "wage" ? buildWage() : buildInvestment()
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
