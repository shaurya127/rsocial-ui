import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/user_onboarding.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Widgets/error.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import '../model/user.dart';

class HelpCenter extends StatelessWidget {
  final String fname = curUser.fname;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: ListView(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TyperAnimatedTextKit(
              // isRepeatingAnimation: false,
              text: [
                'Hi, $fname! Welcome to Rsocial!',
                'How can we help you?',
              ],
              textStyle: TextStyle(fontSize: 16, fontFamily: "Lato"),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 160,
                child: Card(
                  elevation: 10,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return FAQScreen();
                      }));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('images/answer.png'))),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: FittedBox(
                            child: Text(
                              'Still have questions',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, fontFamily: "Lato"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 160,
                child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          //return UserOnboarding(null);
                          return VideoScreen();
                        }));
                      },
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('images/online-video.png'),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: FittedBox(
                              child: Text(
                                'Watch an interactive video',
                                style:
                                    TextStyle(fontSize: 13, fontFamily: "Lato"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 160,
                child: Card(
                  elevation: 10,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return AboutScreen();
                      }));
                    },
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          height: 80,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('images/helprs.jpg'))),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'About us',
                            style: TextStyle(fontSize: 15, fontFamily: "Lato"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    var preferredWidget = AppBar(
      backgroundColor: colorButton,
      iconTheme: IconThemeData(color: Colors.white),
    );
    return Scaffold(
        appBar: preferredWidget,
        bottomNavigationBar: Container(
          color: colorButton,
          height: 60,
        ),
        body: Center(
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            width: double.infinity,
            imageUrl: "https://relatotechnologies.com/bg.gif",
            placeholder: (ctx, _) => Center(child: CircularProgressIndicator()),
            errorWidget: (ctx, _, error) => Center(
              child: FittedBox(
                child: Text(
                  'Some error occured. Please try again later',
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

class FAQScreen extends StatefulWidget {
  const FAQScreen({
    Key key,
  }) : super(key: key);

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

var isLoading = true;

class _FAQScreenState extends State<FAQScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        opacity: 0.0,
        child: Stack(
          children: [
            WebView(
              initialUrl:
                  'https://relatotechnologies.com/frequently-asked-questions/index.html',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (_) {
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  var isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        opacity: 0.0,
        child: Stack(
          children: [
            WebView(
              initialUrl: 'https://relatotechnologies.com/rsocial/index.html',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (_) {
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
