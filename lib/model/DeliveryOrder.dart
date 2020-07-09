import 'package:deliveryfood/enums/PaymentMethod.dart';
import 'package:deliveryfood/model/CartItem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../enums/OrderStatus.dart';

class DeliveryOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  OrderStatus orderStatus = OrderStatus.PREPARED;
  double orderTotalPrice;
  String orderAddress;
  LatLng orderLatLng;
  final List<CartItem> productList;
  DateTime orderTime;
  PaymentMethod orderPaymentMethod = PaymentMethod.CASH;
  final double deliveryCharge;
  final double fees;

  DeliveryOrder(
      {this.id,
      this.productList,
      this.customerName,
      this.customerPhone,
      this.orderStatus,
      this.orderTotalPrice,
      this.orderAddress,
      this.orderLatLng,
      this.orderTime,
      this.orderPaymentMethod,this.deliveryCharge,
        this.fees,});

  String getOrderTime() {
    String timeType = (this.orderTime.hour < 12) ? "AM" : "PM";
    var dateFormatter = DateFormat('dd/MM/yyyy hh:mm ');
    var time =this.orderTime.toLocal();
    return dateFormatter.format(DateTime(time.year, time.month, time.day, time.hour, time.minute)) + "$timeType";
  }
}
