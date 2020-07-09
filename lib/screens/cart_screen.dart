import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:deliveryfood/model/CartItem.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../utilities/cart_pref.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _connectionState = true;
  Connectivity connectivity;

  StreamSubscription<ConnectivityResult> subscription;

  //List of cart items
  Map<String, CartItem> cartList;

  //Fetch Cart List  from CartPref

  void fetchDataFromCartPref() {
    cartList = CartPref.getCart();
  }

  @override
  void initState() {
    connectivity = Connectivity();
    subscription = connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        setState(() {
          _connectionState = true;
        });
      } else {
        setState(() {
          _connectionState = false;
        });
      }
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    fetchDataFromCartPref();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);


    //fetch Total Amount for cart list
  final cart = Provider.of<Cart>(context);
    var totalAmount = cart.getTotalAmountFromCash();


    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/burgger.jpg'), fit: BoxFit.cover)),
        ),
        Positioned(
          left: screenHeight * 0.02,
          top: screenHeight * 0.05,
          child:  GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              )),
        ),

        Align(
          alignment: Alignment.topCenter,
          child:Padding(
            padding:  EdgeInsets.only(top: screenHeight * 0.05),
            child: Text(
              'Your cart',
              style: textStyle.copyWith(fontSize: 25, color: Colors.white),
            ),
          ),

        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: Container(
            height: screenHeight * 0.85,
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                      child: cartList.length == 0
                          ? Center(
                              child: Text(
                                'NO cart yet!',
                                style: textStyle.copyWith(color: Colors.blueGrey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: cartList.length,
                              itemBuilder: (context, index) {
                                String savedId = cartList.keys.toList()[index];
                                CartItem cartItem = cartList[savedId];
                                return CartItemWidget(savedId, cartItem, () {
                                  setState(() {});
                                });
                              }),
                    )),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    'Total Amount: ${totalAmount.toStringAsFixed(2)}',
                    style: textStyle.copyWith(color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                GestureDetector(
                    onTap: () {
                      //First check internet connection ,then check cart i
                      if (_connectionState == false) {
                        showAppDialog(context, 'Please check internet connection try again');
                      } else {
                        if (cartList.isEmpty) {
                          showAppDialog(context, 'Cart Is Empty');
                        } else {
                          _showDialog(context);
                          Navigator.of(context).pushNamed('dressOrderScrenn');
                        }
                      }
                    },
                    child: CompleteOrderContainer())
              ],
            ),
          ),
        )
      ]),
    );
  }
}

class CompleteOrderContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.08,
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(15, 0, 20, 15),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue,
      ),
      child: Center(
          child: FittedBox(
        child: Text(
          'Complete Order',
          style: textStyle.copyWith(color: Colors.white),
        ),
      )),
    );
  }
}

Widget _showDialog(BuildContext context) {
  return Container(
    color: Colors.blueGrey,
    child: Row(
      children: <Widget>[
        SizedBox(
          width: 15,
        ),
        SpinKitCircle(
          color: Colors.black,
          size: 60.0,
        ),
        SizedBox(
          width: 15,
        ),
        Text(
          'Loading ',
          style: textStyle,
        ),
      ],
    ),
  );
}
