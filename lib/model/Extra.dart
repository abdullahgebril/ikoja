import 'dart:convert';

class Extra {
  String name;
  double price;

  Extra({this.name, this.price});

  Extra.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
