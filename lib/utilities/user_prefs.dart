import 'dart:convert';

import 'package:deliveryfood/model/User.dart';
import 'package:deliveryfood/utilities/cart_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_api.dart';

class UserPrefs {
  static SharedPreferences sharedPreferences;

  static void init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static void saveUser(String data, String userType) async {
    await UserPrefs._saveString("user", data);
    await UserPrefs._saveString("user_type", userType);
  }

//  static void saveUserFavouritesProducts(List<Favourite> favourites) async {
//    await UserPrefs._saveString("user_favourites", json.encode(favourites));
//  }

  static Future<void> _saveString(String key, String data) async {
    sharedPreferences.setString(key, data);
  }

  static String getUserFavouritesProducts() {
    return sharedPreferences.getString("user_favourites");
  }

  static bool isUserLogined() {
    return sharedPreferences.containsKey("user");
  }

  static String getUserType() {
    return sharedPreferences.getString("user_type");
  }

  static String getUserAsString() {
    return sharedPreferences.getString("user");
  }

  static User getUser() {
    User user;
    String savedUser = getUserAsString();
    if (savedUser != null) {
      user = User.fromJson(jsonDecode(savedUser));
    }
    return user;
  }

  static Future<void> deleteUser(user) async {
    try {
      AuthApi authHelper = AuthApi();
      await authHelper.removeUserToken(user);
    } catch (_) {}
    sharedPreferences.clear();
    CartPref.clearCartPref();
    CartPref.clearCarItems();
  }
}
