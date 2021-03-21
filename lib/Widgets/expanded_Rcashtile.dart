import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';

import '../contants/constants.dart';
import '../functions.dart';
import '../model/user.dart';

class EpandedRcashTile extends StatelessWidget {
  User user;
  EpandedRcashTile({
    this.user,
    this.titles,
    this.values,
  });

  List<int> values;
  List<String> titles;
  List<Widget> buildList() {
    return List.generate(titles.length + 1, (i) {
      if (i == titles.length) {
        return SizedBox(
          height: 20,
        );
      }
      if (i == 0) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 25, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                titles[0],
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Lato'),
              ),
              Spacer(),
              // Container(
              //     child: Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 15),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       SvgPicture.asset("images/yollar.svg",
              //           height: 15,
              //           color: values[0] < 0
              //               ? colorAmountNegative
              //               : colorAmountPositive),
              //       SizedBox(
              //         width: 2,
              //       ),
              //       Text(
              //         formatNumber(values[0]),
              //         style: TextStyle(
              //             fontFamily: 'Lato',
              //             fontWeight: FontWeight.bold,
              //             fontSize: 15,
              //             color: values[0] < 0
              //                 ? colorAmountNegative
              //                 : colorAmountPositive),
              //       )
              //     ],
              //   ),
              // )),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              titles[i],
              style: TextStyle(fontSize: 15, fontFamily: 'Lato'),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset("images/yollar.svg",
                      height: 15,
                      color: values[i] < 0
                          ? colorAmountNegative
                          : colorAmountPositive),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    formatNumber(values[i]),
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: values[i] < 0
                            ? colorAmountNegative
                            : colorAmountPositive),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget build(BuildContext context) {
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
            children: buildList(),
          ),
        ),
      ),
    );
  }
}
