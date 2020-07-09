import 'dart:convert';

import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import '../utilities/auth_api.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber;
  String password;

  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthApi authHelper = AuthApi();

  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
  }

  void _saveForm() async {
    var isValid = _formKey.currentState.validate();
    if (!isValid) return;

    setState(() {
      isLoading = true;
    });
    try {
      await authHelper.userLogin(_phoneController.text, _passwordController.text).then((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('homeScreen', (Route<dynamic> route) => false);
      });
    } catch (error) {
      var errorMessage = 'Somthing wrong';
      if (error.toString().contains('wrong phone or password')) errorMessage = 'wrong phone or password.';
      _phoneController.text = '';
      _passwordController.text = '';

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text(errorMessage == null ? 'Error' : errorMessage),
                actions: <Widget>[
                  FlatButton(
                    child: Text('close'),
                    onPressed: () {
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ));
    }
    setState(() {
      isLoading = true;
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
            height: screenHeight,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/LoadingBg.jpeg'),
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop))),
          ),
          Positioned(
            top: screenHeight * 0.1,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            child: Card(
              color: Colors.transparent,
              child: Container(
                //   height: screenHeight * 0.6,
                width: screenWidth,
                margin: EdgeInsets.only(left: 10, right: 10),
                decoration:
                    BoxDecoration(color: Colors.black54.withOpacity(.5), border: Border.all(color: Colors.white70, width: 2)),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                style: TextStyle(color: Colors.white),
                                cursorColor: Color(0xFF9b9b9b),
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 11,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(8.0),
                                      ),
                                      borderSide: new BorderSide(
                                        color: Colors.red,
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                                    ),
                                    hintText: "Phone number",
                                    hintStyle: textStyle.copyWith(color: Colors.white.withOpacity(0.6))),
                                focusNode: _phoneFocusNode,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                                },
                                validator: (phoneValue) {
                                  if (phoneValue.isEmpty || phoneValue.length != 11) {
                                    return 'Please enter your phone correctly';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                style: textStyle.copyWith(color: Colors.white),
                                cursorColor: Color(0xFF9b9b9b),
                                controller: _passwordController,
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(8.0),
                                      ),
                                      borderSide: new BorderSide(
                                        color: Colors.white,
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                                    ),
                                    hintText: "Password",
                                    hintStyle: textStyle.copyWith(color: Colors.white.withOpacity(0.6))),
                                focusNode: _passwordFocusNode,
                                validator: (passwordvalue) {
                                  if (passwordvalue.isEmpty) {
                                    return 'Please enter  your Password number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ),
                            ],
                          ),
                        ),
                      ),
                      isLoading
                          ? Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 15,
                                ),
                                SpinKitCircle(
                                  color: Colors.deepOrange,
                                  size: 60.0,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  'Sign in ',
                                  style: textStyle,
                                ),
                              ],
                            )
                          : AuthTypeContainer('Log in', () {
                              _saveForm();
                            }),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                        alignment: Alignment.center,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(border: Border.all(width: 0.25)),
                              ),
                            ),
                            Text(
                              "OR CONNECT WITH",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(border: Border.all(width: 0.25)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                          child: Row(children: <Widget>[
                            Expanded(
                                child: Container(
                                    margin: EdgeInsets.only(right: 8.0),
                                    alignment: Alignment.center,
                                    child: Row(children: <Widget>[
                                      Expanded(
                                        child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30.0),
                                          ),
                                          color: Color(0Xff3B5998),
                                          onPressed: _facebookLogin,
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  child: FlatButton(
                                                    onPressed: _facebookLogin,
                                                    padding: EdgeInsets.only(
                                                      top: 20.0,
                                                      bottom: 20.0,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: <Widget>[
                                                        Icon(
                                                          FontAwesomeIcons.facebookF,
                                                          color: Colors.white,
                                                          size: 15.0,
                                                        ),
                                                        Text(
                                                          "FACEBOOK",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ])))
                          ])),
                      AuthTypeContainer('Sign Up', () {
                        Navigator.of(context).pushNamed('Sign UP');
                      }),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('deliveryBoyLogin');
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'LOG IN AS DELIVERY BOY',
                              style: textStyle,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _facebookLogin() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        /**
       * Shady
       * When login in is succeeded.
       */
        final token = result.accessToken.token;
        final graphResponse =
            await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
        final profile = json.decode(graphResponse.body);
        setState(() {
          isLoading = true;
        });
        try {
          await authHelper.userLoginFB(profile["id"]).then((_) {
            Navigator.of(context).pushNamedAndRemoveUntil('homeScreen', (Route<dynamic> route) => false);
          });
        } catch (error) {
          var errorMessage = 'Somthing wrong';
          if (error.toString().contains('facebook account not registered')) errorMessage = 'facebook account not registered.';
          _phoneController.text = '';
          _passwordController.text = '';

          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: Text(errorMessage == null ? 'Error' : errorMessage),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Close'),
                        onPressed: () {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  ));
        }
        setState(() {
          isLoading = true;
        });
        //print(profile);
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        break;
    }
  }
}

//Build login and sing up button

class AuthTypeContainer extends StatelessWidget {
  final String title;
  final Function onPressed;

  AuthTypeContainer(this.title, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        padding: EdgeInsets.all(15.0),
        alignment: FractionalOffset.center,
        decoration: new BoxDecoration(
          color: Color.fromRGBO(213, 100, 80, 1),
          borderRadius: new BorderRadius.all(const Radius.circular(30.0)),
        ),
        child: Text(title, style: textStyle.copyWith(color: Colors.white)),
      ),
    );
  }
}
