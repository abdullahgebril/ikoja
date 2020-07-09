import 'package:deliveryfood/model/CartItem.dart';
import 'package:deliveryfood/screens/product_details_screen.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/shared.dart';

typedef void OnItemRemoved();

// ignore: must_be_immutable
class CartItemWidget extends StatefulWidget {
  OnItemRemoved onItemRemoved;

  CartItem cartItem;

  String savedId;

  CartItemWidget(this.savedId, this.cartItem, this.onItemRemoved);

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  String productModifiers;

  @override
  void initState() {
    super.initState();
    List<String> extrasNames = widget.cartItem.extras.map<String>((e) => e.name).toList();
    productModifiers = (widget.cartItem.ingredients + extrasNames).join(',');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final cart = Provider.of<Cart>(context);
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey, border: Border.all(color: Colors.white, width: 1)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, new MaterialPageRoute(builder: (_) {
            return new ProductDetailsScreen(widget.cartItem.productId, widget.savedId);
            // clear chache ad test.
          }));
        },
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${widget.cartItem.title} x ${widget.cartItem.quantity}",
                    style: textStyle.copyWith(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 5),
                  Text(
                    productModifiers.isEmpty ? 'No extra ingredient' : productModifiers,
                    style: textStyle.copyWith(fontSize: 16, color: Colors.black54),
                  )
                ],
              ),
            ),
            SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FittedBox(
                  child: Text(
                    'EGP${widget.cartItem.getTotalPriceAsString()}',
                    style: textStyle.copyWith(fontSize: 16, color: Colors.black),
                  ),
                ),
                SizedBox(height: 15),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 35,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Are you sure!?'),
                              content: Text('Do you want remove item from cart?'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('NO'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                FlatButton(
                                  child: Text('YES'),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                    setState(() {
                                      cart.removeProductFromCart(widget.savedId);
                                      widget.onItemRemoved();
                                    });
                                  },
                                ),
                              ],
                            ));
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
