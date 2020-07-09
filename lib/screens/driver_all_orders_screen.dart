import 'dart:convert';

import 'package:deliveryfood/enums/OrderStatus.dart';
import 'package:deliveryfood/model/DeliveryOrder.dart';
import 'package:deliveryfood/model/Driver.dart';
import 'package:deliveryfood/provider/categorys_products_data_provider.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:deliveryfood/utilities/user_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverAllOrdersScreen extends StatefulWidget {
  @override
  _DriverAllOrdersScreenState createState() => _DriverAllOrdersScreenState();
}

class _DriverAllOrdersScreenState extends State<DriverAllOrdersScreen> {
  Driver _driver;
  List<DeliveryOrder> driverOrders;

  var _isInit = true;
  var _isLoading = false;

  void getDriver() async {
    var value = json.decode(UserPrefs.getUserAsString());

    /**
     * Shady
     * setState to detect the changes for variable as user data.
     */
    setState(() {
      _driver = Driver.fromJson(value);
    });
  }

  void loadData() {
    if (_isInit && mounted) {
      setState(() {
        _isLoading = true;
      });
      try {
        Provider.of<DataProvider>(context).fetchDriverAllOrders(_driver).then((orders) {
          setState(() {
            driverOrders = orders;
            _isLoading = false;
          });
        });
      } catch (e) {
        throw e;
      }
      _isInit = false;
    }
  }

  void initState() {
    super.initState();
    getDriver();
  }

  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_driver != null) this.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);
    driverOrders = Provider.of<DataProvider>(context).driverOrders;
    driverOrders.sort((order1, order2) => order2.orderTime.compareTo(order1.orderTime));
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
                    : (driverOrders.length > 0)
                        ? SingleChildScrollView(child: Column(children: driverOrders.map((order) => _orderItem(order)).toList()))
                        : Center(
                            child: Text(
                              'No Orders.',
                              style: textStyle.apply(color: Colors.black),
                            ),
                          ),
              ))
        ],
      ),
    );
  }

  Widget _orderItem(DeliveryOrder order) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              "DeliveryOrderDetailsScreen",
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
