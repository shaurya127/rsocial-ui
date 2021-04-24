import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/bottom_nav_bar.dart';
import 'auth.dart';
import 'model/post.dart';

Future<Uri> createDynamicLink(String type, Post post) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String parameter;
  String header;

  if (type == 'postid') {
    parameter = post.id;
    header = 'posts';
  } else {
    parameter = curUser.id;
    header = 'invites';
  }

  final DynamicLinkParameters parameters = DynamicLinkParameters(
      // This should match firebase but without the username query param
      uriPrefix: 'https://rsocialdevapp.page.link',
      // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
      link: Uri.parse(
          'https://rsocialdevapp.page.link/$header?$type=$parameter&'),
      androidParameters: AndroidParameters(
        packageName: packageInfo.packageName,
        minimumVersion: 0,
      ),

      // dynamicLinkParametersOptions: DynamicLinkParametersOptions(
      //   shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      // ),

      iosParameters: IosParameters(
        bundleId: packageInfo.packageName,
        minimumVersion: '0',
        appStoreId: '123456789',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'example-promo',
        medium: 'social',
        source: 'orkut',
      ),
      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
        providerToken: '123456',
        campaignToken: 'example-promo',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: type == 'postid'
            ? '${post.user.fname} on Rsocial'
            : 'Hey! join me on RSocial',
        description: type == 'postid'
            ? ""
            : "Join via this link and the referrer gets 500 Yollar once referee joins Rsocial.",
        // imageUrl: type=='post' ? post.fileUpload.isNotEmpty
        //     ? Uri.parse(post.fileUpload[0])
        //     : Uri.parse(post.user.photoUrl)
        //     :
      ),
      navigationInfoParameters:
          NavigationInfoParameters(forcedRedirectEnabled: true));

  final link = await parameters.buildUrl();
  final ShortDynamicLink shortenedLink = await DynamicLinkParameters.shortenUrl(
    link,
    DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
  );
  return shortenedLink.shortUrl;
}

// initDynamicLinks() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
//   //final Uri deepLink = data?.link;
//
//   FirebaseDynamicLinks.instance.onLink(
//       onSuccess: (PendingDynamicLinkData dynamicLink) async {
//     final Uri deepLink = dynamicLink?.link;
//     if (deepLink != null) {
//       print(
//           "the postid is:${deepLink.queryParameters['postid']}"); // <- prints 'abc'
//       postId = deepLink.queryParameters['postid'];
//       inviteSenderId = deepLink.queryParameters['sender'];
//       prefs.setString('inviteSenderId', inviteSenderId);
//     }
//   }, onError: (OnLinkErrorException e) async {
//     print('onLinkError');
//     print(e.message);
//   });
//
//   final PendingDynamicLinkData data =
//       await FirebaseDynamicLinks.instance.getInitialLink();
//   final Uri deepLink = data?.link;
//
//   if (deepLink != null) {
//     postId = deepLink.queryParameters['postid'];
//     inviteSenderId = deepLink.queryParameters['sender'];
//   }
// }
