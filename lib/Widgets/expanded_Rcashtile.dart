import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';

import '../contants/constants.dart';
import '../functions.dart';
import '../model/user.dart';

class EpandedRcashTile extends StatelessWidget {
  User user;
  EpandedRcashTile(
      {this.user,
        this.titles,
      this.values});

 List<int> values;
List<String> titles;

  Widget build(BuildContext context) {
    // if (title == "Investment") {
    //   isInvestment = true;
    //   if (curUser.totalActiveInvestmentAmount < 0 ||
    //       curUser.totalInvestmentEarningMaturedAmount < 0) {
    //     backgroundColor = colorRcashNegative;
    //   }
    // }
    //
    // if (title == "Platform Engagement") {
    //   isplatformEngagement = true;
    //   if (curUser.totalPlatformInteractionAmount < 0 ||
    //       curUser.referralAmount < 0) {
    //     backgroundColor = colorRcashNegative;
    //     textColor = colorAmountNegative;
    //   }
    // }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: Container(
          decoration: BoxDecoration(
            color: values[0] < 0 ? colorRcashNegative : colorRcashPositive,
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
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      titles[0],
                      style: TextStyle(
                        color: Colors.blue,

                          fontSize: 15,
                          fontFamily: 'Lato'),
                    ),
                    Container(
                      child:Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset("images/yollar.svg",
                              height: 15,
                              color: values[0] < 0
                                  ? colorAmountNegative
                                  : colorAmountPositive),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            formatNumber(values[0]),
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: values[0] < 0
                                    ? colorAmountNegative
                                    : colorAmountPositive),
                          )
                        ],
                      ),)
                    ),


                  ],
                ),
                SizedBox(height: 12,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                     titles[1],
                      style: TextStyle(

                          fontSize: 15,
                          fontFamily: 'Lato'),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset("images/yollar.svg",
                              height: 15,
                              color: values[1] < 0
                                  ? colorAmountNegative
                                  : colorAmountPositive),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            formatNumber(values[1]),
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: values[1] < 0
                                    ? colorAmountNegative
                                    : colorAmountPositive),
                          )
                        ],
                      ),
                    )


                  ],
                ),
                SizedBox(height: 12,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Invested",
                      style: TextStyle(

                          fontSize: 15,
                          fontFamily: 'Lato'),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset("images/yollar.svg",
                              height: 15,
                              color: values[3] < 0
                                  ? colorAmountNegative
                                  : colorAmountPositive),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            formatNumber(values[3]),
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: values[3] < 0
                                    ? colorAmountNegative
                                    : colorAmountPositive),
                          )
                        ],
                      ),
                    )


                  ],
                ),
                SizedBox(height: 12,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Joining Bonus",
                      style: TextStyle(

                          fontSize: 15,
                          fontFamily: 'Lato'),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset("images/yollar.svg",
                              height: 15,
                              color: values[4] < 0
                                  ? colorAmountNegative
                                  : colorAmountPositive),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            formatNumber(values[4]),
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: values[0] < 0
                                    ? colorAmountNegative
                                    : colorAmountPositive),
                          )
                        ],
                      ),
                    )


                  ],
                ),
                SizedBox(height: 12,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Wassup",
                      style: TextStyle(

                          fontSize: 15,
                          fontFamily: 'Lato'),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset("images/yollar.svg",
                              height: 15,
                              color: values[2] < 0
                                  ? colorAmountNegative
                                  : colorAmountPositive),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            formatNumber(values[2]),
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: values[0] < 0
                                    ? colorAmountNegative
                                    : colorAmountPositive),
                          )
                        ],
                      ),
                    )


                  ],
                ),
                SizedBox(height: 12,),
              ],
            ),
          ),
            ),
          );

  }
}
