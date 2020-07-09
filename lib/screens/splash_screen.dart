import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:deliveryfood/utilities/user_prefs.dart';
import 'package:flutter/material.dart';

import '../model/User.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User user;

  void checkUser() async {
    bool isUserLoggedIn = UserPrefs.isUserLogined();
    if (!isUserLoggedIn) {
      Navigator.of(context).pushReplacementNamed('LogIn');
    } else {
      // user is logged in in app.
      // check user type to decide which screen to open .
      String userType = UserPrefs.getUserType();
      if (userType == 'user') {
        Navigator.of(context).pushReplacementNamed('homeScreen');
      } else {
        // user is driver.
        Navigator.of(context).pushReplacementNamed('DeliveryMainScreen');
      }
    }
  }

  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      checkUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,

            decoration: BoxDecoration(
              color: Colors.black54
//              image: DecorationImage(
//                image: AssetImage('assets/images/burgger.jpg'),
//                fit: BoxFit.cover,
//                colorFilter: new ColorFilter.mode(
//                    Colors.black.withOpacity(0.5), BlendMode.dstATop),
//              ),
            ),
          ),
          Center(
            child: Container(
              height: screenHeight * 0.47,
              width: screenWidth ,
              child: Image.asset('assets/images/Logo.png'),
            ),
          ),
        ],
      ),
    );
  }
}
