import 'dart:convert';

import 'package:deliveryfood/enums/PaymentMethod.dart';
import 'package:deliveryfood/model/CartItem.dart';
import 'package:deliveryfood/model/CustomerOrder.dart';
import 'package:deliveryfood/model/Driver.dart';
import 'package:deliveryfood/model/Extra.dart';
import 'package:deliveryfood/model/User.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../enums/OrderStatus.dart';
import '../model/CartItem.dart';
import '../model/Category.dart';
import '../model/DeliveryOrder.dart';
import '../model/Product.dart';

class DataProvider with ChangeNotifier {
  bool refreshedOrderStatus = false;

  final String _allProductsApi = '$domainName/api/product/';

  final String _categoryApi = '$domainName/api/category/category/';

  final String _allOrdersForDeliveryApi = '$domainName/api/order/allOrdersForDriver/';

  final String _allUserOrders = '$domainName/api/user/getAllMyOrders/';
  final String _allDriverOrders = '$domainName/api/order/driverHistory/';

  List<Category> categories = [];

  List<Product> products = [];
  List<DeliveryOrder> deliveryOrders = [];
  List<DeliveryOrder> driverOrders = [];
  List<CustomerOrder> userOrders = [];

  List<Product> get favourites {
    return products.where((product) => product.isFavorite).toList();
  }

  Product getProductById(String productId) {
    return products.firstWhere((p) => p.productID == productId);
  }

  Map<String, String> buildMap(String key, String value) {
    return {key: value};
  }

  Map<String, String> jsonHeader() {
    return buildMap("content-type", "application/json");
  }

  String buildBody(Map<String, String> body) {
    return json.encode(body);
  }

  void refreshOrder() {
    refreshedOrderStatus = true;
    notifyListeners();
    //refreshedOrderStatus = false;
  }

  Future fetchCategories() async {
    List loadingCategories = [];
    final response = await http.get(_categoryApi, headers: jsonHeader());

    var categoriesData = json.decode(response.body) as List<dynamic>;
    loadingCategories = categoriesData
        .map((category) => Category(
            categoryId: category["_id"],
            title: category["name"],
            image: category["image"],
            products: (category["productList"] as List<dynamic>)
                .map((productItem) => Product(
                    productID: productItem["_id"],
                    title: productItem["name"],
                    price: productItem["price"].toDouble(),
                    description:productItem['description'],
                    image: productItem['image'],
                    ingredients: productItem["ingredients"].cast<String>(),
                    extras: (productItem["extras"])
                        .map<Extra>((extraItem) => Extra(name: extraItem['name'], price: extraItem["price"].toDouble()))
                        .toList()))
                .toList()))
        .toList();
    categories = loadingCategories;
    notifyListeners();
  }

  Future fetchProducts() async {
    final response = await http.get(_allProductsApi, headers: jsonHeader());

    var productData = json.decode(response.body) as List<dynamic>;
    List loadingProducts = [];
    loadingProducts = productData
        .map((productItem) => Product(
            productID: productItem["_id"],
            title: productItem["name"],
            price: productItem["price"].toDouble(),
            description: productItem['description'],
            image: productItem['image'],
            ingredients: productItem["ingredients"].cast<String>(),
            extras: (productItem["extras"] as List<dynamic>)
                .map((extraItem) => Extra(name: extraItem['name'], price: extraItem["price"].toDouble()))
                .toList()))
        .toList();
    products = loadingProducts;
    notifyListeners();
  }

  Future fetchDeliveryOrders(Driver driver) async {
    final body = {"driverId": "${driver.id}"};
    final response =
        await http.post(_allOrdersForDeliveryApi, headers: {'content-type': 'application/json'}, body: buildBody(body));

    var ordersDataMap = json.decode(response.body) as Map<String, dynamic>;
    var ordersData = List<dynamic>.from(ordersDataMap["ordersList"]);
    List loadingProducts = [];
    loadingProducts = ordersData
        .map((deliverOrderItem) => DeliveryOrder(
              id: deliverOrderItem["_id"],
              productList: (deliverOrderItem["productList"] as List<dynamic>)
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
              customerName: deliverOrderItem["customerName"],
              customerPhone: deliverOrderItem["customerPhone"],
              orderTotalPrice: deliverOrderItem["price"].toDouble(),
              orderStatus: OrderStatusClass.getOrderStatus(deliverOrderItem["status"]),
              orderAddress: deliverOrderItem["address"],
              orderLatLng: LatLng(double.parse(deliverOrderItem["lat"]), double.parse(deliverOrderItem["lng"])),
              orderTime: DateTime.parse(deliverOrderItem["createdAt"]),
              orderPaymentMethod: (deliverOrderItem["paymentMethod"] == "CASH") ? PaymentMethod.CASH : PaymentMethod.VISA,
      deliveryCharge: deliverOrderItem["deliveryCharge"]?.toDouble(),
      fees: deliverOrderItem["fees"]?.toDouble(),

            ))
        .toList();
    deliveryOrders = loadingProducts;
    notifyListeners();
    return deliveryOrders;
  }

  Future fetchDriverAllOrders(Driver user) async {
    final response = await http.get("$_allDriverOrders${user.id}", headers: {'content-type': 'application/json'});

    //var ordersDataMap = json.decode(response.body) as Map<String, dynamic>;
    var ordersData = List<dynamic>.from(json.decode(response.body));
    List loadingProducts = [];
    loadingProducts = ordersData
        .map((deliverOrderItem) => DeliveryOrder(
              id: deliverOrderItem["_id"],
              productList: (deliverOrderItem["productList"] as List<dynamic>)
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
              customerName: deliverOrderItem["customerName"],
              customerPhone: deliverOrderItem["customerPhone"],
              orderTotalPrice: deliverOrderItem["price"].toDouble(),
              orderStatus: OrderStatusClass.getOrderStatus(deliverOrderItem["status"]),
              orderAddress: deliverOrderItem["address"],
              orderLatLng: LatLng(double.parse(deliverOrderItem["lat"]), double.parse(deliverOrderItem["lng"])),
              orderTime: DateTime.parse(deliverOrderItem["createdAt"]),
              orderPaymentMethod: (deliverOrderItem["paymentMethod"] == "CASH") ? PaymentMethod.CASH : PaymentMethod.VISA,
      deliveryCharge: deliverOrderItem["deliveryCharge"]?.toDouble(),
      fees: deliverOrderItem["fees"]?.toDouble(),
            ))
        .toList();
    driverOrders = loadingProducts;
    notifyListeners();
    return driverOrders;
  }

  Future fetchUserAllOrders(User user) async {
    final response = await http.get("$_allUserOrders${user.id}", headers: {'content-type': 'application/json'});

    var ordersData = List<dynamic>.from(json.decode(response.body));

    List loadingProducts = [];

    loadingProducts = ordersData
        .map((userOrderItem) => CustomerOrder(
              id: userOrderItem["_id"],
              productList: (userOrderItem['productList'] as List<dynamic>)
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
              customerName: userOrderItem["customerName"],
              customerPhone: userOrderItem["customerPhone"],
              orderStatus: OrderStatusClass.getOrderStatus(userOrderItem["status"]),
              orderTotalPrice: userOrderItem["price"].toDouble(),
              deliveryCharge: userOrderItem["deliveryCharge"]?.toDouble(),
              fees: userOrderItem["fees"]?.toDouble(),
              orderAddress: userOrderItem["address"],
              couponsValue: userOrderItem["couponsValue"].toDouble(),
              orderTime: DateTime.parse(userOrderItem["placedTime"]),
              customerEmail: userOrderItem["customerEmail"],
              customerNote: userOrderItem["customerNote"],
              orderPaymentMethod: (userOrderItem["paymentMethod"] == "CASH") ? PaymentMethod.CASH : PaymentMethod.VISA,
              orderLatLng: LatLng(double.parse(userOrderItem["lat"]), double.parse(userOrderItem["lng"])),
              userId: userOrderItem["userId"],
            ))
        .toList();
    userOrders = loadingProducts;
    notifyListeners();
    return userOrders;
  }
}
