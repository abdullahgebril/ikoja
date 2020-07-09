import 'dart:convert';

import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import '../utilities/auth_api.dart';

class SingUp extends StatefulWidget {
  @override
  _SingUpState createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber;
  String password;
  String name;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPass = TextEditingController();

  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _confirmPassword = FocusNode();

  AuthApi dbHelper = AuthApi();

  String errorMsg = '';

  @override
  void dispose() {
    super.dispose();

    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPassword.dispose();
    _phoneController.dispose();
  }

  void _saveForm() async {
    var isValid = _formKey.currentState.validate();
    if (!isValid) return;

    try {
      await dbHelper.singUp(_nameController.text, _phoneController.text, _passwordController.text);
      Navigator.of(context).pop();
    } catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('user already exists')) errorMessage = 'This email address is already in use.';

      _phoneController.text = '';
      _passwordController.text = '';
      _nameController.text = '';
      _confirmPass.text = '';
      showErrorDialog(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);

    return Card(
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            height: screenHeight,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/LoadingBg.jpeg'),
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop))),
            child: Center(
              child: Container(
                //height: screenHeight * 0.62,
                width: screenWidth,
                margin: EdgeInsets.only(left: 10, right: 10, top: screenHeight * 0.05, bottom: screenHeight * 0.05),
                decoration:
                    BoxDecoration(color: Colors.black54.withOpacity(.5), border: Border.all(color: Colors.blueGrey, width: 2)),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                  cursorColor: Color(0xFF9b9b9b),
                                  controller: _nameController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(8.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                                    ),
                                    hintText: "Full Name",
                                    hintStyle: textStyle.copyWith(color: Colors.white.withOpacity(0.6)),
                                  ),
                                  focusNode: _nameFocusNode,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_phoneFocusNode);
                                  },
                                  validator: (nameValue) {
                                    if (nameValue.isEmpty || nameValue.trim().length < 3 || !nameValue.trim().contains(" ")) {
                                      return 'Please enter your full name: Ahmed Mohamed';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  style: TextStyle(color: Colors.white, fontSize: 20),
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
                                        color: Colors.teal,
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
                                    hintStyle: textStyle.copyWith(color: Colors.white.withOpacity(0.6)),
                                  ),
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
                                  height: 8,
                                ),
                                TextFormField(
                                  style: TextStyle(color: Colors.white, fontSize: 20),
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
                                        color: Colors.teal,
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
                                    hintStyle: textStyle.copyWith(color: Colors.white.withOpacity(0.6)),
                                  ),
                                  focusNode: _passwordFocusNode,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_confirmPassword);
                                  },
                                  validator: (passwordvalue) {
                                    if (passwordvalue.length < 6) return 'password must be large than 6';
                                    if (passwordvalue.isEmpty) {
                                      return 'Please enter  your phone number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                  cursorColor: Color(0xFF9b9b9b),
                                  keyboardType: TextInputType.text,
                                  controller: _confirmPass,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(8.0),
                                      ),
                                      borderSide: new BorderSide(
                                        color: Colors.teal,
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                                    ),
                                    hintText: "Confirm Password",
                                    hintStyle: textStyle.copyWith(color: Colors.white.withOpacity(0.6)),
                                  ),
                                  focusNode: _confirmPassword,
                                  validator: (confirmvalue) {
                                    if (confirmvalue.isEmpty) {
                                      return 'Please enter  your phone number';
                                    }
                                    if (confirmvalue != _passwordController.text) return 'Not Match';

                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      GestureDetector(
                        onTap: _saveForm,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                          padding: EdgeInsets.all(15.0),
                          alignment: FractionalOffset.center,
                          decoration: new BoxDecoration(
                            color: Color.fromRGBO(213, 100, 80, 1),
                            borderRadius: new BorderRadius.all(const Radius.circular(30.0)),
                          ),
                          child: Text('Sign up', style: textStyle.copyWith(color: Colors.white)),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
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
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
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
        final fbToken = result.accessToken.token;
        final graphResponse =
            await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$fbToken');
        final profile = json.decode(graphResponse.body);

        final formFBKey = GlobalKey<FormState>();
        final phoneFBController = TextEditingController();

        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: formFBKey,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      style: TextStyle(color: Colors.black, fontSize: 20),
                                      cursorColor: Color(0xFF9b9b9b),
                                      controller: phoneFBController,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(8.0),
                                          ),
                                          borderSide: new BorderSide(
                                            color: Colors.teal,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black, width: 1.0),
                                        ),
                                        hintText: "Phone number",
                                        hintStyle: textStyle.copyWith(color: Colors.black.withOpacity(0.6)),
                                      ),
                                      validator: (phoneValue) {
                                        if (phoneValue.isEmpty || phoneValue.length != 11) {
                                          return 'Please enter your phone correctly';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              var isValid = formFBKey.currentState.validate();
                              if (!isValid) return;

                              try {
                                dbHelper
                                    .singUpFB(profile["name"], phoneFBController.text, profile["id"], fbToken, profile["email"])
                                    .then((_) => Navigator.of(context)
                                        .pushNamedAndRemoveUntil('homeScreen', (Route<dynamic> route) => false));
                              } catch (error) {
                                var errorMessage = 'Authentication failed';
                                if (error.toString().contains('phone already exists')) errorMessage = 'phone already exists.';
                                if (error.toString().contains('facebook user already exists'))
                                  errorMessage = 'facebook user already exists.';
                                showErrorDialog(context, errorMessage);
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                              padding: EdgeInsets.all(15.0),
                              alignment: FractionalOffset.center,
                              decoration: new BoxDecoration(
                                color: Color.fromRGBO(213, 100, 80, 1),
                                borderRadius: new BorderRadius.all(const Radius.circular(30.0)),
                              ),
                              child: Text('Continue', style: textStyle.copyWith(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ));

        //print(profile);
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        break;
    }
  }
}
