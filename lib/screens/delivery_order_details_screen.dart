import 'dart:convert';

import 'package:deliveryfood/enums/OrderStatus.dart';
import 'package:deliveryfood/enums/PaymentMethod.dart';
import 'package:deliveryfood/model/CartItem.dart';
import 'package:deliveryfood/model/DeliveryOrder.dart';
import 'package:deliveryfood/model/Driver.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/delivery_orders_api.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:deliveryfood/utilities/user_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/categorys_products_data_provider.dart';

class DeliveryOrderDetailsScreen extends StatefulWidget {
  @override
  _DeliveryOrderDetailsScreenState createState() => _DeliveryOrderDetailsScreenState();
}

class _DeliveryOrderDetailsScreenState extends State<DeliveryOrderDetailsScreen> {
  Driver _driver;
  DeliveryOrder _deliveryOrder;

  DeliveryOrdersApi dbHelper = DeliveryOrdersApi();

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

  Future _pickOrder() async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
                onWillPop: () => Future.value(false),
                child: Dialog(child: Container(height: 100, child: Center(child: CircularProgressIndicator()))));
          });

      await dbHelper.pickOrder(_deliveryOrder, _driver).then((_) async {
        await Provider.of<DataProvider>(context, listen: false).fetchDeliveryOrders(_driver);
        await Provider.of<DataProvider>(context, listen: false).fetchDriverAllOrders(_driver);

        Navigator.pop(context);

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Done picked order.",
                          style: textStyle,
                        ),
                        RaisedButton(
                          child: Text("Back"),
                          onPressed: () {
                            Navigator.pop(this.context);
                            Navigator.pop(this.context);
                          },
                        )
                      ],
                    )),
              );
            });
      });
    } catch (error) {
      showErrorDialog(context, error.toString());
    }
  }

  Future _deliverOrder() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () => Future.value(false),
              child: Dialog(child: Container(height: 100, child: Center(child: CircularProgressIndicator()))));
        });

    try {
      await dbHelper.deliverOrder(_deliveryOrder, _driver).then((_) async {
        await Provider.of<DataProvider>(context, listen: false).fetchDeliveryOrders(_driver);
        await Provider.of<DataProvider>(context, listen: false).fetchDriverAllOrders(_driver);

        Navigator.pop(context);

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Done delivered order.",
                          style: textStyle,
                        ),
                        RaisedButton(
                          child: Text("Back"),
                          onPressed: () {
                            Navigator.pop(this.context);
                            Navigator.pop(this.context);
                          },
                        )
                      ],
                    )),
              );
            });
      });
    } catch (error) {
      showErrorDialog(context, error.toString());
    }
  }

  void initState() {
    super.initState();
    getDriver();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    //final screenWidth = ScreenUtil.getScreenWidth(context);

    if (_deliveryOrder == null) _deliveryOrder = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black54
//                image: DecorationImage(
//              image: AssetImage('assets/images/burgger.jpg'),
//              fit: BoxFit.cover,
//              colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
//            ),
            ),
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
                'Order: ${_deliveryOrder.customerName}',
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                    Image.asset(
                        (_deliveryOrder.orderStatus == OrderStatus.DELEVIRED)
                            ? "assets/images/delivered_order_icon.png"
                            : "assets/images/prepared_order_icon.png",
                        width: 60),
                    SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Order Amount ${_deliveryOrder.orderTotalPrice + (_deliveryOrder.fees ?? 0) + (_deliveryOrder.deliveryCharge ?? 0)} EGP",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${_deliveryOrder.productList.map((e) => e.quantity).toList().reduce((v, e) => v += e)} Items",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Payment: ",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${_deliveryOrder.orderPaymentMethod == PaymentMethod.CASH ? "Cash" : "Visa"}",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _deliveryOrder.orderPaymentMethod == PaymentMethod.CASH ? Colors.green : Colors.blue),
                                  )
                                ],
                              ),
                              FittedBox(
                                child: Text(
                                  "${_deliveryOrder.getOrderTime()}",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ]),
                  Divider(
                    height: 30,
                    thickness: 2,
                  ),
                  Text(
                    "${_deliveryOrder.customerName}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${_deliveryOrder.orderAddress}",
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${_deliveryOrder.customerPhone}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(15),
                    color: Colors.black12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              launch("tel://${_deliveryOrder.customerPhone}");
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.phone_in_talk),
                                SizedBox(width: 5),
                                Text("Call Client", style: TextStyle(fontSize: 16))
                              ],
                            )),
                        Container(height: 25, child: VerticalDivider(width: 15, thickness: 1, color: Colors.black)),
                        GestureDetector(
                            onTap: () {
                              MapsLauncher.launchCoordinates(
                                  _deliveryOrder.orderLatLng.latitude, _deliveryOrder.orderLatLng.longitude);
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.location_on),
                                SizedBox(width: 5),
                                Text("Show Map", style: TextStyle(fontSize: 16))
                              ],
                            ))
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                          child: Column(children: _deliveryOrder.productList.map((product) => _productItem(product)).toList()))),
                  SizedBox(height: 5),
                  Center(
                      child: GestureDetector(
                    onTap: (_deliveryOrder.orderStatus == OrderStatus.PREPARED)
                        ? () async {
                            await _pickOrder();
                          }
                        : (_deliveryOrder.orderStatus == OrderStatus.PICKED)
                            ? () async {
                                await _deliverOrder();
                              }
                            : null,
                    child:
                        (_deliveryOrder.orderStatus == OrderStatus.PREPARED || _deliveryOrder.orderStatus == OrderStatus.PICKED)
                            ? Container(

                                padding: EdgeInsets.all(15.0),
                                alignment: FractionalOffset.center,
                                decoration: new BoxDecoration(
                                  color: (_deliveryOrder.orderStatus == OrderStatus.PREPARED)
                                      ? Color.fromRGBO(213, 100, 80, 1)
                                      : (_deliveryOrder.orderStatus == OrderStatus.PICKED) ? Colors.green : Colors.black,
                                  borderRadius: new BorderRadius.all(const Radius.circular(30.0)),
                                ),
                                child: Text(
                                    (_deliveryOrder.orderStatus == OrderStatus.PREPARED)
                                        ? 'Pick Order'
                                        : (_deliveryOrder.orderStatus == OrderStatus.PICKED) ? 'Deliver Order' : '',
                                    style: textStyle.copyWith(color: Colors.white)),
                              )
                            : Container(),
                  ))
                ]),
              ))
        ],
      ),
    );
  }

  Widget _productItem(CartItem cartItem) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Card(
          color: Color(0xFFEAEAEA),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                        child: Text("${cartItem.title} x${cartItem.quantity}",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    Flexible(
                        child: Text(
                      "${cartItem.getTotalPriceAsString()} EGP",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ))
                  ],
                ),
                SizedBox(height: 5),
                Text("${cartItem.ingredients.join(", ")}", style: TextStyle(fontSize: 14)),
                SizedBox(height: 5),
                Text("${cartItem.extras.map((e) => e.name).join(", ")}", style: TextStyle(fontSize: 14)),
              ],
            ),
          )),
      SizedBox(height: 2)
    ]);
  }
}
