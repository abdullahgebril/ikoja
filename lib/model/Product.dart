import 'package:deliveryfood/model/Extra.dart';

class Product {
  final String productID;
  final String title;
  final String description;
  final String image;
  double price;
  final List<String> ingredients;
  final List<Extra> extras;
  bool isFavorite;
  double priceWithExtras;

  Product(
      {this.productID,
      this.title,
      this.description,
      this.image,
      this.price,
      this.ingredients,
      this.extras,
      this.isFavorite = false}) {
    this.priceWithExtras = 0;
  }

  void calcProductPrice(List<String> selectedExtras) {
    this.priceWithExtras = 0;
    selectedExtras.forEach((item) => this.priceWithExtras += extras.firstWhere((extra) => extra.name == item).price);
  }
}
