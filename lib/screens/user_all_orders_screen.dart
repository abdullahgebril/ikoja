import 'dart:convert';

import 'package:deliveryfood/enums/OrderStatus.dart';
import 'package:deliveryfood/model/CustomerOrder.dart';
import 'package:deliveryfood/model/User.dart';
import 'package:deliveryfood/provider/categorys_products_data_provider.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:deliveryfood/utilities/user_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/categorys_products_data_provider.dart';

class UserAllOrdersScreen extends StatefulWidget {
  @override
  _UserAllOrdersScreenState createState() => _UserAllOrdersScreenState();
}

class _UserAllOrdersScreenState extends State<UserAllOrdersScreen> {
  User _user;
  List<CustomerOrder> userOrders;

  var _isInit = true;
  var _isLoading = false;

  void getUser() async {
    var value = json.decode(UserPrefs.getUserAsString());

    setState(() {
      _user = User.fromJson(value);
    });
  }

  void loadData(User user) {
    if (_isInit && mounted) {
      setState(() {
        _isLoading = true;
      });
      try {
        Provider.of<DataProvider>(context).fetchUserAllOrders(user).then((orders) {
          setState(() {
            userOrders = orders;
            _isLoading = false;
          });
        });
      } catch (e) {
        //print(e.toString());
      }
      _isInit = false;
    }
  }

  void initState() {
    super.initState();
    getUser();
  }

  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_user != null) loadData(_user);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);
    userOrders = Provider.of<DataProvider>(context).userOrders;
    userOrders.sort((order1, order2) => order2.orderTime.compareTo(order1.orderTime));

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
            left: screenHeight * 0.02,
            top: screenHeight * 0.05,
            child: Row(children: <Widget>[
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  )),
              SizedBox(width: 5),
              Text(
                'My Orders',
                style: textStyle,
              )
            ]),
          ),
          Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                height: screenHeight * 0.85,
                width: double.infinity,
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(child: Column(children: userOrders.map((order) => _orderItem(order)).toList())),
              ))
        ],
      ),
    );
  }

  Widget _orderItem(CustomerOrder order) {
    //print(order.productList.length);
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              "UserOrderDetailsScreen",
              arguments: order,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black12,
            child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Order: ${order.customerName}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${order.getOrderTime()}",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Order Amount ${order.orderTotalPrice + (order.fees ?? 0) + (order.deliveryCharge ?? 0)} EGP",
                        style: TextStyle(fontSize: 14),
                      )
                    ],
                  )),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "${order.productList.map((e) => e.quantity).toList().reduce((v, e) => v += e)} Items",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Image.asset(
                      (order.orderStatus == OrderStatus.DELEVIRED)
                          ? "assets/images/delivered_order_icon.png"
                          : (order.orderStatus == OrderStatus.CANCELLED)
                              ? "assets/images/close.png"
                              : "assets/images/prepared_order_icon.png",
                      height: 20)
                ],
              )
            ]),
          )),
      SizedBox(height: 10)
    ]);
  }
}
