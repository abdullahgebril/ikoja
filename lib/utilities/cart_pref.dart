import 'dart:async';
import 'dart:convert';

import 'package:deliveryfood/Logger.dart';
import 'package:deliveryfood/model/CartItem.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPref {
  static SharedPreferences sharedPreferences;
  static Map<String, CartItem> cartItems;

  static void init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    cartItems = getCart();
  }

  static void saveCart() async {
    String cart = json.encode(cartItems);
    await CartPref._saveString("cart", cart);
  }

  static Future<void> _saveString(String key, String data) async {
    sharedPreferences.setString(key, data);
  }

  static Map<dynamic, CartItem> getCart() {
    if (cartItems != null) return cartItems;
    String cart = sharedPreferences.getString("cart");
    Map<String, CartItem> savedCartItems = {};
    if (cart != null && cart != 'null') {
      Map<String, dynamic> savedItems = json.decode(cart);
      savedItems.forEach((key, value) {
        savedCartItems.putIfAbsent(key, () => CartItem.fromJson(value));
      });
    }
    return savedCartItems;
  }

  static List<CartItem> getCartItems() {
    List<CartItem> cartItems = List();
    Map<String, CartItem> cartList = CartPref.getCart();
    cartList.forEach((key, value) => cartItems.add(value));
    return cartItems;
  }

  /// get total amount for cart list
  static double totalAmount() {
    double total = 0.0;
    cartItems.forEach((key, cartItem) {
      total += cartItem.getTotalPrice();
    });
    return total;
  }

  static void removeProduct(String cardId) {
//    Logger.log(cardId);
  print(cardId);
    if (cartItems.containsKey(cardId)) {
   //   Logger.log("remove contains item");
      print("remove contains item");
      cartItems.remove(cardId);
     // print("remove contains item");
     print("items size "+cartItems.length.toString());
      CartPref.saveCart();
       print("done");
    }
  }

  static void clearCartPref() {
    sharedPreferences.clear();
  }

  static void clearCarItems() {
    cartItems.clear();
    CartPref.saveCart();
  }
}
