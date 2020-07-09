import 'dart:convert';

import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/user_prefs.dart';
import 'package:http/http.dart' as http;

class AuthApi {
  //Variables.
  String _driverLoginApi = '$domainName/api/driver/login';
  String _userLoginApi = '$domainName/api/user/login';
  String _userLoginFBApi = '$domainName/api/user/loginFB';

  String _userSingUpApi = '$domainName/api/user/signup';
  String _userSingUpFBApi = '$domainName/api/user/signupFB';

  String userApi = '$domainName/api/user';

  String _setUserTokenApi = '$domainName/api/user/setNoficationtoken/';
  String _removeUserTokenApi = '$domainName/api/user/removeNotifcationToken/';

  Future userLogin(String phoneNumber, String password) async {
    // build request body.
    var body = {'phone': phoneNumber, 'password': password};
    final response = await http.post(this._userLoginApi, headers: jsonHeader(), body: buildBody(body));
    throwErrorIfApiHasError(response);
    UserPrefs.saveUser(response.body, "user");
  }

  Future userLoginFB(String facebookID) async {
    // build request body.
    var body = {'facebookID': facebookID};
    final response = await http.post(this._userLoginFBApi, headers: jsonHeader(), body: buildBody(body));
    throwErrorIfApiHasError(response);
    UserPrefs.saveUser(response.body, "user");
  }

  void throwErrorIfApiHasError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw Exception(response.body);
    }
  }

  Future<void> singUp(String name, String phoneNumber, String password) async {
    var body = {'name': name, 'phone': phoneNumber, 'password': password};
    final response = await http.post(_userSingUpApi, headers: jsonHeader(), body: buildBody(body));
    throwErrorIfApiHasError(response);
    UserPrefs.saveUser(response.body, "user");
  }

  Future<void> singUpFB(String name, String phoneNumber, String facebookID, String facebookToken, String email) async {
    var body = {'name': name, 'phone': phoneNumber, 'facebookID': facebookID, 'facebookToken': facebookToken, 'email': email};
    final response = await http.post(_userSingUpFBApi, headers: jsonHeader(), body: buildBody(body));
    throwErrorIfApiHasError(response);
    UserPrefs.saveUser(response.body, "user");
  }

  Future driverLogin(String email, String password) async {
    // build request body.
    var body = {'phone': email, 'password': password};
    final response = await http.post(this._driverLoginApi, headers: jsonHeader(), body: buildBody(body));
    throwErrorIfApiHasError(response);
    UserPrefs.saveUser(response.body, "driver");
  }

  Future setUserToken(user, token) async {
    // build request body.
    var body = {'token': "$token"};
    final response = await http.post("${this._setUserTokenApi}${user.id}", headers: jsonHeader(), body: buildBody(body));
    throwErrorIfApiHasError(response);
  }

  Future removeUserToken(user) async {
    // build request body.
    final response = await http.post("${this._removeUserTokenApi}${user.id}", headers: jsonHeader());
    throwErrorIfApiHasError(response);
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
}
