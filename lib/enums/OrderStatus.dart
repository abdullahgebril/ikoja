enum OrderStatus { PLACED, ACCEPTED, CONFIRMED, PREPARED, PICKED, DELEVIRED, CANCELLED }

class OrderStatusClass {
  static OrderStatus getOrderStatus(String value) {
    return OrderStatus.values
        .firstWhere((status) => status.toString().replaceAll("OrderStatus.", "") == value, orElse: () => OrderStatus.PLACED);
  }
}
