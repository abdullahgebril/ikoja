import 'Product.dart';

class Category {
  String categoryId;
  String title;
  String image;
  List<Product> products;

  Category({this.categoryId, this.title, this.image, this.products});
}
