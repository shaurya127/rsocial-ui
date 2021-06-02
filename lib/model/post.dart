import 'dart:convert';

import 'dart:io';

import 'user.dart';

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
      this.duration,
      this.profit,
      this.createdOn,
      this.canReact,
      this.reactions,
      this.userReaction});

  String id;
  User user;
  String storyType;
  String storyText;
  List<String> investedWith;
  List<User> investedWithUser;
  String investedAmount;
  List<String> fileUpload;
  List<int> reactions = [0, 0, 0, 0];
  int duration;
  String profit;
  String createdOn;
  bool canReact;
  String userReaction;
  factory Post.fromJsonI(final json) {
    var uid = json["UserId"];
    final diff = DateTime.now().difference(DateTime.parse(json['PostedOn']));
    final time = getTimeSinceNotification(diff);
    var expiringOnDiff =
        DateTime.now().difference(DateTime.parse(json['ExpiringOn'])).isNegative
            ? true
            : false;

    List<User> investedWith = [];
    if (json['InvestedWith'].isNotEmpty) {
      for (int i = 0; i < json['InvestedWith'].length; i++) {
        User user = User.fromJson(json['InvestedWith'][i]);
        investedWith.add(user);
      }
    }
    List<int> reactions = [0, 0, 0, 0];
    reactions[0] = json["loved"] ?? 0;
    reactions[1] = json["liked"] ?? 0;
    reactions[2] = json["whatever"] ?? 0;
    reactions[3] = json["hated"] ?? 0;
    String reaction = json["requester_reaction"] ?? "noreact";
    if (reaction == "NotReacted") {
      reaction = "noreact";
    }

    return Post(
        userReaction: reaction,
        storyType: json["StoryType"],
        id: json["id"],
        canReact: expiringOnDiff,
        user: User.fromJson(uid),
        storyText: json["StoryText"],
        investedWithUser: investedWith,
        investedAmount: json["InvestedAmount"],
        profit: json["PresentValue"].toString(),
        reactions: reactions,
        createdOn: time,
        fileUpload: json["FileUpload"] == null
            ? []
            : List<String>.from(json["FileUpload"].map((x) => x)));
  }

  factory Post.fromJsonW(final json) {
    final diff = DateTime.now().difference(DateTime.parse(json['PostedOn']));
    final time = getTimeSinceNotification(diff);
    var uid = json["UserId"];
    List<int> reactions = [0, 0, 0, 0];
    reactions[0] = json["loved"] ?? 0;
    reactions[1] = json["liked"] ?? 0;
    reactions[2] = json["whatever"] ?? 0;
    reactions[3] = json["hated"] ?? 0;
    String reaction = json["requester_reaction"] ?? "noreact";
    if (reaction == "NotReacted") {
      reaction = "noreact";
    }
    return Post(
        userReaction: reaction,
        storyType: json["StoryType"],
        id: json["id"],
        user: User.fromJson(uid),
        storyText: json["StoryText"],
        profit: json["PresentValue"].toString(),
        reactions: reactions,
        createdOn: time,
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
        // "FileUpload": fileUpload != null
        //     ? List<String>.from(fileUpload.map((x) => x))
        //     : [],
      };
  // Map<String, dynamic> toJsonInvestDao() => {
  //       "id": id,
  //       "StoryText": storyText,
  //       "InvestedWith": investedWith == null ? [] : this.investedWith,
  //       "InvestedAmount": investedAmount,
  //       "Duration": duration.toString(),
  //       "FileUpload": fileUpload != null
  //           ? List<String>.from(fileUpload.map((x) => x))
  //           : [],
  //       "PresentValue": profit,
  //       "ReactedBy": reactedBy,
  //       "createdOn": createdOn,
  //       "StoryType": storyType,
  //       "Owner": user,
  //     };

  // Map<String, dynamic> toJsonWageDao() => {
  //       "id": id,
  //       "StoryText": storyText,
  //       "FileUpload": fileUpload != null
  //           ? List<String>.from(fileUpload.map((x) => x))
  //           : [],
  //       "PresentValue": profit,
  //       "ReactedBy": reactedBy,
  //       "createdOn": createdOn,
  //       "StoryType": storyType,
  //       "Owner": user,
  //     };

  Map<String, dynamic> toJsonWage() => {
        "id": id,
        "StoryText": storyText,
        // "FileUpload": fileUpload != null
        //     ? List<String>.from(fileUpload.map((x) => x))
        //     : [],
      };
  static String getTimeSinceNotification(Duration duration) {
    if (duration.inDays > 62) {
      return "${(duration.inDays ~/ 31)} months ago";
    } else if (duration.inDays >= 31) {
      return "A month ago";
    } else if (duration.inDays == 1) {
      return "A day ago";
    } else if (duration.inDays > 1) {
      return "${duration.inDays} days ago";
    } else if (duration.inHours == 1) {
      return "An hour ago";
    } else if (duration.inHours > 1) {
      return "${duration.inHours} hours ago";
    } else {
      return "Now";
    }
  }
}
