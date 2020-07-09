import 'package:deliveryfood/enums/PaymentMethod.dart';
import 'package:deliveryfood/model/CartItem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../enums/OrderStatus.dart';
import 'User.dart';

class CustomerOrder {
  final String id;
  final User user;
  final String userId;
  final String customerName;
  final String customerPhone;
  OrderStatus orderStatus = OrderStatus.PREPARED;
  final double orderTotalPrice;
  final String orderAddress;
  final LatLng orderLatLng;
  final String customerEmail;
  final String customerNote;
  final List<CartItem> productList;
  final String couponCode;
  final double couponsValue;
  final PaymentMethod orderPaymentMethod;
  final double deliveryCharge;
  final double fees;
  DateTime orderTime;

  CustomerOrder(
      {this.id,
      this.productList,
      this.user,
      this.userId,
      this.customerName,
      this.customerPhone,
      this.orderStatus,
      this.orderTotalPrice,
      this.orderAddress,
      this.orderLatLng,
      this.customerEmail,
      this.couponCode,
      this.couponsValue,
      this.customerNote,
      this.orderPaymentMethod,
      this.deliveryCharge,
      this.fees,
      this.orderTime});

  String getOrderTime() {
    String timeType = (this.orderTime.hour < 12) ? "AM" : "PM";
    var dateFormatter = DateFormat('dd/MM/yyyy hh:mm ');
    var time =this.orderTime.toLocal();
    return dateFormatter.format(DateTime(time.year, time.month, time.day, time.hour, time.minute)) + "$timeType";
  }
}
