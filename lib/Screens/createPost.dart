import 'dart:async';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:rsocial2/Widgets/alert_box.dart';
import 'package:rsocial2/Widgets/selectButton.dart';
import 'package:rsocial2/contants/config.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:rsocial2/functions.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:video_player/video_player.dart';
import '../helper.dart';
import '../model/post.dart';
import '../model/user.dart';
import 'package:http/http.dart' as http;
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Widgets/video_player.dart' as video;
//
//

class Wage extends StatefulWidget {
  final bool looping;

  User currentUser;
  Function isPostedCallback;

  Wage({this.currentUser, this.isPostedCallback, this.looping});

  @override
  _WageState createState() => _WageState();
}

class _WageState extends State<Wage> {
  final bool play = false;
  final String url = "";
  bool boldInput = false;
  bool italics = false;
  String storytext;
  bool underline = false;
  bool isSelected = false;
  bool isPosting = false;
  File file;
  //List<String> list = [];
  List<File> fileList = [];
  List<File> fileListVideo = [];
  String orientation = "invest";
  var textController = TextEditingController();
  bool isloading = false;
  String path;
  String investmentstoryText = "";
  List<File> investmentfileList = [];
  List<File> investmentfileListvideo = [];
  // List<String> selectedImgList = [];
  // List<String> selectedvideolist = [];
  List<User> selectedList = [];
  List<String> idSelectedList = [];
  List<User> investmentlist = [];
  List<User> connections = [];
  var investmentTextController = TextEditingController();
  List<String> imageCacheIds = [];
  VideoPlayerController _videoPlayer;
  int amount = 1000;
  bool isOne = true;
  String search_query;
  TextEditingController investingWithController = TextEditingController();
  // Future<File> _cropImage(filePath) async {
  //   File croppedImage = await ImageCropper.cropImage(
  //     aspectRatio: CropAspectRatio(
  //       ratioX: 25,
  //       ratioY:25,
  //     ),
  //     sourcePath: filePath,
  //     maxWidth: 1080,
  //     maxHeight: 1080,
  //   );
  //   if (croppedImage != null) {
  //     //setState(() {});
  //     return croppedImage;
  //   }
  // }
  removeVideo() {
    setState(() {
      investmentfileListvideo.clear();
      fileListVideo.clear();
    });
    _videoPlayer.dispose();
  }

  handleVideo() async {
    var permission = Permission.camera;
    var status = await Permission.storage.status;

    if (status.isGranted) {
      try {
        PickedFile pickedFile =
            await ImagePicker().getVideo(source: ImageSource.gallery);
        if (pickedFile != null) {
          File video = File(pickedFile.path);
          video = await video.rename("${video.path}.mp4");
          if (video.lengthSync() > 500000000) {
            var alertBox = AlertDialogBox(
              title: 'Error',
              content: 'Video is too large',
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Back'),
                ),
              ],
            );
            showDialog(context: context, builder: (context) => alertBox);
            return;
          }
          _videoPlayer = VideoPlayerController.file(video);
          await _videoPlayer.initialize();
          setState(() {
            orientation == "wage"
                ? fileListVideo.add(video)
                : investmentfileListvideo.add(video);
          });
        }
      } on PlatformException catch (e) {
        if (e.code == 'photo_access_denied') {
          print(e);

          var alertBox = AlertDialogBox(
            title: "Gallery Permission",
            content: "This app needs gallery access to fetch videos",
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
          showDialog(
            context: context,
            builder: (context) => alertBox,
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      var alertBox = AlertDialogBox(
        title: "Gallery Permission",
        content: "This app needs gallery access to fetch videos",
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
    } else {
      await permission.request();
    }
  }

  handleVideocamera() async {
    var permission = Permission.camera;
    var status = await permission.status;

    if (status.isGranted) {
      try {
        PickedFile pickedFile =
            await ImagePicker().getVideo(source: ImageSource.camera);
        if (pickedFile != null) {
          File video = File(pickedFile.path);
          video = await video.rename("${video.path}.mp4");
          if (video.lengthSync() > 500000000) {
            var alertBox = AlertDialogBox(
              title: 'Error',
              content: 'Video is too large',
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Back'),
                ),
              ],
            );
            showDialog(context: context, builder: (context) => alertBox);
            return;
          }
          _videoPlayer = VideoPlayerController.file(video);
          await _videoPlayer.initialize();
          setState(() {
            orientation == "wage"
                ? fileListVideo.add(video)
                : investmentfileListvideo.add(video);
          });
        }
      } on PlatformException catch (e) {
        if (e.code == 'photo_access_denied') {
          print(e);

          var alertBox = AlertDialogBox(
            title: "Camera Permission",
            content: "This app needs camera access to capture videos",
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
          showDialog(
            context: context,
            builder: (context) => alertBox,
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      var alertBox = AlertDialogBox(
        title: "Camera Permission",
        content: "This app needs camera access to capture videos",
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
    } else {
      await permission.request();
    }
  }

  handleTakePhoto() async {
    var permission = Permission.camera;
    var status = await permission.status;
    if (status.isGranted || status.isLimited) {
      PickedFile pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        // File file = await _cropImage(pickedFile.path);
        if (file != null) {
          print("File size");
          print(file.lengthSync());

          if (file.lengthSync() > 500000000) {
            //file = await compressImage(file);
            print("New length =" + file.lengthSync().toString());

            print("not allowed");
            if (file.lengthSync() > 500000000) {
              var alertBox = AlertDialogBox(
                title: 'Error',
                content: 'Image is too large',
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Back'),
                  ),
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
            // orientation == "wage"
            //     ? list.add(img64)
            //     : selectedImgList.add(img64);
          });
        }
      }
    } else if (status.isPermanentlyDenied) {
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
    } else {
      await permission.request();
    }
  }

  //
  // Future<File> compressImage(File f) async {
  //   final tempDir = await getTemporaryDirectory();
  //   path = tempDir.path;
  //   im.Image imageFile = im.decodeImage(f.readAsBytesSync());
  //   String randomId = Uuid().v4();
  //   imageCacheIds.add(randomId);
  //   final compressedImageFile = File('$path/img_$randomId.jpg')
  //     ..writeAsBytesSync(im.encodeJpg(imageFile,
  //         quality: ((5000000 / f.lengthSync()) * 100).floor()));

  // print('$path/img_${Uuid().v4()}.jpg');

  //   return compressedImageFile;
  // }

  handleChooseFromGallery() async {
    var permission = Permission.storage;
    var status = await permission.status;
    if (status.isGranted || status.isLimited) {
      try {
        PickedFile pickedFile = await ImagePicker().getImage(
          source: ImageSource.gallery,
          // maxHeight: 675,
          // maxWidth: 960,
        );
        if (pickedFile != null) {
          File file = File(pickedFile.path);
          // File file = await _cropImage(pickedFile.path);
          //final File file = File(pickedFile.path);
          if (file != null) {
            print("File size");
            print(file.lengthSync());
            if (file.lengthSync() > 500000000) {
              print("New length =" + file.lengthSync().toString());

              print("not allowed");
              if (file.lengthSync() > 500000000) {
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
              // orientation == "wage"
              //     ? list.add(img64)
              //     : selectedImgList.add(img64);
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
    } else if (status.isPermanentlyDenied) {
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
    } else {
      await permission.request();
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

  createPostInvestment(String storytext, String investmentAmount,
      List<File> files, List<File> filevideo) async {
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

    if ((investmentstoryText == null || investmentstoryText.isEmpty) &&
        files.isEmpty &&
        filevideo.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please upload text, a photo or a video",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);
      return;
    }

    if (investmentstoryText != null) {
      // Show Modal Progress hud
      setState(() {
        isloading = true;
      });

      // Get the current Firebase user

      int n = files.length;
      int m = filevideo.length;
      var user = authFirebase.currentUser;
      // Get the user token
      var token = await user.getIdToken();

      var uid = curUser.id;
      print(uid);

      for (int i = 0; i < selectedList.length; i++) {
        idSelectedList.add(selectedList[i].id);
      }

      Post post = Post(
        id: uid,
        storyText: investmentstoryText.trim(),
        investedWith: idSelectedList,
        investedAmount: investmentAmount,
        duration: isOne ? 2 : 7,
        // fileUpload: list
      );

      // Create Investment Post

      var map = post.toJsonInvest();
      map["count_image"] = n;
      map["count_video"] = m;

      List<File> investfinal = new List();
      for (int i = 0; i < investmentfileList.length; i++) {
        investfinal.add(investmentfileList[i]);
      }
      for (int i = 0; i < investmentfileListvideo.length; i++) {
        investfinal.add(investmentfileListvideo[i]);
      }

      // Awaiting for post Response
      var response = await postFunc(
        url: storyEndPoint + "createinvestment2",
        token: token,
        body: jsonEncode(map),
      );
      // if()
      print(map);

      if (response == null) {
        setState(() {
          isloading = false;
          isPosting = false;
        });
        Fluttertoast.showToast(
            msg: "Error occurred, please check Internet connection.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);
        return;
      }

      var body = json.decode(response.body);
      var x = body["body"];
      // print(x.runtimeType);
      var b = json.decode(x);
      x = b["presigned"];

      for (var i = 0; i < x.length; i++) {
        var y = x[i]["fields"];
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(x[i]["url"]),
        );
        request.files.add(
          http.MultipartFile(
            'file',
            investfinal[i].readAsBytes().asStream(),
            investfinal[i].lengthSync(),
            filename: (investfinal[i].path),
            // contentType: MediaType(
            //   'image',
            //   'jpeg',
            // ),
          ),
        );
        // request.files.add(
        //   http.MultipartFile(
        //     'file',
        //     files[i].readAsBytes().asStream(),
        //     files[i].lengthSync(),
        //     filename: (files[i].path),
        //     contentType: MediaType(
        //       'video',
        //       'mp3',
        //     ),
        //   ),
        // );

        // request.fields
        request.fields.addAll({
          "key": y["key"],
          "x-amz-algorithm": y["x-amz-algorithm"],
          "x-amz-credential": y["x-amz-credential"],
          "x-amz-date": y["x-amz-date"],
          "x-amz-security-token": y["x-amz-security-token"],
          "policy": y["policy"],
          "x-amz-signature": y["x-amz-signature"],
        });

        var res = await request.send();
      }

      // Response is null if some exception occurred while posting, for eg - Lost internet connection
      if (response == null) {
        setState(() {
          isloading = false;
          isPosting = false;
        });
        Fluttertoast.showToast(
            msg: "Error occurred, please check Internet connection.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);
        return;
      }

      if (response.statusCode == 200) {
        print('Response body is: ${response.body}');
        investmentTextController.clear();

        // After successful response restore defaults
        setState(() {
          amount = 1000;
          investmentfileList.clear();
          investmentfileListvideo.clear();
          // selectedImgList.clear();
          idSelectedList.clear();
          isloading = false;
          selectedList.clear();
        });

        // Remove all the cached images
        if (imageCacheIds.length != 0) {
          for (String i in imageCacheIds) {
            try {
              await File('$path/img_$i.jpg').delete();
            } catch (e) {}
          }
        }

        // Move to the Landing Page
        widget.isPostedCallback();

        // Show User that story has been successfully posted
        Fluttertoast.showToast(
            msg: "Uploaded investment story!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);
      } else {
        print(response.statusCode);

        Fluttertoast.showToast(
            msg: "Some error occurred",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15);

        setState(() {
          isloading = false;
        });
      }
    }
  }

  @override
  void initState() {
    // super.initState();
    //

    super.initState();
    FirebaseAnalytics().setCurrentScreen(screenName: "post");

    const oneSec = const Duration(seconds: 1);

    Timer.periodic(oneSec, (Timer timer) {
      print("timer");
      print(curUser);
      if (curUser != null) {
        timer.cancel();
        print("Timer cancelled");
        getFriends();
        setState(() {});
      }
    });

    getFriends();
  }

  @override
  void dispose() {
    // widget.videoPlayerController.dispose();
    // _chewieController.dispose();
    super.dispose();
  }

  createWagePost(
      String storyText, List<File> files, List<File> filevideo) async {
    if ((storyText == null || storyText.isEmpty) &&
        files.isEmpty &&
        filevideo.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please upload text, a photo or a video",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);
      return;
    }
    // if(storytext==null )

    // Show Modal Progress hud
    setState(() {
      isloading = true;
    });

    var user = authFirebase.currentUser;
    var token = await user.getIdToken();

    var uid = curUser.id;
    // Creating Post
    Post post = Post(id: uid, storyText: storyText);
    var map = post.toJsonWage();

    int n = files.length;
    int m = filevideo.length;
    map["count_image"] = n;
    map["count_video"] = m;

    List<File> investfinalwage = new List();
    for (int i = 0; i < fileList.length; i++) {
      investfinalwage.add(fileList[i]);
    }
    for (int i = 0; i < fileListVideo.length; i++) {
      investfinalwage.add(fileListVideo[i]);
    }

    // Awaiting for post Response
    var response = await postFunc(
        url: storyEndPoint + "createwage2",
        token: token,
        body: jsonEncode(map));

    print(map);

    if (response == null) {
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
    var body = json.decode(response.body);
    // print(body);

    // var response2=await http.get(body["url"]);
    var x = body["body"];
    print(x.runtimeType);
    var b = json.decode(x);
    x = b["presigned"];
    // print(x
    for (var i = 0; i < x.length; i++) {
      var y = x[i]["fields"];
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(x[i]["url"]),
      );
      request.files.add(
        http.MultipartFile(
          'file',
          investfinalwage[i].readAsBytes().asStream(),
          investfinalwage[i].lengthSync(),
          filename: (investfinalwage[i].path),
          // contentType: MediaType('image', 'jpeg'),
        ),
      );
      // request.fields
      request.fields.addAll({
        "key": y["key"],
        "x-amz-algorithm": y["x-amz-algorithm"],
        "x-amz-credential": y["x-amz-credential"],
        "x-amz-date": y["x-amz-date"],
        "x-amz-security-token": y["x-amz-security-token"],
        "policy": y["policy"],
        "x-amz-signature": y["x-amz-signature"],
      });

      var res = await request.send();

      // print(x[i]);
    }

    // Response is null if some exception occurred while posting, for eg - Lost internet connection
    if (response == null) {
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

    if (response.statusCode == 200) {
      print('Response body is: ${response.body}');

      // Restore defaults
      textController.clear();
      setState(() {
        fileList.clear();
        fileListVideo.clear();
        isloading = false;
      });

      // Show user that the wage story is successfully posted
      Fluttertoast.showToast(
          msg: "Uploaded wassup story!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);

      // Clear the image caches used for compression
      if (imageCacheIds.length != 0) {
        for (String i in imageCacheIds) {
          try {
            await File('$path/img_$i.jpg').delete();
          } catch (e) {}
        }
      }

      // Move to landing page
      widget.isPostedCallback();
    } else {
      Fluttertoast.showToast(
          msg: "Some error occurred",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 15);
      setState(() {
        isloading = false;
      });

      print(response.statusCode);
    }
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
    if (curUser != null) this.investmentlist = curUser.connection;

    // while (curUser == null) {
    //   setState(() {});
    // }
  }

  buildInvestment() {
    return curUser == null
        ? Center(
            child: Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: CircularProgressIndicator(),
          ))
        : curUser.totalAvailableYollar < 1000
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "You need ",
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SvgPicture.asset(
                        "images/yollar.svg",
                        height: 18,
                        color: colorPrimaryBlue,
                      ),
                      Text(
                        (1000 - curUser.totalAvailableYollar).toString() +
                            " more to start investing!",
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
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
                              selectedList == null || selectedList.length == 0
                                  ? 0
                                  : 12,
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
                                  borderSide:
                                      BorderSide(color: colorPrimaryBlue)),
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
                  curUser.totalAvailableYollar >= 1000
                      ? Padding(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                          formatNumber(
                                              curUser.totalAvailableYollar),
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
                                max: curUser.totalAvailableYollar.toDouble(),
                                activeColor: colorPrimaryBlue,
                                inactiveColor: colorGreyTint,
                                onChanged: (value) {
                                  setState(() {
                                    if (value <= curUser.lollarAmount)
                                      amount = ((value.round() / 1000).floor() *
                                          1000);
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 24),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: <Widget>[
                  //       Text(
                  //         "Duration",
                  //         textAlign: TextAlign.left,
                  //         style: TextStyle(
                  //             fontFamily: "Lato",
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.w700),
                  //       ),
                  //       SizedBox(
                  //         height: 12,
                  //       ),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: <Widget>[
                  //           GestureDetector(
                  //             onTap: () {
                  //               setState(() {
                  //                 isOne = true;
                  //               });
                  //             },
                  //             child: Container(
                  //               width: 60,
                  //               decoration: BoxDecoration(
                  //                   borderRadius:
                  //                       BorderRadius.all(Radius.circular(8)),
                  //                   color: isOne
                  //                       ? colorPrimaryBlue
                  //                       : colorGreyTint.withOpacity(0.3)),
                  //               child: Padding(
                  //                 padding: const EdgeInsets.all(8.0),
                  //                 child: Center(
                  //                   child: Text(
                  //                     "1 day",
                  //                     style: TextStyle(
                  //                         color:
                  //                             isOne ? Colors.white : Colors.black,
                  //                         fontSize: 12,
                  //                         fontFamily: "Lato"),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           SizedBox(
                  //             width: 20,
                  //           ),
                  //           GestureDetector(
                  //             onTap: () {
                  //               setState(() {
                  //                 isOne = false;
                  //               });
                  //             },
                  //             child: Container(
                  //               width: 60,
                  //               decoration: BoxDecoration(
                  //                   borderRadius:
                  //                       BorderRadius.all(Radius.circular(8)),
                  //                   color: isOne
                  //                       ? colorGreyTint.withOpacity(0.3)
                  //                       : colorPrimaryBlue),
                  //               child: Padding(
                  //                 padding: const EdgeInsets.all(8.0),
                  //                 child: Center(
                  //                   child: Text(
                  //                     "7 days",
                  //                     style: TextStyle(
                  //                         color:
                  //                             !isOne ? Colors.white : Colors.black,
                  //                         fontSize: 12,
                  //                         fontFamily: "Lato"),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           )
                  //         ],
                  //       )
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 25.0, right: 25, top: 32),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: colorGreyTint.withOpacity(0.03),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: colorGreyTint, width: 0.5)),
                      child: Column(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 24, top: 12, right: 24),
                                child: TextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
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
                                  maxLength: 200,
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
                              if (investmentfileList.isNotEmpty)
                                Container(
                                    constraints: BoxConstraints(maxHeight: 300),
                                    child: investmentfileList.length > 1
                                        ? Swiper(
                                            control: SwiperControl(
                                              color: Colors.black,
                                              disableColor: Colors.transparent,
                                            ),
                                            loop: false,
                                            pagination: SwiperPagination(
                                              builder:
                                                  DotSwiperPaginationBuilder(
                                                      color: Colors.grey,
                                                      activeColor: colorButton,
                                                      size: 13.0,
                                                      activeSize: 15.0,
                                                      space: 5.0),
                                            ),
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                investmentfileList.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Stack(
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: colorGreyTint
                                                            .withOpacity(0.03),
                                                        image: DecorationImage(
                                                            image: FileImage(
                                                                investmentfileList[
                                                                    index]),
                                                            fit: BoxFit
                                                                .contain)),
                                                  ),
                                                  Positioned(
                                                    right: 10,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            8)),
                                                      ),
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons.clear,
                                                          color: Colors.black,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            investmentfileList
                                                                .removeAt(
                                                                    index);
                                                            // selectedImgList
                                                            //     .removeAt(index);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          )
                                        : Stack(
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 35, bottom: 10),
                                                child: Image.file(
                                                  investmentfileList[0],
                                                  fit: BoxFit.contain,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colorGreyTint
                                                      .withOpacity(0.03),
                                                ),
                                              ),
                                              Positioned(
                                                right: 5,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomRight:
                                                                Radius.circular(
                                                                    8)),
                                                  ),
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.clear,
                                                      color: Colors.black,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        investmentfileList
                                                            .removeAt(0);
                                                        // selectedImgList
                                                        //     .removeAt(index);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                              if (investmentfileListvideo.isNotEmpty)
                                video.VideoPlayer(investmentfileListvideo[0],
                                    _videoPlayer, removeVideo),
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
                                  if (investmentfileList != null &&
                                      investmentfileList.length > 15) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You can upload a maximum of 15 photos",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: 15);
                                    return;
                                  }
                                  if (investmentfileListvideo.isNotEmpty) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You can upload either a video or some photos",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: 15);
                                    return;
                                  }
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
                                  if (investmentfileList != null &&
                                      investmentfileList.length > 15) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You can upload a maximum of 15 photos",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: 15);
                                    return;
                                  }
                                  if (investmentfileListvideo.isNotEmpty) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You can upload either a video or some photos",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: 15);
                                    return;
                                  }

                                  handleTakePhoto();
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.videocam,
                                  color: colorGreyTint,
                                  size: 23,
                                ),
                                onPressed: () {
                                  if (investmentfileList.isNotEmpty) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You can upload either a video or some photos",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: 15);
                                    return;
                                  }
                                  if (investmentfileListvideo != null &&
                                      investmentfileListvideo.length == 1) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You have already selected a video",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: 15);
                                    return;
                                  }
                                  handleVideo();
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.camera_front,
                                  color: colorGreyTint,
                                  size: 23,
                                ),
                                onPressed: () {
                                  if (investmentfileList.isNotEmpty) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You can upload either a video or some photos",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: 15);
                                    return;
                                  }
                                  if (investmentfileListvideo != null &&
                                      investmentfileListvideo.length == 1) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You have already selected a video",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: 15);
                                    return;
                                  }
                                  handleVideocamera();
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  if ((curUser == null
                          ? savedUser.connectionCount
                          : curUser.connectionCount) !=
                      0)
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
                            "${formatNumber(curUser == null ? savedUser.connectionCount : curUser.connectionCount)}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Lato"),
                          ),
                        ],
                      ),
                    ),
                  if ((curUser == null
                          ? savedUser.connectionCount
                          : curUser.connectionCount) ==
                      0)
                    SizedBox(
                      height: 60,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: RoundedButton(
                      color: colorPrimaryBlue,
                      textColor: Colors.white,
                      text: "Start Earning",
                      onPressed: () async {
                        print("click");

                        if (curUser.totalAvailableYollar < 1000) {
                          Fluttertoast.showToast(
                              msg: "Earn more than 1000 to invest",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              fontSize: 15);
                          return;
                        }

                        await createPostInvestment(storytext, amount.toString(),
                            investmentfileList, investmentfileListvideo);
                      },
                    ),
                  )
                ],
              );
  }

  buildWage() {
    return Column(
      children: <Widget>[
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
                        textCapitalization: TextCapitalization.sentences,
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
                        maxLength: 200,
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
                    if (fileList.isNotEmpty)
                      Container(
                          constraints: BoxConstraints(maxHeight: 300),
                          child: fileList.length > 1
                              ? Swiper(
                                  control: SwiperControl(
                                    color: Colors.black,
                                    disableColor: Colors.transparent,
                                  ),
                                  loop: false,
                                  pagination: SwiperPagination(
                                    builder: DotSwiperPaginationBuilder(
                                        color: Colors.grey,
                                        activeColor: colorButton,
                                        size: 13.0,
                                        activeSize: 15.0,
                                        space: 5.0),
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: fileList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Stack(
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                              color: colorGreyTint
                                                  .withOpacity(0.03),
                                              image: DecorationImage(
                                                  image: FileImage(
                                                      fileList[index]),
                                                  fit: BoxFit.contain)),
                                        ),
                                        Positioned(
                                          right: 10,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(8)),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                color: Colors.black,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  fileList.removeAt(index);
                                                  // selectedImgList
                                                  //     .removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : Stack(
                                  children: <Widget>[
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 35, bottom: 10),
                                      child: Image.file(
                                        fileList[0],
                                        fit: BoxFit.contain,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorGreyTint.withOpacity(0.03),
                                      ),
                                    ),
                                    Positioned(
                                      right: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(8)),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              fileList.removeAt(0);
                                              // selectedImgList
                                              //     .removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                    if (fileListVideo.isNotEmpty)
                      video.VideoPlayer(
                          fileListVideo[0], _videoPlayer, removeVideo),
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
                        if (fileList != null && fileList.length > 15) {
                          Fluttertoast.showToast(
                              msg: "You can upload a maximum of 15 photos",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              fontSize: 15);
                          return;
                        }
                        if (fileListVideo.isNotEmpty) {
                          Fluttertoast.showToast(
                              msg:
                                  "You can upload either a video or some photos",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              fontSize: 15);
                          return;
                        }
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
                        if (fileList != null && fileList.length > 15) {
                          Fluttertoast.showToast(
                              msg: "You can upload a maximum of 15 photos",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              fontSize: 15);
                          return;
                        }
                        if (fileListVideo.isNotEmpty) {
                          Fluttertoast.showToast(
                              msg:
                                  "You can upload either a video or some photos",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              fontSize: 15);
                          return;
                        }
                        handleTakePhoto();
                        // handleTakeVideo();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.videocam,
                        color: colorGreyTint,
                        size: 23,
                      ),
                      onPressed: () {
                        if (fileList.isNotEmpty) {
                          Fluttertoast.showToast(
                              msg:
                                  "You can upload either a video or some photos",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              fontSize: 15);
                          return;
                        }
                        if (fileListVideo != null &&
                            fileListVideo.length == 1) {
                          Fluttertoast.showToast(
                              msg: "You have already selected a video",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              fontSize: 15);
                          return;
                        }
                        handleVideo();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.camera_front,
                        color: colorGreyTint,
                        size: 23,
                      ),
                      onPressed: () {
                        if (fileList.isNotEmpty) {
                          Fluttertoast.showToast(
                              msg:
                                  "You can upload either a video or some photos",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              fontSize: 15);
                          return;
                        }
                        if (fileListVideo != null &&
                            fileListVideo.length == 1) {
                          Fluttertoast.showToast(
                              msg: "You have already selected a video",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              fontSize: 15);
                          return;
                        }
                        handleVideocamera();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        if ((curUser == null
                ? savedUser.connectionCount
                : curUser.connectionCount) !=
            0)
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
                  "${formatNumber(curUser == null ? savedUser.connectionCount : curUser.connectionCount)}",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Lato"),
                ),
              ],
            ),
          ),
        if ((curUser == null
                ? savedUser.connectionCount
                : curUser.connectionCount) ==
            0)
          SizedBox(
            height: 60,
          ),
        RoundedButton(
          color: colorPrimaryBlue,
          textColor: Colors.white,
          text: "Time to Brag",
          onPressed: () {
            storytext = textController.text;
            createWagePost(storytext.trim(), fileList, fileListVideo);
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
                            text: "Invest",
                            orientation: "invest",
                            curOrientation: orientation),
                        SelectButton(
                            onTap: () {
                              setState(() {
                                orientation = "wage";
                              });
                            },
                            text: "Wassup",
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
