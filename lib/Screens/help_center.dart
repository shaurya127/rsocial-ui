import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rsocial2/Widgets/CustomAppBar.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Widgets/error.dart';

class HelpCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: ListView(
        children: [
          SizedBox(
            height: 50,
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 25.0, right: 25, top: 10, bottom: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return FAQScreen();
                    }),
                  );
                },
                child: Text(
                  "FAQ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'lato',
                      fontSize: 22,
                      color: colorPrimaryBlue,
                      decoration: TextDecoration.underline),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25, top: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return OnboardingGuide();
                    }),
                  );
                },
                child: Text(
                  "Onboarding Guide",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'lato',
                      fontSize: 22,
                      color: colorPrimaryBlue,
                      decoration: TextDecoration.underline),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingGuide extends StatelessWidget {
  const OnboardingGuide({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(context),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: FadeInImage(
            imageErrorBuilder: (context, obj, trace) {
              return ErrWidget(
                tryAgainOnPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      return OnboardingGuide();
                    }),
                  );
                },
              );
            },
            height: MediaQuery.of(context).size.height - 50,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            placeholder: AssetImage(
              "images/splashScreenAndroid.gif",
            ),
            image: NetworkImage(
              "https://relatotechnologies.com/bg.gif",
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
