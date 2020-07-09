import 'dart:convert';

import 'package:deliveryfood/model/Extra.dart';
import 'package:deliveryfood/model/Product.dart';
import 'package:deliveryfood/model/User.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/user_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class UserFavProductsProvider with ChangeNotifier {
  List<Product> favouritesProducts = [];

  final String _addFavUrl = '$domainName/api/user/addFavourite';

  final String _removeFavUrl = '$domainName/api/user/removeFavourite';
  User user = UserPrefs.getUser();

  Future<void> loadFavProducts() async {
    final String _allFavProducts = '$domainName/api/user/allMyFavourites/${user.id}';

    final response = await http.get(_allFavProducts, headers: {"content-type": "application/json"});

    var responseMap = json.decode(response.body) as Map<String, dynamic>;
    var favProducts = responseMap["favourite"] as List<dynamic>;
    List loadingProducts = [];
    loadingProducts = favProducts
        .map((productItem) => Product(
            productID: productItem["_id"],
            title: productItem["name"],
            price: productItem["price"].toDouble(),
        description:productItem['description'],
        image: productItem['image'],
            ingredients: productItem["ingredients"].cast<String>(),
            extras: (productItem["extras"] as List<dynamic>)
                .map((extraItem) => Extra(name: extraItem['name'], price: extraItem["price"].toDouble()))
                .toList()))
        .toList();
    favouritesProducts = loadingProducts;
    notifyListeners();
  }

  isProductInFavourites(String productID) {
    bool isItemInFav = false;
    for (int i = 0; i < this.favouritesProducts.length; i++) {
      //print(favouritesProducts[i].productID);
      if (favouritesProducts[i].productID == productID) {
        isItemInFav = true;
        break;
      }
    }
    return isItemInFav;
  }

  void removeFacProduct(String productId, [bool notifyListeners = true]) {
    int index = -1;
    for (int i = 0; i < this.favouritesProducts.length; i++) {
      if (favouritesProducts[i].productID == productId) {
        index = i;
        break;
      }
    }
    if (index > -1) {
      this.favouritesProducts.removeAt(index);
      if (notifyListeners) {
        this.notifyListeners();
      }
    }
  }

  Future addItemToFavourites(String productID, String userId, String userToken) async {
    final response = await http.post(_addFavUrl,
        headers: {"content-type": "application/json", "x-auth-token": "$userToken"},
        body: json.encode({"userId": userId, "productId": productID}));
    this.loadFavProducts();
  }

  Future removeItemToFavourites(String productID, String userId, String userToken) async {
    await http.post(_removeFavUrl,
        headers: {"content-type": "application/json", "x-auth-token": "$userToken"},
        body: json.encode({"userId": userId, "productId": productID}));
    this.removeFacProduct(productID, true);
  }
}
