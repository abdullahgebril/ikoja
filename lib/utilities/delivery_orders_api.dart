import 'dart:convert';

import 'package:deliveryfood/model/DeliveryOrder.dart';
import 'package:deliveryfood/model/Driver.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/user_prefs.dart';
import 'package:http/http.dart' as http;

class DeliveryOrdersApi {
  //Variables.
  String _pickOrderApi = '$domainName/api/driver/pickNewOrder';
  String _deliverOrderApi = '$domainName/api/driver/deliverOrder';

  String _setPresence = '$domainName/api/driver/setPresence/';

  Future pickOrder(DeliveryOrder order, Driver driver) async {
    // build request body.
    var body = {'orderId': order.id, 'driverId': driver.id};
    final response = await http.put(this._pickOrderApi, headers: jsonHeader(driver), body: buildBody(body));
    throwErrorIfApiHasError(response);
  }

  Future deliverOrder(DeliveryOrder order, Driver driver) async {
    // build request body.
    var body = {'orderId': order.id, 'driverId': driver.id};
    final response = await http.post(this._deliverOrderApi, headers: jsonHeader(driver), body: buildBody(body));
    throwErrorIfApiHasError(response);
  }

  Future setPresence(Driver driver) async {
    var url = "${this._setPresence}${driver.id}";
    final response = await http.get(url, headers: jsonHeader(driver));
    throwErrorIfApiHasError(response);
    var value = json.decode(response.body);
    Driver updatedDriver = Driver.fromJson(value);
    driver.presence = updatedDriver.presence;

    String newUserPref = UserPrefs.getUserAsString();

    if (newUserPref.contains('"presence":false')) {
      newUserPref = newUserPref.replaceAll('"presence":false', '"presence":${driver.presence}');
    } else if (newUserPref.contains('"presence":true')) {
      newUserPref = newUserPref.replaceAll('"presence":true', '"presence":${driver.presence}');
    }

    UserPrefs.saveUser(newUserPref, "driver");
    return driver;
  }

  void throwErrorIfApiHasError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw Exception(response.body);
    }
  }

  Map<String, String> buildMap(String key, String value) {
    return {key: value};
  }

  Map<String, String> jsonHeader(Driver driver) {
    return {"content-type": "application/json", "x-auth-token": driver.token};
  }

  String buildBody(Map<String, String> body) {
    return json.encode(body);
  }
}
