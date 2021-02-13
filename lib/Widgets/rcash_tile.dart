import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';

import '../contants/constants.dart';
import '../model/user.dart';

class RcashTile extends StatelessWidget {
  User user;
  RcashTile(
      {this.user,
      this.textColor,
      this.backgroundColor,
      this.title,
      this.value});
  Color backgroundColor;
  Color textColor;
  String title;
  String value;
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colorShadow.withOpacity(0.12),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(2, 2), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 21.0, horizontal: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Lato'),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset("images/yollar.svg",
                            height: 15, color: textColor),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          value,
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textColor),
                        )
                      ],
                    ),
                  )

                  // Expanded(
                  //   child: ListTile(
                  //     //contentPadding: EdgeInsets.all(4),
                  //     dense: true,
                  //     //contentPadding: EdgeInsets.all(-10)
                  //     // leading: GestureDetector(
                  //     //   // onTap: () =>
                  //     //   // showProfile(
                  //     //   // context, widget.user, widget.user.photoUrl, curUser),
                  //     //   child: CircleAvatar(
                  //     //     backgroundImage: widget.user.photoUrl != ""
                  //     //         ? NetworkImage(
                  //     //             widget.user.photoUrl,
                  //     //           )
                  //     //         : AssetImage("images/avatar.jpg"),
                  //     //   ),
                  //     // ),
                  //
                  //     leading: Padding(
                  //       padding: const EdgeInsets.only(bottom: 0),
                  //       child: Stack(
                  //         children: <Widget>[
                  //           GestureDetector(
                  //             child: Container(
                  //               height: 39,
                  //               width: 39,
                  //               //  color: Colors.red,
                  //               decoration: BoxDecoration(
                  //                   color: Colors.red,
                  //                   image: DecorationImage(
                  //                       image: curUser.photoUrl != ""
                  //                           ? NetworkImage(curUser.photoUrl)
                  //                           : AssetImage("images/avatar.jpg"),
                  //                       fit: BoxFit.cover),
                  //                   shape: BoxShape.circle),
                  //             ),
                  //             onTap: () {
                  //               // if (canShowProfile)
                  //               //   showProfile(context, curUser, curUser.photoUrl);
                  //             },
                  //           ),
                  //           Positioned(
                  //             // right: 0,
                  //             // bottom: 27,
                  //             left: 0,
                  //             top: 27,
                  //             child: Container(
                  //               height: 12,
                  //               // width: 40,
                  //               decoration: BoxDecoration(
                  //                   border: Border.all(color: colorProfitPositive),
                  //                   borderRadius:
                  //                       BorderRadius.all(Radius.circular(8)),
                  //                   //shape: BoxShape.circle,
                  //                   color: colorProfitPositive),
                  //               child: Padding(
                  //                 padding: const EdgeInsets.all(2.0),
                  //                 child: Center(
                  //                     child: Text(
                  //                         widget.user.socialStanding.toString(),
                  //                         style: TextStyle(
                  //                             color: Colors.white,
                  //                             fontSize: 7,
                  //                             fontWeight: FontWeight.bold))
                  //                     // FaIcon(
                  //                     //   FontAwesomeIcons.bars,
                  //                     //   color: colorGreenTint,
                  //                     //   size: 15,
                  //                     // ),
                  //                     ),
                  //               ),
                  //             ),
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //     title: Text(
                  //       widget.user.id == curUser.id
                  //           ? "You"
                  //           : "${widget.user.fname} ${widget.user.lname}",
                  //       style: TextStyle(
                  //         fontFamily: "Lato",
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 16,
                  //         color: nameCol,
                  //       ),
                  //     ),
                  //     subtitle: Padding(
                  //       padding: const EdgeInsets.only(bottom: 0),
                  //       child: Row(
                  //         children: <Widget>[
                  //           Text(
                  //             "Investment story, ",
                  //             style: TextStyle(
                  //                 fontFamily: 'Lato',
                  //                 fontSize: 12,
                  //                 color: subtitile),
                  //           ),
                  //           Text(
                  //             "10 october",
                  //             style: TextStyle(
                  //                 fontFamily: 'Lato',
                  //                 fontSize: 9,
                  //                 color: postIcons),
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Text(
                  //   "+3000",
                  //   style: TextStyle(
                  //       color: colorProfitPositive,
                  //       fontFamily: 'Lato',
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold),
                  // )
                ],
              ),
              title == "Investment"
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Matured Investment",
                              style:
                                  TextStyle(fontSize: 12, fontFamily: 'Lato'),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset("images/yollar.svg",
                                      height: 12, color: colorAmountPositive),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    user.totalInvestmentEarningMaturedAmount
                                        .toString(),
                                    style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: colorAmountPositive),
                                  )
                                ],
                              ),
                            )
                          ]),
                    )
                  : title == "Platform Engagement"
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Interaction",
                                  style: TextStyle(
                                      fontSize: 12, fontFamily: 'Lato'),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset("images/yollar.svg",
                                          height: 12,
                                          color: colorAmountPositive),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "11",
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: colorAmountPositive),
                                      )
                                    ],
                                  ),
                                )
                              ]),
                        )
                      : SizedBox.shrink(),
              title == "Investment"
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Active Investment",
                              style:
                                  TextStyle(fontSize: 12, fontFamily: 'Lato'),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset("images/yollar.svg",
                                      height: 12, color: textColor),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    user.totalInvestmentEarningActiveAmount
                                        .toString(),
                                    style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: textColor),
                                  )
                                ],
                              ),
                            )
                          ]),
                    )
                  : title == "Platform Engagement"
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Referral",
                                  style: TextStyle(
                                      fontSize: 12, fontFamily: 'Lato'),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset("images/yollar.svg",
                                          height: 12, color: textColor),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        user.referralAmount.toString(),
                                        style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: textColor),
                                      )
                                    ],
                                  ),
                                )
                              ]),
                        )
                      : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
