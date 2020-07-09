import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:flutter/material.dart';

import '../utilities/auth_api.dart';

class DeliveryBoyLogIn extends StatefulWidget {
  @override
  _DeliveryBoyLogInState createState() => _DeliveryBoyLogInState();
}

class _DeliveryBoyLogInState extends State<DeliveryBoyLogIn> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber;
  String password;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  AuthApi dbHelper = AuthApi();

  bool _isLoading = false;

  void dispose() {
    super.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    _emailController.dispose();
  }

  void _saveForm() async {
    var isValid = _formKey.currentState.validate();
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await dbHelper
          .driverLogin(_emailController.text, _passwordController.text)
          .then((_) => Navigator.of(context).pushNamedAndRemoveUntil('DeliveryMainScreen', (Route<dynamic> route) => false));
    } catch (error) {
      Navigator.pop(context);

      var errorMessage = 'Somthing wrong';
      if (error.toString().contains('wrong mail or password')) errorMessage = 'wrong mail or password.';

      _emailController.text = '';
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
                        _isLoading = false;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);
    return Scaffold(

    resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
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
              'Delivery Boy Login',
              style: textStyle,
            ),
          ),
          Positioned(
            top:screenHeight * 0.15,
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                  height: screenHeight * 0.7,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SingleChildScrollView(
                      child: Column(children: [
                        Container(
                          height: 150,
                          width: 150,
                          child: Image.asset('assets/images/deliveryboy.jpg'),
                        ),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Column(
                         children: <Widget>[
                           Form(
                             key: _formKey,
                             child: Column(
                               children: <Widget>[
                                 TextFormField(
                                   style: TextStyle(color: Colors.black),
                                   cursorColor: Colors.blueGrey,
                                   controller: _emailController,
                                   keyboardType: TextInputType.phone,
                                   decoration: InputDecoration(
                                     labelText: "Phone Required",
                                     focusedBorder: OutlineInputBorder(
                                       borderSide: BorderSide(color: Colors.black54, width: 2.0),
                                     ),
                                     enabledBorder: OutlineInputBorder(
                                       borderSide: BorderSide(color: Colors.blue, width: 1.0),
                                     ),
                                   ),
                                   focusNode: _emailFocusNode,
                                   onFieldSubmitted: (_) {
                                     FocusScope.of(context).requestFocus(_passwordFocusNode);
                                   },
                                   validator: (phoneValue) {
                                     if (phoneValue.isEmpty) {
                                       return 'Please enter  your Email number';
                                     }

                                     return null;
                                   },
                                 ),
                                 SizedBox(
                                   height: screenHeight * 0.04,
                                 ),
                                 TextFormField(
                                   style: TextStyle(color: Colors.black),
                                   cursorColor: Colors.blueGrey,
                                   controller: _passwordController,
                                   keyboardType: TextInputType.text,
                                   obscureText: true,
                                   decoration: InputDecoration(
                                     labelText: "Password Required",
                                     focusedBorder: OutlineInputBorder(
                                       borderSide: BorderSide(color: Colors.black54, width: 2.0),
                                     ),
                                     enabledBorder: OutlineInputBorder(
                                       borderSide: BorderSide(color: Colors.blue, width: 1.0),
                                     ),
                                   ),
                                   focusNode: _passwordFocusNode,
                                   validator: (passwordValue) {
                                     if (passwordValue.isEmpty) {
                                       return 'Please enter  your Password number';
                                     }
                                     return null;
                                   },
                                 ),
                                 SizedBox(
                                   height: screenHeight * 0.04,
                                 ),
                                 GestureDetector(
                                   onTap: () {
                                     showSingInDailog(context);
                                     _saveForm();
                                   },
                                   child: Container(
                                     width: screenWidth * 0.4,
                                     padding: EdgeInsets.all(15.0),
                                     alignment: FractionalOffset.center,
                                     decoration: new BoxDecoration(
                                       color: Color.fromRGBO(213, 100, 80, 1),
                                       borderRadius: new BorderRadius.all(const Radius.circular(30.0)),
                                     ),
                                     child: _isLoading
                                         ? Center(child: CircularProgressIndicator())
                                         : Text('Log in', style: textStyle.copyWith(color: Colors.white)),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ],
                          ),
                      ]),
                    ),
                  )))
        ],
      ),
    );
  }
}
