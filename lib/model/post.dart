import 'dart:convert';

import 'dart:io';

import 'user.dart';
import 'package:timeago/timeago.dart' as timeago;

var locale = 'en';

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
      this.profit,
      this.createdOn,
      this.canReact});

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
  String createdOn;
  bool canReact;

  factory Post.fromJsonI(final json) {
    var uid = json["UserId"];
    var frnd = json['InvestedWith'];
    final diff = DateTime.now().difference(DateTime.parse(json['PostedOn']));
    final txt = timeago.format(DateTime.now().subtract(diff), locale: locale);
    var expiringOnDiff =
        DateTime.now().difference(DateTime.parse(json['ExpiringOn'])).isNegative
            ? false
            : true;

    List<User> investedWith = [];
    if (json['InvestedWith'].isNotEmpty) {
      for (int i = 0; i < json['InvestedWith'].length; i++) {
        User user = User.fromJson(json['InvestedWith'][i]);
        investedWith.add(user);
      }
    }

    List<User> rxn = [];
    if (json["ReactedBy"] != null) if (json["ReactedBy"].isNotEmpty) {
      for (int i = 0; i < json["ReactedBy"].length; i++) {
        User user = User.fromJson(json["ReactedBy"][i]);
        rxn.add(user);
      }
    }

    return Post(
        storyType: json["StoryType"],
        id: json["id"],
        canReact: expiringOnDiff,
        user: User.fromJson(uid),
        storyText: json["StoryText"],
        investedWithUser: investedWith,
        investedAmount: json["InvestedAmount"],
        profit: json["PresentValue"].toString(),
        reactedBy: rxn,
        createdOn: txt,
        fileUpload: json["FileUpload"] == null
            ? []
            : List<String>.from(json["FileUpload"].map((x) => x)));
  }

  factory Post.fromJsonW(final json) {
    final diff = DateTime.now().difference(DateTime.parse(json['PostedOn']));
    final txt = timeago.format(DateTime.now().subtract(diff), locale: locale);
    print(txt);
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
        createdOn: txt,
        canReact: true,
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

  Map<String, dynamic> toJsonInvestDao() => {
        "id": id,
        "StoryText": storyText,
        "InvestedWith": investedWith == null ? [] : this.investedWith,
        "InvestedAmount": investedAmount,
        "Duration": duration.toString(),
        "FileUpload": fileUpload != null
            ? List<String>.from(fileUpload.map((x) => x))
            : [],
        "PresentValue": profit,
        "ReactedBy": reactedBy,
        "createdOn": createdOn,
        "StoryType": storyType,
        "Owner": user,
      };

  Map<String, dynamic> toJsonWageDao() => {
        "id": id,
        "StoryText": storyText,
        "FileUpload": fileUpload != null
            ? List<String>.from(fileUpload.map((x) => x))
            : [],
        "PresentValue": profit,
        "ReactedBy": reactedBy,
        "createdOn": createdOn,
        "StoryType": storyType,
        "Owner": user,
      };

  Map<String, dynamic> toJsonWage() => {
        "id": id,
        "StoryText": storyText,
        "FileUpload": fileUpload != null
            ? List<String>.from(fileUpload.map((x) => x))
            : [],
      };
}
