import 'dart:convert';

import 'dart:io';

import 'package:rsocial2/user.dart';

class Post {
  Post({
    this.investedWithUser,
    this.id,
    this.storyType,
    this.user,
    this.storyText,
    this.investedWith,
    this.investedAmount,
    this.fileUpload,
  });

  String id;
  User user;
  String storyType;
  String storyText;
  String investedWith;
  User investedWithUser;
  String investedAmount;
  List<String> fileUpload;

  factory Post.fromJsonI(final json) {
    //print("userid is: ${json["UserId"]}");
    var uid = json["UserId"];
    var frnd = json['InvestedWith'];
    print("frnd is $frnd with type ${json['StoryType']}");
    //User investedWithUser = User.fromJson(uid);
    //print("haha");
    //print("person is ${investedWithUser.lollarAmount}");
    //print(User.fromJson(uid));

    return Post(
        storyType: json["StoryType"],
        id: json["id"],
        user: User.fromJson(uid),
        storyText: json["StoryText"],
        investedWithUser: User.fromJson(frnd),
        investedAmount: json["InvestedAmount"],
        fileUpload: json["FileUpload"] == null
            ? []
            : List<String>.from(json["FileUpload"].map((x) => x)));
  }

  factory Post.fromJsonW(final json) {
    //print("userid is: ${json["UserId"]}");
    var uid = json["UserId"];
    //var frnd = json['InvestedWith'];
    //print("frnd is $frnd");
    //User investedWithUser = User.fromJson(uid);
    //print("haha");
    //print("person is ${investedWithUser.lollarAmount}");
    //print(User.fromJson(uid));

    return Post(
        storyType: json["StoryType"],
        id: json["id"],
        user: User.fromJson(uid),
        storyText: json["StoryText"],
        //investedWithUser: User.fromJson(json['InvestedWith']),
        //investedAmount: json["InvestedAmount"],
        fileUpload: json["FileUpload"] == null
            ? []
            : List<String>.from(json["FileUpload"].map((x) => x)));
  }

  Map<String, dynamic> toJsonInvest() => {
        "id": id,
        "StoryText": storyText,
        "InvestedWith": investedWith == null ? "" : this.investedWith,
        "InvestedAmount": investedAmount,
        "FileUpload": fileUpload != null
            ? List<String>.from(fileUpload.map((x) => x))
            : [],
      };
  Map<String, dynamic> toJsonWage() => {
    "id": id,
    "StoryText": storyText,
    "FileUpload": fileUpload != null
        ? List<String>.from(fileUpload.map((x) => x))
        : [],
  };
}
