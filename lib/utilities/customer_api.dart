import 'dart:convert';

import 'package:deliveryfood/enums/OrderStatus.dart';
import 'package:deliveryfood/enums/PaymentMethod.dart';
import 'package:deliveryfood/model/CartItem.dart';
import 'package:deliveryfood/model/CustomerOrder.dart';
import 'package:deliveryfood/model/Extra.dart';
import 'package:deliveryfood/model/User.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class CustomerApi with ChangeNotifier {
  //Variables.
  String _makeOrderApi = '$domainName/api/user/makeOrder';
  String _getOrderById = '$domainName/api/order/order/';
  String _cancelOrder = '$domainName/api/user/cancelOrder';
  String _confirmOrderVISAApi = '$domainName/api/payment/';
  String _confirmOrderCashApi = '$domainName/api/user/acceptOrderWithChargeAndFees';
  String _newRateApi = '$domainName/api/user/newRate';

  Future<CustomerOrder> addOrder(CustomerOrder customerOrder) async {
    final response = await http.post(_makeOrderApi,
        headers: jsonHeader(customerOrder.user),
        body: json.encode({
          'userId': customerOrder.user.id,
          'customerName': customerOrder.customerName,
          'customerPhone': customerOrder.customerPhone,
          'customerEmail': customerOrder.customerEmail,
          'customerNote': customerOrder.customerNote,
          'address': customerOrder.orderAddress,
          'lat': customerOrder.orderLatLng.latitude,
          'lng': customerOrder.orderLatLng.longitude,
          'paymentMethod': (customerOrder.orderPaymentMethod == PaymentMethod.CASH) ? 'CASH' : 'VISA',
          'coupon': customerOrder.couponCode,
          'productList': customerOrder.productList
              .map((cartItem) => {
                    'count': cartItem.quantity,
                    'id': cartItem.productId,
                    'name': cartItem.title,
                    'price': cartItem.price,
                    'ingredients': cartItem.ingredients,
                    'extras': cartItem.extras
                  })
              .toList(),
        }));

    throwErrorIfApiHasError(response);
    //print(response.body);
    Map orderMap = json.decode(response.body);

    CustomerOrder order = CustomerOrder(
      id: orderMap["_id"],
      productList: (orderMap['productList'] as List<dynamic>)
          .map((cartItem) => CartItem(
              productId: cartItem["id"],
              quantity: cartItem["count"],
              title: cartItem["name"],
              price: cartItem["price"].toDouble(),
              ingredients: List<String>.from(cartItem["ingredients"]),
              extras: (cartItem["extras"] as List<dynamic>)
                  .map((extraItem) => Extra(name: extraItem['name'], price: extraItem["price"].toDouble()))
                  .toList()))
          .toList(),
      customerName: orderMap["customerName"],
      customerPhone: orderMap["customerPhone"],
      customerEmail: orderMap["customerEmail"],
      customerNote: orderMap["customerNote"],
      orderLatLng: LatLng(double.parse(orderMap["lat"]), double.parse(orderMap["lng"])),
      orderPaymentMethod: (orderMap["paymentMethod"] == "CASH") ? PaymentMethod.CASH : PaymentMethod.VISA,
      orderStatus: OrderStatusClass.getOrderStatus(orderMap["status"]),
      orderTotalPrice: orderMap["price"].toDouble(),
      deliveryCharge: orderMap["deliveryCharge"]?.toDouble(),
      fees: orderMap["fees"]?.toDouble(),
      orderAddress: orderMap["address"],
      couponsValue: orderMap["couponsValue"].toDouble(),
      orderTime: DateTime.parse(orderMap["placedTime"]),
    );
    return order;
  }

  Future<CustomerOrder> refreshOrder(CustomerOrder customerOrder) async {
    final response = await http.get("$_getOrderById${customerOrder.id}", headers: {"content-type": "application/json"});

    throwErrorIfApiHasError(response);
    //print(response.body);
    Map orderMap = json.decode(response.body);

    CustomerOrder order = CustomerOrder(
      id: orderMap["_id"],
      productList: (orderMap['productList'] as List<dynamic>)
          .map((cartItem) => CartItem(
              productId: cartItem["id"],
              quantity: cartItem["count"],
              title: cartItem["name"],
              price: cartItem["price"].toDouble(),
              ingredients: List<String>.from(cartItem["ingredients"]),
              extras: (cartItem["extras"] as List<dynamic>)
                  .map((extraItem) => Extra(name: extraItem['name'], price: extraItem["price"].toDouble()))
                  .toList()))
          .toList(),
      customerName: orderMap["customerName"],
      customerPhone: orderMap["customerPhone"],
      customerEmail: orderMap["customerEmail"],
      customerNote: orderMap["customerNote"],
      orderLatLng: LatLng(double.parse(orderMap["lat"]), double.parse(orderMap["lng"])),
      orderPaymentMethod: (orderMap["paymentMethod"] == "CASH") ? PaymentMethod.CASH : PaymentMethod.VISA,
      orderStatus: OrderStatusClass.getOrderStatus(orderMap["status"]),
      orderTotalPrice: orderMap["price"].toDouble(),
      deliveryCharge: orderMap["deliveryCharge"]?.toDouble(),
      fees: orderMap["fees"]?.toDouble(),
      orderAddress: orderMap["address"],
      couponsValue: orderMap["couponsValue"].toDouble(),
      orderTime: DateTime.parse(orderMap["placedTime"]),
    );
    return order;
  }

  Future cancelOrder(User user, CustomerOrder customerOrder) async {
    final response = await http.post(_cancelOrder,
        headers: jsonHeader(user), body: json.encode({'userId': user.id, 'orderId': customerOrder.id}));

    throwErrorIfApiHasError(response);
    //print(response.body);
    Map orderMap = json.decode(response.body);
    return orderMap["message"];
  }

  Future newRate(User user, double rateQuestion1, double rateQuestion2, double rateQuestion3, double rateQuestion4,
      double rateQuestion5) async {
    final response = await http.post(_newRateApi,
        headers: jsonHeader(user),
        body: json.encode({
          'userId': user.id,
          'rateQuestion1': rateQuestion1,
          'rateQuestion2': rateQuestion2,
          'rateQuestion3': rateQuestion3,
          'rateQuestion4': rateQuestion4,
          'rateQuestion5': rateQuestion5,
        }));
    throwErrorIfApiHasError(response);
    var body = json.decode(response.body);
    return body["message"];
  }

  Future<String> confirmVISAOrder(CustomerOrder customerOrder) async {
    final response = await http.post(_confirmOrderVISAApi,
        headers: {"content-type": "application/json"},
        body: json.encode({
          "orderDetails": {
            '_id': customerOrder.id,
            'userId': customerOrder.userId,
            'customerName': customerOrder.customerName,
            'customerPhone': customerOrder.customerPhone,
            'customerEmail': customerOrder.customerEmail,
            'customerNote': customerOrder.customerNote,
            'price': customerOrder.orderTotalPrice + (customerOrder.fees ?? 0) + (customerOrder.deliveryCharge ?? 0),
            'address': customerOrder.orderAddress,
            'lat': customerOrder.orderLatLng.latitude,
            'lng': customerOrder.orderLatLng.longitude,
            'paymentMethod': (customerOrder.orderPaymentMethod == PaymentMethod.CASH) ? 'CASH' : 'VISA',
            'productList': customerOrder.productList
                .map((cartItem) => {
                      'count': cartItem.quantity,
                      'id': cartItem.productId,
                      'name': cartItem.title,
                      'price': cartItem.price,
                      'ingredients': cartItem.ingredients,
                      'extras': cartItem.extras
                    })
                .toList(),
          }
        }));
    throwErrorIfApiHasError(response);
    var body = json.decode(response.body);
    return body["Location"];
  }

  Future confirmCashOrder(customerOrder) async {
    final response = await http.post(_confirmOrderCashApi,
        headers: {"content-type": "application/json"}, body: json.encode({'orderId': customerOrder.id}));
    throwErrorIfApiHasError(response);
  }

  void throwErrorIfApiHasError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw Exception(response.body);
    }
  }

  Map<String, String> buildMap(String key, String value) {
    return {key: value};
  }

  Map<String, String> jsonHeader(User user) {
    return {"content-type": "application/json", "x-auth-token": user.token};
  }

  String buildBody(Map<String, String> body) {
    return json.encode(body);
  }
}
