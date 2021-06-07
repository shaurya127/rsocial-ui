import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:new_version/new_version.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rate_my_app/rate_my_app.dart';

import 'package:rsocial2/auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:rsocial2/contants/constants.dart';
import 'providers/data.dart';
import 'push_notifications.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: colorStatusBar, // status bar color
  ));
  runApp(MyApp());
}


final GlobalKey<NavigatorState> navigatorKey =
GlobalKey(debugLabel: "Main Navigator");
final GlobalKey key = GlobalKey();




class MyApp extends StatelessWidget {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    // Initialising push notification service
    final pushNotificationService =
    PushNotificationService(MyApp._firebaseMessaging, context);
    pushNotificationService.initialise();

    // The app will stay in potrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: OverlaySupport(
        child: ChangeNotifierProvider(
          create: (ctx) {
            return Data();
          },
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            navigatorObservers: <NavigatorObserver>[MyApp.observer],
            theme: ThemeData(
              primaryColor: colorPrimaryBlue,
            ),
            home: UpdatePage(),

          ),
        ),
      ),
    );
  }
}

class UpdatePage extends StatefulWidget {

  // static void launch({String androidAppId, String iOSAppId}) async {
  //   await _channel.invokeMethod(
  //       'openappstore', {'android_id': androidAppId, 'ios_id': iOSAppId});
  // }

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {



  RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 7,
    remindDays: 2,
    remindLaunches: 5,
    // appStoreIdentifier: '',
    googlePlayIdentifier: 'com.rsocial',
  );


  @override
  void initState() {
    super.initState();

    // _rateMyApp.init().then((_) {
    //   // TODO: Comment out this if statement to test rating dialog (Remember to uncomment)
    //   // if (_rateMyApp.shouldOpenDialog) {
    //   _rateMyApp.showStarRateDialog(
    //     context,
    //     title: 'Enjoying Flutter Rating Prompt?',
    //     message: 'Please leave a rating!',
    //     actionsBuilder: (context, stars) {
    //       return [
    //         FlatButton(
    //           child: Text('Ok'),
    //           onPressed: () {
    //             if (stars != null) {_rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed).then((_) => Navigator.pop(context));
    //
    //             // _rateMyApp
    //             // _rateMyApp.doNotOpenAgain = true;
    //             // _rateMyApp.save().then((v) => Navigator.pop(context));
    //
    //             if (stars <= 3) {
    //               print('Navigate to Contact Us Screen');
    //               // Navigator.push(
    //               //   context,
    //               //   MaterialPageRoute(
    //               //     builder: (_) => ContactUsScreen(),
    //               //   ),
    //               // );
    //             } else if (stars <= 5) {
    //
    //
    //               // print('Leave a Review Dialog');
    //               // showDialog(context: null);
    //             }
    //             } else {
    //               Navigator.pop(context);
    //             }
    //           },
    //         ),
    //         FlatButton(
    //           child: Text('No Thanks!'),
    //           onPressed: () {
    //            print("rate us");
    //           },
    //         ),
    //       ];
    //     },
    //     dialogStyle: DialogStyle(
    //       titleAlign: TextAlign.center,
    //       messageAlign: TextAlign.center,
    //       messagePadding: EdgeInsets.only(bottom: 20.0),
    //     ),
    //     starRatingOptions: StarRatingOptions(),
    //   );
    //   // }
    // });




    _checkversion();
  }

  // Future<void> rate() async {
  //   final InAppReview inAppReview = InAppReview.instance;
  //
  //   if (await inAppReview.isAvailable()) {
  //     inAppReview.requestReview();
  //   }
  // }

  void _checkversion() async {
    final newVersion = NewVersion(
      androidId: 'com.master.rsocial',
    );
    final status = await newVersion.getVersionStatus();
    newVersion.showUpdateDialog(
      context: context,
      versionStatus: status,

    );
    print("device" + status.localVersion);
    print("device " + status.storeVersion);
  }
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splashIconSize: double.infinity,
        duration: 300,
        animationDuration: Duration(milliseconds: 300),
        splash: Image.asset(
          "images/splashScreenAndroid.gif",
          fit: BoxFit.cover,
        ),
        backgroundColor: Colors.white,
        nextScreen: AuthScreen(analytics: analytics, observer: observer),
        pageTransitionType: PageTransitionType.fade,
      ),

    );
  }
}
