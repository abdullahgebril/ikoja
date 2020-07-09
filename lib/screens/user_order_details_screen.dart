import 'package:deliveryfood/enums/OrderStatus.dart';
import 'package:deliveryfood/enums/PaymentMethod.dart';
import 'package:deliveryfood/model/CustomerOrder.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/customer_api.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/User.dart';
import '../provider/categorys_products_data_provider.dart';
import '../utilities/user_prefs.dart';

class UserOrderDetailsScreen extends StatefulWidget {
  @override
  _UserOrderDetailsScreenState createState() => _UserOrderDetailsScreenState();
}

class _UserOrderDetailsScreenState extends State<UserOrderDetailsScreen> {
  CustomerOrder customerOrder;
  User user;

  CustomerApi dbHelper = CustomerApi();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  void didUpdateWidget(UserOrderDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  void getUser() async {
    this.user = UserPrefs.getUser();
  }

  Future<void> refreshCustomerOrder() async {
    try {
      await Provider.of<DataProvider>(context, listen: false).fetchUserAllOrders(user);
      await dbHelper.refreshOrder(customerOrder).then((order) async {
        setState(() => this.customerOrder = order);
      });
    } catch (error) {
      //var message = "Error happened. Please try again.";
      var message = error.toString();

      showErrorDialog(context, message);
    }
  }

  Future<void> cancelCustomerOrder() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () => Future.value(false),
              child: Dialog(child: Container(height: 100, child: Center(child: CircularProgressIndicator()))));
        });

    try {
      await dbHelper.cancelOrder(user, customerOrder).then((message) async {
        await refreshCustomerOrder();

        Navigator.pop(context);

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                  onWillPop: () => Future.value(false),
                  child: AlertDialog(
                    title: Text("Order Canceled"),
                    content: Text("Your order successfully canceled."),
                    actions: [
                      FlatButton(
                        child: Text("Close"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
            });
      });
    } catch (error) {
      Navigator.pop(context);

      //var message = "Error happened. Please try again.";
      var message = error.toString();

      showErrorDialog(context, message);
    }
  }

  Future<void> confirmVISAOrder() async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
                onWillPop: () => Future.value(false),
                child: Dialog(child: Container(height: 100, child: Center(child: CircularProgressIndicator()))));
          });

      await dbHelper.confirmVISAOrder(customerOrder).then((url) async {
        Navigator.pop(context);
        Navigator.of(context).pushNamed('UserOrderPaymentScreen', arguments: [
          url,
          () async {
            await refreshCustomerOrder();
          }
        ]);
      });
    } catch (error) {
      Navigator.pop(context);

      //var message = "Error happened. Please try again.";
      var message = error.toString();

      showErrorDialog(context, message);
    }
  }

  Future<void> confirmCashOrder() async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
                onWillPop: () => Future.value(false),
                child: Dialog(child: Container(height: 100, child: Center(child: CircularProgressIndicator()))));
          });

      await dbHelper.confirmCashOrder(customerOrder).then((url) async {
        await refreshCustomerOrder();

        Navigator.pop(context);

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                  onWillPop: () => Future.value(false),
                  child: AlertDialog(
                    title: Text("Order Confirmed"),
                    content: Text("Your order successfully confirmed."),
                    actions: [
                      FlatButton(
                        child: Text("Close"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
            });
      });
    } catch (error) {
      Navigator.pop(context);

      //var message = "Error happened. Please try again.";
      var message = error.toString();

      showErrorDialog(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);

    bool isRefreshed = Provider.of<DataProvider>(context).refreshedOrderStatus;
    if (isRefreshed) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await refreshCustomerOrder();
        Provider.of<DataProvider>(context, listen: false).refreshedOrderStatus = false;
      });
    }
    if (customerOrder == null) customerOrder = ModalRoute.of(context).settings.arguments as CustomerOrder;

    return Scaffold(
        body: Stack(children: [
      Container(
        height: screenHeight,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/burgger.jpg'), fit: BoxFit.cover)),
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
            'Following Order',
            style: textStyle.copyWith(fontSize: 25, color: Colors.white),
          )
        ]),
      ),
      Positioned(
        left: 10,
        right: 10,
        bottom: 10,
        child: Container(
          padding: const EdgeInsets.all(8),
          height: screenHeight * 0.88,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      _buildOrderSteps(screenWidth, customerOrder),
                      SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${customerOrder.getOrderTime()}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        "${customerOrder.productList.map((e) => e.quantity).toList().reduce((v, e) => v += e)} Items",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Text(
                                    "EGP ${customerOrder.orderTotalPrice + (customerOrder.fees ?? 0) + (customerOrder.deliveryCharge ?? 0)}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            RichText(
                                text: TextSpan(
                              text: customerOrder.customerPhone,
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            )),
                            SizedBox(
                              height: 5,
                            ),
                            RichText(
                                text: TextSpan(
                              text: customerOrder.orderAddress,
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            )),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Fees: ${(customerOrder.fees != null) ? "${customerOrder.fees} EGP" : "-"}",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Delivery: ${(customerOrder.deliveryCharge != null) ? "${customerOrder.deliveryCharge} EGP" : "-"}",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: screenHeight * 0.35,
                        child: ListView.builder(
                            itemCount: customerOrder.productList.length,
                            itemBuilder: (context, index) => OrderItem(
                                  customerOrder.productList[index].title,
                                  customerOrder.productList[index].price,
                                  customerOrder.productList[index].ingredients,
                                  customerOrder.productList[index].extras,
                                  customerOrder.productList[index].quantity,
                                )),
                      ),
                    ],
                  ))),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                (customerOrder.orderStatus == OrderStatus.ACCEPTED)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: RaisedButton(
                          color: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          onPressed: () =>
                              (customerOrder.orderPaymentMethod == PaymentMethod.VISA) ? confirmVISAOrder() : confirmCashOrder(),
                          child: Center(
                              child: FittedBox(
                            child: Text(
                              'Confirm Order',
                              style: textStyle.copyWith(color: Colors.black, fontSize: 16),
                            ),
                          )),
                        ))
                    : Container(),
                (customerOrder.orderStatus == OrderStatus.PLACED ||
                        customerOrder.orderStatus == OrderStatus.ACCEPTED ||
                        customerOrder.orderStatus != OrderStatus.CANCELLED)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: RaisedButton(
                          color: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          onPressed: cancelCustomerOrder,
                          child: Center(
                              child: FittedBox(
                            child: Text(
                              'Cancel Order',
                              style: textStyle.copyWith(color: Colors.white, fontSize: 16),
                            ),
                          )),
                        ))
                    : Container()
              ])
            ],
          ),
        ),
      ),
    ]));
  }

  Widget _buildOrderSteps(var screenWidth, CustomerOrder customerOrder) {
    final statusTextStyle = TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

    //customerOrder.orderStatus = OrderStatus.PLACED;
    //customerOrder.orderStatus = OrderStatus.ACCEPTED;
    //customerOrder.orderStatus = OrderStatus.CONFIRMED;
    //customerOrder.orderStatus = OrderStatus.PREPARED;
    //customerOrder.orderStatus = OrderStatus.PICKED;
    //customerOrder.orderStatus = OrderStatus.DELEVIRED;
    //customerOrder.orderStatus = OrderStatus.CANCELLED;
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(top: 10),
                  child: Container(
                    height: 3,
                    width: screenWidth,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              FittedBox(
                                child: Text(
                                    (customerOrder.orderStatus == OrderStatus.PLACED)
                                        ? "Order Placed"
                                        : (customerOrder.orderStatus == OrderStatus.CANCELLED)
                                            ? "Canceled"
                                            : (customerOrder.orderStatus == OrderStatus.ACCEPTED) ? "Accepted" : "Confirmed",
                                    style: statusTextStyle,
                                    textAlign: TextAlign.center),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: (customerOrder.orderStatus == OrderStatus.PLACED ||
                                            customerOrder.orderStatus == OrderStatus.ACCEPTED)
                                        ? Colors.lightBlueAccent
                                        : (customerOrder.orderStatus == OrderStatus.CANCELLED)
                                            ? Colors.redAccent
                                            : (customerOrder.orderStatus == OrderStatus.CONFIRMED ||
                                                    customerOrder.orderStatus == OrderStatus.PREPARED ||
                                                    customerOrder.orderStatus == OrderStatus.PICKED ||
                                                    customerOrder.orderStatus == OrderStatus.DELEVIRED)
                                                ? Colors.lightGreen
                                                : Colors.grey),
                                child: Icon(
                                  Icons.add_shopping_cart,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Text(
                                  (customerOrder.orderStatus == OrderStatus.PLACED ||
                                          customerOrder.orderStatus == OrderStatus.ACCEPTED)
                                      ? "Prepare"
                                      : (customerOrder.orderStatus == OrderStatus.CONFIRMED) ? "  Preparing  " : "  Prepared ",
                                  style: statusTextStyle,
                                  textAlign: TextAlign.center),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: (customerOrder.orderStatus == OrderStatus.CONFIRMED)
                                        ? Colors.lightBlueAccent
                                        : (customerOrder.orderStatus == OrderStatus.PREPARED ||
                                                customerOrder.orderStatus == OrderStatus.PICKED ||
                                                customerOrder.orderStatus == OrderStatus.DELEVIRED)
                                            ? Colors.lightGreen
                                            : Colors.grey),
                                child: Icon(
                                  Icons.local_dining,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              FittedBox(
                                child: Text(
                                    (customerOrder.orderStatus == OrderStatus.PICKED ||
                                            customerOrder.orderStatus == OrderStatus.DELEVIRED)
                                        ? "On the Way"
                                        : 'Waiting Pick',
                                    style: statusTextStyle,
                                    textAlign: TextAlign.center),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: (customerOrder.orderStatus == OrderStatus.PICKED ||
                                            customerOrder.orderStatus == OrderStatus.PREPARED)
                                        ? Colors.lightBlueAccent
                                        : (customerOrder.orderStatus == OrderStatus.DELEVIRED) ? Colors.lightGreen : Colors.grey),
                                child: Center(
                                    child: Container(
                                        height: 40,
                                        child: Image.asset(
                                          'assets/images/path.png',
                                          fit: BoxFit.fill,
                                        ))),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Text('  Delivered  ', style: statusTextStyle, textAlign: TextAlign.center),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color:
                                        (customerOrder.orderStatus == OrderStatus.DELEVIRED) ? Colors.lightGreen : Colors.grey),
                                child: Icon(
                                  Icons.home,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OrderItem extends StatefulWidget {
  final String title;
  final double price;
  final List ingredients;
  final List extras;
  final int quantity;

  OrderItem(this.title, this.price, this.ingredients, this.extras, this.quantity);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  String productModifiers;

  @override
  void initState() {
    super.initState();
    List<String> extrasNames = widget.extras.map<String>((e) => e.name).toList();
    productModifiers = (widget.ingredients + extrasNames).join(',');
  }

  double getTotalPrice() {
    if (widget.extras.isNotEmpty) {
      return ((widget.price + widget.extras.map((e) => e.price).toList().reduce((value, element) => element += value)) *
          widget.quantity);
    } else {
      return (widget.price * widget.quantity);
    }
  }

  String getTotalPriceAsString([int fixedDecimalCount = 2]) {
    return getTotalPrice().toStringAsFixed(fixedDecimalCount);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey, border: Border.all(color: Colors.white, width: 1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${widget.title} x${widget.quantity}",
                  style: textStyle.copyWith(fontSize: 16, color: Colors.black),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(productModifiers.isEmpty ? 'No extra ingredient' : productModifiers,
                    style: textStyle.copyWith(fontSize: 14, color: Colors.black54))
              ],
            ),
          ),
          FittedBox(
            child: Column(
              children: <Widget>[
                FittedBox(
                  child: Text(
                    'EGP${getTotalPriceAsString()}',
                    style: textStyle.copyWith(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
