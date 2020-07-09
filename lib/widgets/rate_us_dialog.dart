import 'dart:convert';

import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/customer_api.dart';
import 'package:deliveryfood/utilities/user_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../model/User.dart';

class RateUsDialog extends StatefulWidget {
  @override
  _RateUsDialogState createState() => _RateUsDialogState();
}

class _RateUsDialogState extends State<RateUsDialog> {
  User user;
  double rateQuestion1 = 1.0;
  double rateQuestion2 = 1.0;
  double rateQuestion3 = 1.0;
  double rateQuestion4 = 1.0;
  double rateQuestion5 = 1.0;

  CustomerApi dbHelper = CustomerApi();

  void getUser() async {
    var value = json.decode(UserPrefs.getUserAsString());
    setState(() {
      user = User.fromJson(value);
    });
  }

  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: (user == null)
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.8,
                  margin: const EdgeInsets.only(top: 35),
                  child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Padding(
                                padding: const EdgeInsets.only(top: 60, right: 15, left: 15, bottom: 5),
                                child: SingleChildScrollView(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      "Did you find the food fresh and delicious?",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 10),
                                    Center(
                                        child: SmoothStarRating(
                                            allowHalfRating: false,
                                            onRatingChanged: (v) {
                                              if (v < 1.0) v = 1.0;
                                              setState(() => rateQuestion1 = v);
                                            },
                                            starCount: 5,
                                            rating: rateQuestion1,
                                            size: 30.0,
                                            filledIconData: Icons.star,
                                            defaultIconData: Icons.star,
                                            color: Colors.orange.withGreen(180),
                                            borderColor: Colors.grey.withAlpha(80),
                                            spacing: 0.0)),
                                    SizedBox(height: 5),
                                    Divider(),
                                    Text(
                                      "Was the order arrive at your place quickly?",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 10),
                                    Center(
                                        child: SmoothStarRating(
                                            allowHalfRating: false,
                                            onRatingChanged: (v) {
                                              if (v < 1.0) v = 1.0;
                                              setState(() => rateQuestion2 = v);
                                            },
                                            starCount: 5,
                                            rating: rateQuestion2,
                                            size: 30.0,
                                            filledIconData: Icons.star,
                                            defaultIconData: Icons.star,
                                            color: Colors.orange.withGreen(180),
                                            borderColor: Colors.grey.withAlpha(80),
                                            spacing: 0.0)),
                                    SizedBox(height: 5),
                                    Divider(),
                                    Text(
                                      "Were you able to use discounts and special offers provided in our app?",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 10),
                                    Center(
                                        child: SmoothStarRating(
                                            allowHalfRating: false,
                                            onRatingChanged: (v) {
                                              if (v < 1.0) v = 1.0;
                                              setState(() => rateQuestion3 = v);
                                            },
                                            starCount: 5,
                                            rating: rateQuestion3,
                                            size: 30.0,
                                            filledIconData: Icons.star,
                                            defaultIconData: Icons.star,
                                            color: Colors.orange.withGreen(180),
                                            borderColor: Colors.grey.withAlpha(80),
                                            spacing: 0.0)),
                                    SizedBox(height: 5),
                                    Divider(),
                                    Text(
                                      "Was it easy to place an order?",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 10),
                                    Center(
                                        child: SmoothStarRating(
                                            allowHalfRating: false,
                                            onRatingChanged: (v) {
                                              if (v < 1.0) v = 1.0;
                                              setState(() => rateQuestion4 = v);
                                            },
                                            starCount: 5,
                                            rating: rateQuestion4,
                                            size: 30.0,
                                            filledIconData: Icons.star,
                                            defaultIconData: Icons.star,
                                            color: Colors.orange.withGreen(180),
                                            borderColor: Colors.grey.withAlpha(80),
                                            spacing: 0.0)),
                                    SizedBox(height: 5),
                                    Divider(),
                                    Text(
                                      "Would you like to place an order again?",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 10),
                                    Center(
                                        child: SmoothStarRating(
                                            allowHalfRating: false,
                                            onRatingChanged: (v) {
                                              if (v < 1.0) v = 1.0;
                                              setState(() => rateQuestion5 = v);
                                            },
                                            starCount: 5,
                                            rating: rateQuestion5,
                                            size: 30.0,
                                            filledIconData: Icons.star,
                                            defaultIconData: Icons.star,
                                            color: Colors.orange.withGreen(180),
                                            borderColor: Colors.grey.withAlpha(80),
                                            spacing: 0.0)),
                                    SizedBox(height: 15),
                                  ],
                                ))),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              FlatButton(
                                child: Text(
                                  "CANCEL",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              FlatButton(
                                child: Text(
                                  "RATE",
                                  style: TextStyle(color: Colors.orange),
                                ),
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return WillPopScope(
                                          onWillPop: () => Future.value(false),
                                          child: Dialog(
                                            child: Container(
                                              height: 100,
                                              child: Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                        );
                                      });

                                  try {
                                    await dbHelper
                                        .newRate(user, rateQuestion1, rateQuestion2, rateQuestion3, rateQuestion4, rateQuestion5)
                                        .then((_) {
                                      Navigator.pop(context);
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: Text(
                                                  'Thank you',
                                                  style: textStyle.copyWith(fontSize: 18, color: Colors.black),
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text('close'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ));
                                    });
                                  } catch (error) {
                                    var errorMessage = 'Something wrong, try again.';
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              content: Text(errorMessage == null ? 'Error' : errorMessage),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('Close'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ));
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      )),
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 75,
                      height: 75,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                      child: Image.asset("assets/images/rate_us.png"),
                    )),
              ],
            ),
    );
  }
}
