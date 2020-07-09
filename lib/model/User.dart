class User {
  final String token;
  final String id;
  final String name;
  final String phone;
  List<dynamic> favourites;

  User({this.token, this.id, this.name, this.phone, this.favourites});

  Map toJson() => {'token': token, 'id': id, 'name': name, 'phone': phone, 'favourite': favourites};

  factory User.fromJson(Map<String, dynamic> json) {
    return User(token: json['token'], id: json['id'], name: json['name'], phone: json['phone'], favourites: json['favourite']);
  }
}
