import 'dart:async';

import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserOrderPaymentScreen extends StatefulWidget {
  @override
  _UserOrderPaymentScreenState createState() => _UserOrderPaymentScreenState();
}

class _UserOrderPaymentScreenState extends State<UserOrderPaymentScreen> {
  String url;
  Function refreshOrderFunc;
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);

    List<dynamic> args = ModalRoute.of(context).settings.arguments as List<dynamic>;
    if (url == null) url = args[0];
    if (refreshOrderFunc == null) refreshOrderFunc = args[1];

    return Scaffold(
        body: Stack(children: [
      Container(
        height: screenHeight,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/burgger.jpg'), fit: BoxFit.cover)),
      ),
      Positioned(
        left: screenHeight * 0.02,
        top: screenHeight * 0.05,
        child: Row(children: <Widget>[
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              )),
          SizedBox(width: 5),
          Text(
            'Pay Order',
            style: textStyle.copyWith(fontSize: 25, color: Colors.white),
          )
        ]),
      ),
      Positioned(
        left: 10,
        right: 10,
        bottom: 10,
        child: Container(
          padding: const EdgeInsets.all(8),
          height: screenHeight * 0.88,
          color: Colors.white,
          child: WebView(
            initialUrl: '$url',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                //print('blocking navigation to $request}');
                return NavigationDecision.prevent;
              }
              //print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              //print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              if (url.startsWith("https://accept.paymobsolutions.com/api/acceptance/post_pay")) {
                String newUrl = url.replaceAll(
                    "https://accept.paymobsolutions.com/api/acceptance/post_pay", "$domainName/api/payment/callback");
                _controller.future.then((value) => value.loadUrl("$newUrl"));
              } else if (url.startsWith("$domainName/api/payment/callback")) {
                refreshOrderFunc();
                Future.delayed(Duration(seconds: 7), () => Navigator.pop(context));
              }
              //print('Page finished loading: $url');
            },
            gestureNavigationEnabled: true,
          ),
        ),
      ),
    ]));
  }
}
