import 'dart:convert';

import 'package:deliveryfood/Logger.dart';
import 'package:deliveryfood/model/Extra.dart';
import 'package:deliveryfood/utilities/app_util.dart';
import 'package:deliveryfood/utilities/cart_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CartItem {
  final String productId;
  final String title;
  final double price;
  double priceWithExtra;
  int quantity;
  List<String> ingredients;
  List<Extra> extras;

  CartItem({this.productId, this.title, this.price, this.priceWithExtra, this.ingredients, this.extras, this.quantity = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    List<dynamic> ing = json['ingredients'];
    List<String> ingNames = ing.map((e) => e.toString()).toList();
    return CartItem(
        productId: json['id'],
        title: json['title'],
        price: json['price'],
        priceWithExtra: json['priceWithExtra'],
        quantity: json['quantity'],
        ingredients: ingNames,
        extras: (json['extras'] as List<dynamic>).map((e) => Extra(name: e['name'], price: e['price'].toDouble())).toList());
  }

  Map toJson() => {
        'id': this.productId,
        'title': this.title,
        'price': this.price,
        'priceWithExtra': this.priceWithExtra,
        'quantity': this.quantity,
        'ingredients': this.ingredients,
        'extras': this.extras
      };

  @override
  String toString() {
    return json.encode(toJson());
  }

  String getTotalPriceAsString([int fixedDecimalCount = 2]) {
    return getTotalPrice().toStringAsFixed(fixedDecimalCount);
  }

  double getTotalPrice() {
    if (this.extras.isNotEmpty) {
      return ((this.price + this.extras.map((e) => e.price).toList().reduce((value, element) => element += value)) *
          this.quantity);
    } else {
      return (this.price * this.quantity);
    }
  }
}

class Cart with ChangeNotifier {
  Map<String, CartItem> items = {};
//  double totalAmount = 0.0;

  Cart() {
    this.initCartItemsMap();
  }

  void initCartItemsMap() {
    items = CartPref.getCart();
  }

  void addItem(String cartId, CartItem cartItem) {
    if (cartId != null) {
      // update
      items.update(
        cartId,
        (existingItem) => CartItem(
          productId: existingItem.productId,
          title: existingItem.title,
          price: cartItem.price,
          priceWithExtra: cartItem.priceWithExtra,
          ingredients: cartItem.ingredients,
          extras: cartItem.extras,
          quantity: existingItem.quantity,
        ),
      );
    } else {
      // add
      items.putIfAbsent(
          AppUtil.generateUniqueId(),
          () => CartItem(
              productId: cartItem.productId,
              title: cartItem.title,
              price: cartItem.price,
              priceWithExtra: cartItem.priceWithExtra,
              ingredients: cartItem.ingredients,
              extras: cartItem.extras,
              quantity: cartItem.quantity));
    }
    _saveCartAndNotifyListeners();
  }

  void _saveCartAndNotifyListeners() {
    CartPref.saveCart();
    notifyListeners();
  }



  void removeProductFromCart(String cardId) {
    CartPref.removeProduct(cardId);
    print("notifyListeners");
    notifyListeners();

  }

   double getTotalAmountFromCash(){
    double totalAmount = 0.0;
    totalAmount = CartPref.totalAmount();
    // notifyListeners();
    return totalAmount;
  }
}
