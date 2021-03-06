import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const regexForPhone = r'^[6-9][0-9]{9}$';

const googlePeopleApi =
    "https://people.googleapis.com/v1/people/me?personFields=genders,birthdays&key=";

const colorStatusBar = Color(0xff45A9D2);
const colorGreenTint = Color(0xff409FC6);
const colorPrimaryBlue = Color(0xff4dbae6);
const colorButton = Color(0xff4DBAE6);
const colorGreyTint = Color(0xff7f7f7f);
const colorCoins = Color(0xffE2AF25);
const colorHintText = Color(0xff263238);
const colorUnselectedBottomNav = Color(0xff707070);
const googleTextColor = Color(0xffEA4335);
const facebookTextColor = Color(0xff285296);
const rsocialTextColor = Color(0xff4DBAE6);
const googleButtonColor = Color(0xffF5E8EA);
const facebookButtonColor = Color(0xffE6EAF4);
const nameCol = Color(0xff263238);
const postIcons = Colors.grey;
const colorProfitPositive = Color(0xff37B44B);
const colorProfitNegative = Colors.red;
const colorRcashPositive = Color(0xffEDF7EF);
const colorRcashNegative = Color(0xffFAEAEA);
const colorAmountPositive = Color(0xff37B44B);
const colorAmountNegative = Color(0xffD60E0E);
const colorShadow = Color(0xff00001F);
const colorProfileBio = Color(0xff263238);

const kBioPageTitle = "Describe yourself";
const kBioPageSubtitle = "What makes you special ?";
const kBioPagePlaceholder = "Your Bio...";
const kBioPageButton = "Continue";
const kBioPageInkWell = "Skip for now";

const kBottomNavPageBarTitle = "RSocial";

const kFacebookButtonText = "Sign up with Facebook";
const kGoogleButtonText = "Sign up with Google";
const kRsocialButtonText = "Sign up with Rsocial";

const kFacebookButtonTextSignIn = "Log in with Facebook";
const kGoogleButtonTextSignIn = "Log in with Google";

const kCreateAccountText =
    "Time to value relationships, Assess your social bonds.";
const kCreateAccountButton = "Create Account";
const kCreateAccountAlready = "Already have an account ? ";
const kCreateAccountSignIn = "Log In";

const kInvestingWith = "Invested with";

const kLandingPageEmptyText = "Welcome to your timeline";
const kLandingPageEmptySubtext = "It's empty now, but it won't be for long.";

const kLoginPageNoAccount = "Don't have an account ? ";
const kLoginPageSignUp = "Sign Up";

const kNavDrawerAmount = "Yollar";
const kNavDrawerConnection = "Bonds";
const kNavDrawerProfile = "Profile";
const kNavDrawerRefer = "Refer & earn";
const kNavDrawerSettings = "Help Center";
const kNavDrawerLogout = "Logout";
const kNavDrawerFeedback = "Feedback";

const kProfilePageWage = "Make a Wage story now";
const kProfilePageInvestment = "Make a Investment story now";
const kProfilePageWageTab = "Wage";
const kProfilePageInvestmentTab = "Investment";
const kProfilePagePlatformTab = "Platform Interaction";

const kProfilePicText = "Pick a Profile Picture";
const kProfilePicSubtext = "Have a favourite selfie? Upload it now.";

const kPostTileGain = "Gain";

const kReactionInfoAppBarTitle = "People Who Reacted";

const kInputField = InputDecoration(
    //labelText: "First Name",
    border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.black))
    // focusedBorder: UnderlineInputBorder(
    //   borderSide: BorderSide(color: Colors.lightBlueAccent),
    // ),
    );

const kOtpInput = InputDecoration(
    counterText: "",
    counterStyle: TextStyle(height: double.minPositive),
    // enabledBorder: OutlineInputBorder(),
    // focusedBorder: OutlineInputBorder(),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
        borderSide: BorderSide(color: Color(0xff263238))));
