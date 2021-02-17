import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/Widgets/RoundedButton.dart';
import 'package:rsocial2/model/post.dart';

import '../contants/constants.dart';
import '../deep_links.dart';

class Refer_and_Earn extends StatefulWidget {
  @override
  _Refer_and_EarnState createState() => _Refer_and_EarnState();
}

class _Refer_and_EarnState extends State<Refer_and_Earn> {
  bool _isCreatingLink = false;

  Future<Uri> makeLink(String type,Post post) async {
    Uri uri;
    setState(() {
      _isCreatingLink=true;
    });
    uri = await createDynamicLink(type, post);
    setState(() {
      _isCreatingLink=false;
    });
    return uri;
  }

  // Future<Uri> createDynamicLink() async {
  //   var queryParameters = {
  //     'sender': curUser.id,
  //   };
  //
  //   //Uri link =Uri.http('flutters.page.link', 'invites', queryParameters);
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   setState(() {
  //     _isCreatingLink = true;
  //   });
  //
  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //       // This should match firebase but without the username query param
  //       uriPrefix: 'https://rsocial.page.link',
  //       // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
  //       link: Uri.parse(
  //           'https://rsocial.page.link/invites?sender=${curUser.id}&'),
  //       androidParameters: AndroidParameters(
  //         packageName: packageInfo.packageName,
  //         minimumVersion: 0,
  //       ),
  //
  //       // dynamicLinkParametersOptions: DynamicLinkParametersOptions(
  //       //   shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
  //       // ),
  //
  //       iosParameters: IosParameters(
  //         bundleId: packageInfo.packageName,
  //         minimumVersion: '0',
  //         appStoreId: '123456789',
  //       ),
  //       googleAnalyticsParameters: GoogleAnalyticsParameters(
  //         campaign: 'example-promo',
  //         medium: 'social',
  //         source: 'orkut',
  //       ),
  //       itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
  //         providerToken: '123456',
  //         campaignToken: 'example-promo',
  //       ),
  //       socialMetaTagParameters: SocialMetaTagParameters(
  //         title: 'Hey! join me on RSocial',
  //         description:
  //             "Join via this link and we both can earn 50 Lollar amount!",
  //         //imageUrl: 'images/rsocial-text-2.svg'
  //       ),
  //       navigationInfoParameters:
  //           NavigationInfoParameters(forcedRedirectEnabled: true));
  //
  //   final link = await parameters.buildUrl();
  //   final ShortDynamicLink shortenedLink =
  //       await DynamicLinkParameters.shortenUrl(
  //     link,
  //     DynamicLinkParametersOptions(
  //         shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
  //   );
  //   setState(() {
  //     //_linkMessage = url;
  //     //print(link.queryParameters['sender']);
  //     _isCreatingLink = false;
  //   });
  //   //print(shortenedLink.shortUrl.queryParameters['postid']);
  //   return shortenedLink.shortUrl;
  // }

  Future<void> share(Uri uri) async {
    await FlutterShare.share(
        title: 'Hey! Join me on RSocial',
        //text: '${widget.userPost.user.fname} on RSocial',
        linkUrl: uri.toString(),
        chooserTitle: 'Invite a friend with');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar to be updated
      appBar: customAppBar(
        context,
        "Refer & earn",
        curUser.lollarAmount,
        curUser.photoUrl,
        curUser.socialStanding,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Refer a friend to earn ",
                style: TextStyle(
                  fontFamily: "Lato",
                  color: Color(0xff263238),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SvgPicture.asset(
                "images/yollar.svg",
                color: colorPrimaryBlue,
                height: 25,
              ),
              Text(
                "50",
                style: TextStyle(
                  fontFamily: "Lato",
                  color: Color(0xff263238),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "once they sign up",
              style: TextStyle(
                fontFamily: "Lato",
                color: Color(0xff263238),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "Send invite and Socialize together",
            style: TextStyle(
                fontFamily: "Lato",
                color: Color(0xff263238),
                fontSize: 16,
                fontWeight: FontWeight.w100),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
            child: RoundedButton(
              color: Color(0xff4dbae6),
              textColor: Colors.white,
              text: "Send invite",
              onPressed: !_isCreatingLink
                  ? () async {
                      print("creating link");
                      final Uri uri = await makeLink('sender', null);
                      print("invite link is: $uri");
                      share(uri);
                    }
                  : null,
            ),
          )
        ],
      ),
    );
  }
}
