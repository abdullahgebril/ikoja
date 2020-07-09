import 'dart:convert';

import 'package:deliveryfood/enums/PresenceStatus.dart';
import 'package:deliveryfood/model/Driver.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/auth_api.dart';
import 'package:deliveryfood/utilities/delivery_orders_api.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:deliveryfood/utilities/user_prefs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class DeliveryMainScreen extends StatefulWidget {
  @override
  _DeliveryMainScreenState createState() => _DeliveryMainScreenState();
}

class _DeliveryMainScreenState extends State<DeliveryMainScreen> {
  Driver _driver;
  PresenceStatus _presenceStatus = PresenceStatus.LOADING;

  DeliveryOrdersApi dbHelper = DeliveryOrdersApi();

  void getDriver() async {
    var value = json.decode(UserPrefs.getUserAsString());

    setState(() {
      _driver = Driver.fromJson(value);
      _presenceStatus = (_driver.presence) ? PresenceStatus.ACTIVATED : PresenceStatus.DEACTIVATED;
    });

    // Call to config the messaging notifications.
    _configFirebaseMessaging(context);
  }

  void initState() {
    super.initState();
    getDriver();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/burgger.jpg'),
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
            )),
          ),
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.03,
            child: Text(
              'Delivery Boy',
              style: textStyle,
            ),
          ),
          Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                  height: screenHeight * 0.85,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(children: [
                      Expanded(
                          flex: 1,
                          child: Column(children: [
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                color: Colors.black12,
                                child: Column(children: <Widget>[
                                  Image.asset("assets/images/delivery_boy_icon.png", height: screenHeight * 0.1),
                                  SizedBox(height: 10),
                                  Text("${_driver.name}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        GestureDetector(
                                            onTap: () {
                                              UserPrefs.deleteUser(_driver);
                                              Navigator.of(context)
                                                  .pushNamedAndRemoveUntil('LogIn', (Route<dynamic> route) => false);
                                            },
                                            child: Text("SIGN OUT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                                        SizedBox(width: 10),
                                        Text("|", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 10),
                                        Text("DELIVERY BOY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                                      ])
                                ])),
                            SizedBox(
                              height: screenHeight * 0.03,
                            ),
                            Row(children: <Widget>[
                              Expanded(flex: 1, child: Text("Set your presence", style: TextStyle(fontSize: 18))),
                              (_presenceStatus == PresenceStatus.LOADING)
                                  ? CircularProgressIndicator()
                                  : Switch(
                                      value: (_presenceStatus == PresenceStatus.ACTIVATED) ? true : false,
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.red,
                                      inactiveTrackColor: Colors.red.withAlpha(100),
                                      onChanged: (value) {
                                        setState(() => _presenceStatus = PresenceStatus.LOADING);
                                        _changePresence();
                                      })
                            ])
                          ])),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                        GestureDetector(
                          onTap: (_presenceStatus == PresenceStatus.ACTIVATED)
                              ? () {
                                  Navigator.of(context).pushNamed("DeliveryOrdersScreen");
                                }
                              : null,
                          child: Container(
                            width: screenWidth * 0.4,
                            padding: EdgeInsets.all(15.0),
                            alignment: FractionalOffset.center,
                            decoration: new BoxDecoration(
                              color:
                                  (_presenceStatus == PresenceStatus.ACTIVATED) ? Color.fromRGBO(213, 100, 80, 1) : Colors.grey,
                              borderRadius: new BorderRadius.all(const Radius.circular(30.0)),
                            ),
                            child: Text('Orders', style: textStyle.copyWith(color: Colors.white)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed("DriverAllOrdersScreen");
                          },
                          child: Container(
                            width: screenWidth * 0.4,
                            padding: EdgeInsets.all(15.0),
                            alignment: FractionalOffset.center,
                            decoration: new BoxDecoration(
                              color: Color.fromRGBO(213, 100, 80, 1),
                              borderRadius: new BorderRadius.all(const Radius.circular(30.0)),
                            ),
                            child: Text('My Orders', style: textStyle.copyWith(color: Colors.white)),
                          ),
                        ),
                      ])
                    ]),
                  )))
        ],
      ),
    );
  }

  Future _changePresence() async {
    try {
      await dbHelper.setPresence(_driver).then((updatedDriver) {
        setState(() {
          _driver = updatedDriver;
          _presenceStatus = (_driver.presence) ? PresenceStatus.ACTIVATED : PresenceStatus.DEACTIVATED;
        });
      });
    } catch (error) {
      showErrorDialog(context, error.toString());
    }
  }

  /// Set notifications codes to be ready
  Future<void> _configFirebaseMessaging(BuildContext context) async {
    // try {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    String notificationToken = await firebaseMessaging.getToken();

    AuthApi authHelper = AuthApi();
    await authHelper.setUserToken(_driver, notificationToken);

    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
    );

    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      //print("Settings registered: $settings");
    });

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //print("onMessage: $message");
        String title = message['notification']['title'];
        String body = message['notification']['body'];
        //String tag = message['data']['tag'];

        // Play notification sound
        FlutterRingtonePlayer.play(
          android: AndroidSounds.notification,
          ios: IosSounds.triTone,
          looping: false, // Android only - API >= 28
          asAlarm: false, // Android only - all APIs
        );

        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Text("$title", textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
                  SizedBox(height: 10),
                  Text("$body", textDirection: TextDirection.rtl, style: TextStyle(fontSize: 14, height: 1.5)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[RaisedButton(child: Text("Ok"), onPressed: () => Navigator.pop(context))],
                  )
                ])));
      },
      //onBackgroundMessage: NotificationBackgroundConfig.myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        await Navigator.of(context).pushNamed('cartScreen');
        //print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        //print("onResume: $message");
      },
    );
    //} catch (ex) {
    //  //print(ex);
    //}
  }
}

class NotificationBackgroundConfig {
  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      return data;
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      return notification;
    }

    // Or do other work.
    return null;
  }
}
