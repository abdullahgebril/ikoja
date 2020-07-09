import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/widgets/rate_us_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  void shareApplication() {
    // TODO: Choose the right sentence.
    Share.share('I am in love in Appliaction IKOJA, try it now: https://play.google.com/store/apps/details?id=ikoja.deliveryfood', subject: 'IKOJA Restaurant!');
  }

  void showRateUsDialog() {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(backgroundColor: Colors.transparent, child: RateUsDialog());
        });
  }

  _launchURL() async {
    const url = 'http://ikoja.online/privacy_policy.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Container(
              height: screenHeight * 0.2,
              child: Image.asset('assets/images/Logo.png'),
            ),
            FractionallySizedBox(
              widthFactor: 1,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                height: screenHeight * 0.7,
                color: Colors.blueGrey.withOpacity(0.3),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconsDrawer('assets/images/menulist.png', '  MENU LIST ', () {
                            Navigator.of(context).pushNamedAndRemoveUntil('homeScreen', (Route<dynamic> route) => false);
                          }),
                          IconsDrawer('assets/images/cart.png', '    MY CART   ', () {
                            Navigator.of(context).pushNamed('/cartScreen');
                          }),
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                        IconsDrawer('assets/images/order.png', ' MY ORDERS ', () {
                          Navigator.of(context).pushNamed('UserAllOrdersScreen');
                        }),
                        IconsDrawer('assets/images/heart.png', '  FAVOURITE  ', () {
                          Navigator.of(context).pushNamed('/favoriteScreen');
                        }),
                      ]),
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconsDrawer('assets/images/rate_us.png', '    RATE US     ', showRateUsDialog),
                          IconsDrawer('assets/images/share.png', '      SHARE       ', shareApplication),
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconsDrawer('assets/images/aboutus.png', ' ABOUT US   ', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AboutAsDailog()),
                            );
                          }),
                          IconsDrawer('assets/images/policy.png', '  OUR POLICY  ',_launchURL),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class IconsDrawer extends StatelessWidget {
  final String imageUrl;
  final String title;
  final Function onPressed;

  IconsDrawer(this.imageUrl, this.title, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                )),
            SizedBox(
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                height: 25,
                child: FittedBox(
                  child: Text(
                    title,
                    style: textStyle.copyWith(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Build About us screen for some definition about restaurant
class AboutAsDailog extends StatelessWidget {
  Widget ikojaConcepts(String title, String concept) {
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: textStyle.copyWith(color: Colors.black, fontSize: 25),
            )),
        SizedBox(
          height: 20,
        ),
        RichText(
          text: TextSpan(text: concept, style: textStyle.copyWith(color: Colors.white, fontSize: 20)),
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15),
        height: screenHeight,
        width: screenWidth,
        color: Colors.blueGrey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 50,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Row(
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
                    child: Image.asset('assets/images/Logo.png'),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(text: ikojaDefinition, style: textStyle.copyWith(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ],
              ), SizedBox(
                height: 5,
              ),

              Divider(
                height: 1,
                thickness: 0.3,
                color: Colors.white70,
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              ikojaConcepts('High-Quality Food', highQuality),

              SizedBox(
                height: screenHeight * 0.03,
              ),
              Divider(
                height: 1,
                thickness: 0.3,
                color: Colors.white70,
              ),
              ikojaConcepts('Good Overall Experience', goodOverallExperience),
              SizedBox(
                height: screenHeight * 0.03,
              ),

              Divider(
                height: 1,
                thickness: 0.3,
                color: Colors.white70,
              ),
              Column(
                children: [
                  Align(alignment: Alignment.centerLeft,child: Text('Contact us :',style: textStyle.copyWith(color: Colors.black, fontSize: 25))),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(child: FittedBox(child: Text('Address :',style: textStyle.copyWith(color: Colors.black, fontSize: 20)))),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 3,
                        child: RichText (
                          text: TextSpan(
                            text: 'Concord plaza mall 90st street new cairo',style: textStyle.copyWith(color: Colors.white, fontSize: 16)
                          ),
                        ),
                      ),


                    ],
                  ),
                  Column(
                    children: <Widget>[

                      SizedBox(
                        height: 15,
                      ),
                      Align(alignment: Alignment.centerLeft,child: Text('Open Location on Map:',style:textStyle.copyWith(color: Colors.white, fontSize: 18))),
                      GestureDetector(
                        onTap: (){
                          MapsLauncher.launchCoordinates(
                              30.0249468, 31.4845829);
                        },
                        child: Container(
                          height: 100,
                          width: 100,
                          child:Image.asset('assets/images/map.png',fit: BoxFit.fill,),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.3,
                    color: Colors.white70,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('You can call us ',style:textStyle.copyWith(color: Colors.white, fontSize: 18)),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: <Widget>[


                      Flexible(child: FittedBox(child: Text('Phone number:',style: textStyle.copyWith(color: Colors.black, fontSize: 20)))),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(onTap: (){
                          launch("tel://01119011198}");
                        },child: FittedBox(child: Text('01119011198',style: textStyle.copyWith(color: Colors.indigo, fontSize: 16)))),
                      ),
                    ],
                  ),

                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
