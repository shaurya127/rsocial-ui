import 'dart:convert';

import 'package:flutter/cupertino.dart';

class User {
  User(
      {this.id,
      this.photoUrl,
      this.fname,
      this.lname,
      this.gender,
      this.email,
      this.lollarAmount,
      this.socialStanding,
      this.bio,
      this.dob,
      this.mobile,
      this.connection,
      this.reactionType,
      this.pendingConnection,
      this.sentPendingConnection,
      this.receivedPendingConnection,
      this.userMap,
      this.inviteSenderId,
      this.connectionCount,
      this.totalActiveInvestmentAmount,
      this.joiningBonus,
      this.referralAmount,
      this.totalInvestmentEarningActiveAmount,
      this.totalInvestmentEarningMaturedAmount,
      this.totalPlatformEngagementAmount,
      this.totalWageEarningAmount,
      this.totalAvailableYollar,
      this.totalPlatformInteractionAmount});

  final String fname;
  final String lname;
  String email = "";
  String id;
  int lollarAmount;
  int socialStanding;
  String bio;
  String gender;
  String dob;
  String mobile;
  List<User> connection;
  List<User> pendingConnection;
  List<User> sentPendingConnection;
  List<User> receivedPendingConnection;
  Map<String, String> userMap = new Map();
  String photoUrl;
  String reactionType;
  String inviteSenderId;
  int connectionCount;
  int totalWageEarningAmount;
  int totalInvestmentEarningMaturedAmount;
  int totalInvestmentEarningActiveAmount;
  int totalPlatformEngagementAmount;
  int joiningBonus;
  int referralAmount;
  int totalActiveInvestmentAmount;
  int totalAvailableYollar;
  int totalPlatformInteractionAmount;
  //List<String> list= new List();

  factory User.fromJson(final json) {
    //print(json["SentPendingConnection"]);
    Map<String, String> map = new Map();
    List<User> outgoing = [];
    if (json["SentPendingConnection"] != null) {
      for (int i = 0; i < json["SentPendingConnection"].length; i++) {
        User user = User.fromJson(json["SentPendingConnection"][i]);
        outgoing.add(user);
        map.putIfAbsent(user.id, () => "pending");
      }
    }
    List<User> pending = [];
    if (json["PendingConnection"] != null) {
      for (int i = 0; i < json["PendingConnection"].length; i++) {
        User user = User.fromJson(json["PendingConnection"][i]);
        pending.add(user);
      }
    }

    List<User> frnds = [];
    if (json["Connection"] != null) {
      for (int i = 0; i < json["Connection"].length; i++) {
        User user = User.fromJson(json["Connection"][i]);
        frnds.add(user);
        map[user.id] = "remove";
      }
    }

    List<User> incoming = [];
    if (json["ReceivedPendingConnection"] != null) {
      for (int i = 0; i < json["ReceivedPendingConnection"].length; i++) {
        User user = User.fromJson(json["ReceivedPendingConnection"][i]);
        incoming.add(user);
        map[user.id] = "request";
      }
    }

    return User(
        id: json['id'],
        photoUrl: json['ProfilePic'],
        fname: json['FName'],
        lname: json['LName'],
        email: json['Email'],
        lollarAmount: json['LollarAmount'].floor(),
        socialStanding: json['SocialStanding'],
        bio: json['Bio'],
        gender: json['gender'],
        reactionType: json["reaction_type"],
        dob: json['dob'],
        connection: json["Connection"] == null ? [] : frnds,
        pendingConnection: json["PendingConnection"] == null ? [] : pending,
        sentPendingConnection:
            json["SentPendingConnection"] == null ? [] : outgoing,
        receivedPendingConnection:
            json["ReceivedPendingConnection"] == null ? [] : incoming,
        userMap: map,
        connectionCount: json['NumConnection'],
        totalActiveInvestmentAmount: json['TotalActiveInvestmentAmount'],
        totalWageEarningAmount: json['TotalWageEarningAmount'],
        totalInvestmentEarningActiveAmount:
            json['TotalInvestmentEarningActiveAmount'].floor(),
        totalInvestmentEarningMaturedAmount:
            json['TotalInvestmentEarningMaturedAmount'].floor(),
        totalPlatformEngagementAmount:
            json['TotalPlatformEngagementAmount'].floor(),
        joiningBonus: json['JoiningBonus'].floor(),
        totalAvailableYollar: json['TotalAvailableYollar'].floor(),
        totalPlatformInteractionAmount:
            json['TotalPlatformInteractionAmount'].floor(),
        referralAmount: json['ReferralAmount'].floor());
  }

  Map<String, dynamic> toJson() => {
        'fname': this.fname,
        'lname': this.lname,
        'email': this.email == null ? "" : this.email,
        'mobile': this.mobile != null ? this.mobile.substring(3) : "",
        'bio': this.bio != null ? this.bio : "",
        'gender': this.gender != null ? this.gender : "O",
        'dob': this.dob != null ? this.dob : "01/01/1900",
        'lollarAmount': this.lollarAmount,
        'socialStanding': this.socialStanding,
        'profilepic': this.photoUrl == null ? "" : this.photoUrl,
        'referred_by': this.inviteSenderId,
      };
}
