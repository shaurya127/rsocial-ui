import 'dart:convert';

import 'dart:io';

import 'package:rsocial2/user.dart';

class Post {
  Post(
      {this.investedWithUser,
      this.id,
      this.storyType,
      this.user,
      this.storyText,
      this.investedWith,
      this.investedAmount,
      this.fileUpload,
      this.reactedBy,
      this.duration,
      this.profit});

  String id;
  User user;
  String storyType;
  String storyText;
  List<String> investedWith;
  List<User> investedWithUser;
  String investedAmount;
  List<String> fileUpload;
  List<User> reactedBy;
  int duration;
  String profit;

  factory Post.fromJsonI(final json) {
    var uid = json["UserId"];
    var frnd = json['InvestedWith'];
    //print("frnd is $frnd with type ${json['StoryType']}");

    List<User> investedWith = [];
    if (json['InvestedWith'].isNotEmpty) {
      for (int i = 0; i < json['InvestedWith'].length; i++) {
        //print("reacted by $i is ${json["ReactedBy"][i]}");
        User user = User.fromJson(json['InvestedWith'][i]);
        investedWith.add(user);
      }
    }

    List<User> rxn = [];
    if (json["ReactedBy"].isNotEmpty) {
      for (int i = 0; i < json["ReactedBy"].length; i++) {
        User user = User.fromJson(json["ReactedBy"][i]);
        rxn.add(user);
      }
    }

    return Post(
        storyType: json["StoryType"],
        id: json["id"],
        user: User.fromJson(uid),
        storyText: json["StoryText"],
        investedWithUser: investedWith,
        investedAmount: json["InvestedAmount"],
        profit: json["PresentValue"].toString(),
        reactedBy: rxn,
        fileUpload: json["FileUpload"] == null
            ? []
            : List<String>.from(json["FileUpload"].map((x) => x)));
  }

  factory Post.fromJsonW(final json) {
    var uid = json["UserId"];
    List<User> rxn = [];
    if (json["ReactedBy"].isNotEmpty) {
      for (int i = 0; i < json["ReactedBy"].length; i++) {
        //print("reacted by $i is ${json["ReactedBy"][i]}");
        User user = User.fromJson(json["ReactedBy"][i]);
        rxn.add(user);
      }
    }

    return Post(
        storyType: json["StoryType"],
        id: json["id"],
        user: User.fromJson(uid),
        storyText: json["StoryText"],
        profit: json["PresentValue"].toString(),
        reactedBy: rxn,
        //investedWithUser: User.fromJson(json['InvestedWith']),
        //investedAmount: json["InvestedAmount"],
        fileUpload: json["FileUpload"] == null
            ? []
            : List<String>.from(json["FileUpload"].map((x) => x)));
  }

  Map<String, dynamic> toJsonInvest() => {
        "id": id,
        "StoryText": storyText,
        "InvestedWith": investedWith == null ? [] : this.investedWith,
        "InvestedAmount": investedAmount,
        "Duration": duration.toString(),
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
