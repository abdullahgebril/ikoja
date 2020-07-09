import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:deliveryfood/utilities/user_fav_products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/favourite_item.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  void loadFavouriteProducts() async {
    if (_isInit && mounted) {
      setState(() {
        _isLoading = true;
      });
      try {
        Provider.of<UserFavProductsProvider>(context).loadFavProducts().then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      } catch (e) {
        throw e;
      }
      _isInit = false;
    }
  }

  @override
  void didChangeDependencies() {
    loadFavouriteProducts();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    UserFavProductsProvider provider = Provider.of<UserFavProductsProvider>(context);
    List favProducts = provider.favouritesProducts;
    final screenHeight = ScreenUtil.getScreenHeight(context);
    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/burgger.jpg'), fit: BoxFit.cover)),
      ),
          Positioned(
            left: screenHeight * 0.02,
            top: screenHeight * 0.05,
            child:  GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                )),
          ),

          Align(
            alignment: Alignment.topCenter,
            child:Padding(
              padding:  EdgeInsets.only(top: screenHeight * 0.05),
              child: Text(
                'Your Favourites',
                style: textStyle.copyWith(fontSize: 25, color: Colors.white),
              ),
            ),

          ),
      Positioned(
        bottom: 10,
        left: 10,
        right: 10,
        child: Container(
          height: screenHeight * 0.7,
          color: Colors.white,
          child: favProducts.length == 0
              ? Center(
                  child: Text(
                    'No Favouite',
                    style: textStyle.copyWith(color: Colors.blueGrey),
                  ),
                )
              : ListView.builder(itemCount: favProducts.length, itemBuilder: (context, i) => FavouriteItem(favProducts[i])),
        ),
      ),
    ]));
  }
}
