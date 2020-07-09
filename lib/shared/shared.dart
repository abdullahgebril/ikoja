import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//final String domainName = "https://ikoja.herokuapp.com";
final String domainName = "http://ikoja.online";

final textStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white);

Color blackColor = Colors.black.withOpacity(0.7);

Future showAppDialog(BuildContext context, String message) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Container(
            height: 40,
            // width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: blackColor.withOpacity(0.8),
            ),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                  message,
                  style: textStyle.copyWith(fontSize: 14),
                ))),
          ),
        );
      }).then((_) {});
  await Future.delayed(Duration(seconds: 2));
  Navigator.of(context).pop(true);
}

void showErrorDialog(BuildContext context, var message) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: Text(message == null ? 'Error' : message),
            actions: <Widget>[
              FlatButton(
                child: Text('close'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ));
}

final key = 'user';

saveUserInSharedPref(String userString) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final value = userString;
  prefs.setString(key, value);
}

void showUserInfoDialog(BuildContext context, String userName, Function logout) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
//      shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.circular(10.0)),
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        '$userName',
                        style: textStyle.copyWith(color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                          text: 'You are aleardy Login us', style: textStyle.copyWith(color: Colors.black, fontSize: 15)),
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.blueAccent,
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: textStyle.copyWith(color: Colors.white, fontSize: 25),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: GestureDetector(
                          onTap: logout,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.blueAccent,
                            ),
                            child: Center(
                              child: Text(
                                'Logout',
                                style: textStyle.copyWith(color: Colors.white, fontSize: 25),
                              ),
                            ),
                          ),
                        ))
                      ],
                    ),
                  )
                ],
              )),
        );
      });
}

Widget connectionDialog(BuildContext context) {
  return Dialog(
      backgroundColor: Colors.black12,
      child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'No INTERNET!',
                    style: textStyle.copyWith(color: Colors.black54),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      "please check your internet connection and try again",
                      textAlign: TextAlign.center,
                      style: textStyle.copyWith(color: Colors.black, fontSize: 24),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ]),
              ))));
}

void showSingInDailog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                SizedBox(
                  width: 15,
                ),
                new Text(
                  "Sign in",
                  style: textStyle,
                ),
              ],
            ),
          ),
        );
      });
}

//-------------------------------------------
// Text for about us restaurant
String ikojaDefinition =
    'IKOJA RESTURNAT:\nis a modern restaurant locates in an ideal location in CONCORD PLAZA MALL in NEW CAIRO,some of the qualities that enable ikoja to stnds out from the crowd';

String highQuality =
    'IKOJA sets high standard for its food quality and ensure that guests receive the same quality with every meal. Saving quality food earn the resuarnt a good reputation and compel the guestdto return  for repeat visits';

String goodOverallExperience =
    'Ikoja provides cutomer service in a clean environment which enhances the guests overall experience  of the restuarent . The staff interacts with the  guests is courteous and maintain a postive attitude';

