import 'dart:convert';

import 'package:deliveryfood/libraries/checkbox_group/src/checkboxOrientation.dart';
import 'package:deliveryfood/libraries/checkbox_group/src/groupedCheckbox.dart';
import 'package:deliveryfood/model/Extra.dart';
import 'package:deliveryfood/model/User.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/customer_api.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:deliveryfood/utilities/user_fav_products_provider.dart';
import 'package:deliveryfood/widgets/shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/CartItem.dart';
import '../model/Product.dart';
import '../provider/categorys_products_data_provider.dart';
import '../utilities/user_prefs.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final savedCardId;

  ProductDetailsScreen(this.productId, this.savedCardId);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  //variables
  bool expanded = false;
  bool _isFavourite = false;
  User user;
  bool isFavorite = false;
  Product product;

  //List of Extra and ingredients items
  List<String> ingredientsNames;
  List<String> extrasNames;

  CustomerApi customerApi = CustomerApi();
  bool callRebuildFirstTime = true;
  DataProvider dataProvider;
  CartItem cartItem;

  //initState
  @override
  void initState() {
    super.initState();
    var value = json.decode(UserPrefs.getUserAsString());
    user = User.fromJson(value);
  }

  @override
  Widget build(BuildContext context) {
    //Screen Size
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);

    //Providers
    Cart cart = Provider.of<Cart>(context);
    dataProvider = Provider.of<DataProvider>(context);

    //get selected products from products list
    product = dataProvider.products.firstWhere((pro) => pro.productID == widget.productId, orElse: () => null);
    if (product == null) {
      this.loadProducts(dataProvider);
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    ingredientsNames = product.ingredients.map((item) => item.toString()).toList();
    extrasNames = product.extras.map((extra) => extra.name).toList();

    if (widget.savedCardId != null && callRebuildFirstTime) {
      cartItem = cart.items[widget.savedCardId];
    } else if (cartItem == null) {
      cartItem = new CartItem(
          productId: product.productID,
          title: product.title,
          price: product.price,
          priceWithExtra: product.price,
          ingredients: [],
          quantity: 1,
          extras: []);
    }

    final UserFavProductsProvider userFavProductsProvider = Provider.of<UserFavProductsProvider>(context);
    this._isFavourite = userFavProductsProvider.isProductInFavourites(product.productID);

    return Scaffold(
      body: Stack(children: <Widget>[
        appBackground(screenHeight),
        backArrow(),
        favouriteIcon(),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        Positioned(
            top: screenHeight * 0.13,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            child: Container(
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(text: product.title, style: textStyle.copyWith(fontSize: 23)),
                    ),
                  ),
                  Text(
                    'EGP ${cartItem.getTotalPriceAsString()}',
                    style: textStyle.copyWith(fontSize: 16),
                  ),
                ],
              ),
            )),

      Positioned(
        top: screenHeight * 0.23,
        child:  Container(
          padding: EdgeInsets.all(15),
          height: screenHeight * 0.4,
          width: screenWidth ,
          child: Image.network(
            product.image,
            fit: BoxFit.fill,
          ),
        ),
      ),
      Positioned(
        top: screenHeight * 0.64,
        left: screenWidth *0.1,
        right: screenWidth *0.1,
        child: Text(product.description, style: textStyle.copyWith(fontSize: 16, color: Colors.white70)),
      ),
      //  _productInfo(screenHeight, screenWidth),
        SizedBox(
          height: 5,
        ),
        Positioned(
          bottom: 5,
          right: 10,
          left: 10,
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: screenWidth,
                height: expanded ? screenHeight * 0.6 : screenHeight * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Modifiers',
                                    style: textStyle.copyWith(color: Colors.black),
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.1,
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        expanded = !expanded;
                                      });
                                    },
                                    child: Icon(
                                      expanded ? Icons.expand_more : Icons.expand_less,
                                      size: 50,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    expanded
                        ? Flexible(
                      flex: 6,
                            child: FractionallySizedBox(
                              heightFactor: 1.1,
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            'Select quantity',
                                            style: textStyle.copyWith(color: Colors.black.withOpacity(0.8), fontSize: 16),
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              QuantityButton(
                                                icon: Icons.remove,
                                                statusOfQuatity: () {
                                                  setState(() {
                                                    if (cartItem.quantity > 1) {
                                                      cartItem.quantity--;
                                                    } else {
                                                      showAppDialog(context, 'Item Quantity to be at least 1!');
                                                    }
                                                  });
                                                },
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                '${cartItem.quantity}',
                                                style: textStyle.copyWith(color: Colors.black),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              QuantityButton(
                                                icon: Icons.add,
                                                statusOfQuatity: () {
                                                  setState(() {
                                                    cartItem.quantity++;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Flexible(
                                      child: _buildIngredients(screenWidth, screenHeight),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'select your ingredients for ${product.title}',
                              style: textStyle.copyWith(color: Colors.black54, fontSize: 18),
                            ),
                          ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      height: screenHeight * 0.069,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.blueAccent,
                        child: Text(
                          widget.savedCardId != null ? "UPDATE CART" : "ADD TO CART",
                          style: textStyle,
                        ),
                        onPressed: () {
                          setState(() {
                            cart.addItem(widget.savedCardId, cartItem);
                          });

                          showAppDialog(context, 'Item add to Your Cart');
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],

                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Positioned _productInfo(double screenHeight, double screenWidth) {
    return Positioned(
      top: screenHeight * 0.2,

      child: Column(
        children: <Widget>[
          SizedBox(
            height: screenHeight * .08,
          ),

          SizedBox(
            height: screenHeight * .03,
          ),

        ],
      ),
    );
  }
  Widget backArrow() {
    return Positioned(
      top: 30,
      left: 20,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 30,
            height: 30,
            child: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }

  Widget favouriteIcon() {
    return Positioned(
      top: 30,
      right: 20,
      child: IconButton(
        icon: Icon(
          _isFavourite ? Icons.favorite : Icons.favorite_border,
          size: 40,
        ),
        color: Colors.white70,
        onPressed: () async {
          if (this._isFavourite) {
            _removeItemFromFavourite(product.productID);
          } else {
            _addItemToFavourites(product.productID);
          }
        },
      ),
    );
  }

  Widget _buildIngredients(double screenWidth, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.all(5.0),

      child: Container(
        margin:  EdgeInsets.only(bottom:screenHeight * 0.015),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      child: Text(
                        'free modifiers',
                        style: textStyle.copyWith(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: GroupedCheckbox(
                        orientation: CheckboxOrientation.VERTICAL,
                        activeColor: Colors.green,
                        textStyle: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                        itemList: ingredientsNames.cast<String>(),
                        checkedItemList: cartItem.ingredients,
                        onChanged: (value) {
                          setState(() {
                            cartItem.ingredients = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      child: Text(
                        'Paid modifiers',
                        style: textStyle.copyWith(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: GroupedCheckbox(
                        orientation: CheckboxOrientation.VERTICAL,
                        activeColor: Colors.green,
                        itemList: extrasNames,
                        checkedItemList: cartItem.extras.map<String>((e) => e.name).toList(),
                        textStyle: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                        onChanged: (extras) {
                          setState(() {
                            cartItem.extras = List<Extra>.from(
                                extras.map((extraName) => product.extras.firstWhere((extra) => extra.name == extraName)).toList());
                            product.calcProductPrice(extras);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _removeItemFromFavourite(String productID) async {
    var provider = Provider.of<UserFavProductsProvider>(context, listen: false);
    await provider.removeItemToFavourites(productID, user.id, user.token);
    setState(() {});
  }

  void _addItemToFavourites(String productID) async {
    var provider = Provider.of<UserFavProductsProvider>(context, listen: false);
    await provider.addItemToFavourites(productID, user.id, user.token);
    setState(() {});
  }

  void loadProducts(DataProvider dataProvider) {
    dataProvider.fetchProducts().then((value) => {this.setState(() {})});
  }
}

class QuantityButton extends StatelessWidget {
  final IconData icon;
  final Function statusOfQuatity;

  QuantityButton({this.icon, this.statusOfQuatity});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 40.0,
        height: 40.0,
        child: RaisedButton(
          child: Icon(icon),
          onPressed: statusOfQuatity,
          splashColor: Colors.grey,
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        ));
  }
}
