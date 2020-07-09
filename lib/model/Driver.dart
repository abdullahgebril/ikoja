class Driver {
  final String token;
  final String id;
  final String name;
  final String phone;
  bool presence;

  Driver({this.token, this.id, this.name, this.phone, this.presence});

  Map toJson() => {'token': token, 'id': id, 'name': name, 'phone': phone, 'presence': presence};

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(token: json['token'], id: json['id'], name: json['name'], phone: json['phone'], presence: json["presence"]);
  }
}
