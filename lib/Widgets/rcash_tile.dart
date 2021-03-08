import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';

import '../contants/constants.dart';
import '../functions.dart';
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
  int value;
  bool isInvestment = false;
  bool isplatformEngagement = false;
  Widget build(BuildContext context) {
    if (title == "Investment") {
      isInvestment = true;
      if (curUser.totalActiveInvestmentAmount < 0 ||
          curUser.totalInvestmentEarningMaturedAmount < 0) {
        backgroundColor = colorRcashNegative;
      }
    }

    if (title == "Platform Engagement") {
      isplatformEngagement = true;
      if (curUser.totalPlatformInteractionAmount < 0 ||
          curUser.referralAmount < 0) {
        backgroundColor = colorRcashNegative;
        textColor = colorAmountNegative;
      }
    }
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
        child: !isInvestment&&!isplatformEngagement? Padding(
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
                            height: 15,
                            color: value < 0
                                ? colorAmountNegative
                                : colorAmountPositive),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          formatNumber(value),
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: value < 0
                                  ? colorAmountNegative
                                  : colorAmountPositive),
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

            ],
          ),
        ):
         isplatformEngagement?
        Padding(
    padding: const EdgeInsets.only(top: 0),
    child: ExpansionTile(
expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
    title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                height: 15,
                color: value < 0
                    ? colorAmountNegative
                    : colorAmountPositive),
            SizedBox(
              width: 2,
            ),
            Text(
              formatNumber(value),
              style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: value < 0
                      ? colorAmountNegative
                      : colorAmountPositive),
            )
          ],
        ),
      )


    ],),
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 15,right: 15),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Interaction",
                style: TextStyle(
                    fontSize: 15, fontFamily: 'Lato'),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      "images/yollar.svg",
                      height: 15,
                      color:
                      curUser.totalPlatformInteractionAmount <
                          0
                          ? colorAmountNegative
                          : colorAmountPositive,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      formatNumber(curUser
                          .totalPlatformInteractionAmount
                          .floor()),
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color:
                        curUser.totalPlatformInteractionAmount <
                            0
                            ? colorAmountNegative
                            : colorAmountPositive,
                      ),
                    )
                  ],
                ),
              )
            ]),
      ),

      Padding(
        padding: const EdgeInsets.only(left: 15,right: 15,bottom: 16),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Referral",
                style: TextStyle(
                    fontSize: 15, fontFamily: 'Lato'),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset("images/yollar.svg",
                        height: 15,
                        color: curUser.referralAmount < 0
                            ? colorAmountNegative
                            : colorAmountPositive),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      formatNumber(
                          curUser.referralAmount.floor()),
                      style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: curUser.referralAmount < 0
                              ? colorAmountNegative
                              : colorAmountPositive,
                      ),
                    )
                  ],
                ),
              )
            ]),
      )
    ],
    ),
    ):
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: ExpansionTile(
              expandedAlignment: Alignment.centerLeft,
              title: Row(
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
                          height: 15,
                          color: value < 0
                              ? colorAmountNegative
                              : colorAmountPositive),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        formatNumber(value),
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: value < 0
                                ? colorAmountNegative
                                : colorAmountPositive),
                      )
                    ],
                  ),
                )


              ],),
              children: <Widget>[


                Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Matured Investment",
                          style:
                          TextStyle(fontSize: 15, fontFamily: 'Lato'),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                "images/yollar.svg",
                                height: 15,
                                color:
                                curUser.totalInvestmentEarningMaturedAmount <
                                    0
                                    ? colorAmountNegative
                                    : colorAmountPositive,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                formatNumber(curUser
                                    .totalInvestmentEarningMaturedAmount
                                    .floor()),
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color:
                                  curUser.totalInvestmentEarningMaturedAmount <
                                      0
                                      ? colorAmountNegative
                                      : colorAmountPositive,
                                ),
                              )
                            ],
                          ),
                        )
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15,bottom:16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Active Investment",
                          style:
                          TextStyle(fontSize: 15, fontFamily: 'Lato'),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                "images/yollar.svg",
                                height: 15,
                                color:
                                curUser.totalActiveInvestmentAmount < 0
                                    ? colorAmountNegative
                                    : colorAmountPositive,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                formatNumber(curUser
                                    .totalActiveInvestmentAmount
                                    .floor()),
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color:
                                  curUser.totalActiveInvestmentAmount <
                                      0
                                      ? colorAmountNegative
                                      : colorAmountPositive,
                                ),
                              )
                            ],
                          ),
                        )
                      ]),
                ),


              ],
            ),
          )
      ),
    );
  }
}
