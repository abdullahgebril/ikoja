import 'package:deliveryfood/model/Product.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:flutter/material.dart';

import '../screens/product_details_screen.dart';
import '../shared/shared.dart';

class FavouriteItem extends StatefulWidget {
  final Product favouriteProduct;

  FavouriteItem(this.favouriteProduct);

  @override
  _FavouriteItemState createState() => _FavouriteItemState();
}

class _FavouriteItemState extends State<FavouriteItem> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey, border: Border.all(color: Colors.white, width: 1)),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${widget.favouriteProduct.title}",
                  style: textStyle.copyWith(fontSize: 20, color: Colors.black),
                ),
                SizedBox(height: 5),
                Text(widget.favouriteProduct.description)
              ],
            ),
          ),
          SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              FittedBox(
                child: Text(
                  '\$${widget.favouriteProduct.price}',
                  style: textStyle.copyWith(fontSize: 20, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 40,
                width: 60,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(width: 2, color: Colors.red)),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                        return new ProductDetailsScreen(widget.favouriteProduct.productID, null);
                      }));
                    },
                    child: Icon(
                      Icons.arrow_right,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
