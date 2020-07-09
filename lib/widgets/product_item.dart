import 'package:deliveryfood/screens/product_details_screen.dart';
import 'package:flutter/material.dart';

import '../model/Product.dart';
import '../shared/shared.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product.productID, null)));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 3, 10, 3),
        child: Container(
          height: screenHeight * 0.22,
          child: Card(
            color: blackColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), side: new BorderSide(color: Colors.white, width: 1.0)),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white, width: 0.5))),
                    child: FractionallySizedBox(
                      heightFactor: 0.8,
                      widthFactor: 1,
                      child: CachedNetworkImage(
                        imageUrl:product.image,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => Container(),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.02,
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FittedBox(
                          child: Text(
                            product.title,
                            style: textStyle.copyWith(fontSize: 22),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.018,
                        ),
                        Expanded(child: Text(product.description, style: textStyle.copyWith(fontSize: 12, color: Colors.white))),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'EGP ${product.price}',
                            style: textStyle.copyWith(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
