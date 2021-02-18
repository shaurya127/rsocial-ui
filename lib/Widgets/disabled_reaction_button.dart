import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rsocial2/contants/constants.dart';

class DisabledReactionButton extends StatelessWidget {
  final int reactionSizeIncrease = 3;
  final Animation reactionAnimation;
  final String reactionType;
  final String curReaction;
  final String selectedImage;
  final String unSelectedImage;
  final int counter;
  DisabledReactionButton(
      {this.reactionAnimation,
        this.reactionType,
        this.curReaction,
        this.selectedImage,
        this.unSelectedImage,
        this.counter});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 23 + reactionSizeIncrease * reactionAnimation.value,
          width: 23 + reactionSizeIncrease * reactionAnimation.value,
          child: curReaction == reactionType
              ? SvgPicture.asset(
            selectedImage,
            fit: BoxFit.cover,
          )
              : SvgPicture.asset(
            unSelectedImage,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: 4 - reactionSizeIncrease * reactionAnimation.value,
        ),
        Text(
          counter.toString(),
          style: TextStyle(
            fontFamily: "Lato",
            fontSize: 10,
            color: colorUnselectedBottomNav,
          ),
        )
      ],
    );
  }
}