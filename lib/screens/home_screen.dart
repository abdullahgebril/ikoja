import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:deliveryfood/Logger.dart';
import 'package:deliveryfood/provider/categorys_products_data_provider.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/auth_api.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:deliveryfood/widgets/category_menu_products_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';

import '../model/CartItem.dart';
import '../model/User.dart';
import '../utilities/cart_pref.dart';
import '../utilities/user_prefs.dart';
import '../widgets/drawer_widget.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Data.
  bool _isNetworkAvailable = true;
  Connectivity connectivity;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var productsCart;
  User user;

  void loadSavedCartProducts() {
    setState(() {
      productsCart = CartPref.getCart();
    });
  }

  StreamSubscription<ConnectivityResult> connectivityStatusSubscription;

  void loadProducts() async {
    await Provider.of<DataProvider>(context, listen: false).fetchProducts();
  }

  void initState() {
    listenToInternetStatus();
    loadProducts();
    getUser();

    super.initState();
  }

  void listenToInternetStatus() {
    connectivity = Connectivity();
    connectivityStatusSubscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          if (result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi) {
            setState(() {
              _isNetworkAvailable = true;
            });
          } else {
            setState(() {
              _isNetworkAvailable = false;
            });
          }
        });
  }

  @override
  void didChangeDependencies() async {
    loadSavedCartProducts();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    connectivityStatusSubscription.cancel();
    super.dispose();
  }

  void logoutUser() async {
    UserPrefs.deleteUser(user);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('LogIn', (Route<dynamic> route) => false);
  }

  void getUser() async {
    this.user = UserPrefs.getUser();
    // Call to config the messaging notifications.
    _configFirebaseMessaging(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);

    return new Consumer<Cart>(builder: (context, card, child) {
     // Logger.log("Load data");
      return Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.black54

            ),
          ),
          Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState.openDrawer();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.04),
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Image.asset('assets/images/drawer.png'),
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ikoja',
                    style: textStyle.copyWith(fontSize: 30),
                  )
                ],
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                      icon: Icon(
                        Icons.person,
                        size: 40,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        showUserInfoDialog(context, user.name, logoutUser);
                      }),
                )
              ],
            ),
            drawer: AppDrawer(),
            body: _isNetworkAvailable == false
                ? connectionDialog(context)
                : Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.03),
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(child: DropdownButtonWidget()),
                          SizedBox(
                            height: screenHeight * .02,
                          ),
                        ],
                      )),

                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/cartScreen');
                            },
                            child: Container(
                                height: screenHeight * 0.08,
                                width: double.infinity,
                                margin: EdgeInsets.fromLTRB(15, 0, 20, 15),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: FittedBox(
                                        child: Text(
                                          'MY CART',
                                          style: textStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 22),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Flexible(
                                      child: FittedBox(
                                        child: Text(
                                          productsCart == null
                                              ? ' '
                                              : '${productsCart.length != 0
                                              ? '${productsCart.length} items'
                                              : ' '}',
                                          style: textStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                          )

                ],
              ),
            ),
          ),
        ],
      );
    });
  }
 // feen delete
  /// Set notifications codes to be ready
  Future<void> _configFirebaseMessaging(BuildContext context) async {
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

      String notificationToken = await firebaseMessaging.getToken();

      ////print("$notificationToken");
      AuthApi authHelper = AuthApi();
      await authHelper.setUserToken(user, notificationToken);

      await firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false),
      );

      firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        //print("Settings registered: $settings");
      });

      firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          //print("onMessage: $message");
          String title = message['notification']['title'];
          String body = message['notification']['body'];
          String tag = message['data']['tag'];

          // Play notification sound
          FlutterRingtonePlayer.play(
            android: AndroidSounds.notification,
            ios: IosSounds.triTone,
            looping: false, // Android only - API >= 28
            asAlarm: false, // Android only - all APIs
          );

          if (tag.contains("order"))
            Provider.of<DataProvider>(context, listen: false).refreshOrder();

          return showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("$title",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24)),
                        SizedBox(height: 10),
                        Text("$body",
                            style: TextStyle(fontSize: 14, height: 1.5)),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton(
                                child: Text("Ok"),
                                onPressed: () => Navigator.pop(context))
                          ],
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
    } catch (ex) {
      //print(ex);
    }
  }
}

class NotificationBackgroundConfig {
  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
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