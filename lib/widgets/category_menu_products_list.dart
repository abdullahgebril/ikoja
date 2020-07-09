import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:menu_button/menu_button.dart';
import 'package:provider/provider.dart';

import '../model/Category.dart';
import '../provider/categorys_products_data_provider.dart';
import '../shared/shared.dart';
import 'product_item.dart';

class DropdownButtonWidget extends StatefulWidget {
  @override
  _DropdownButtonWidgetState createState() => _DropdownButtonWidgetState();
}

class _DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  Category selectedCategory;
  List<Category> categories;

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void didChangeDependencies() async {
    super.didChangeDependencies();
    this.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    categories = Provider.of<DataProvider>(context).categories;
    if (selectedCategory == null && categories.length > 0) {
      selectedCategory = categories.first;

    }

    if (selectedCategory == null) {
      return Center(
          child: SpinKitCircle(
            color: Colors.white,
            size: 60.0,
          ));
    }

    // final products = Provider.of<DataProvider>(context).products;
    final selectedProduct = selectedCategory.products;

    final Widget menuButton = SizedBox(
      width: screenWidth - (screenHeight * 0.03),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 40,
                width: 40,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Image.network(
                      selectedCategory.image,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: screenHeight * 0.03,
              ),
              Text(
                selectedCategory.title,
                style: textStyle,
              ),
            ],
          ),
          FittedBox(
              fit: BoxFit.fill,
              child: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 30,
              )),
        ],
      ),
    );
    return _isLoading
        ? Center(
      child: CircularProgressIndicator(),
    )
        : Column(
      children: <Widget>[
        MenuButton<Category>(
          child: menuButton,
          // Widget displayed as the menuButton
          items: categories,
          popupHeight: 300,
         selectedItem: selectedCategory,
         dontShowTheSameItemSelected: true,
          scrollPhysics: AlwaysScrollableScrollPhysics(),
          // List of your items
          itemBuilder: (value) => Container(
            color: Colors.black87.withOpacity(0.6),
            child: SizedBox(
              width: screenWidth - (screenHeight * 0.03),
              height: 40,
              child: Row(
                children: <Widget>[
                  Container(
                    height: 40,
                    width: 40,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.network(
                          value.image,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.03,
                  ),
                  Text(
                    value.title,
                    style: textStyle,
                  ),
                ],
              ),
            ),
          ),
          // Widget displayed for each item
          toggledChild: Container(
            color: Colors.black87.withOpacity(0.6),
            child: SizedBox(
              width: screenWidth - (screenHeight * 0.03),
              height: 40,
              child: Row(
                children: <Widget>[
                  Container(
                    height: 40,
                    width: 40,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.network(
                          selectedCategory.image,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.03,
                  ),
                  //01093109685
                  Text(
                    selectedCategory.title,
                    style: TextStyle(color: Colors.transparent),
                  ),
                ],
              ),
            ),
          ),
          divider: Container(
            height: 0,
            color: Colors.grey,
          ),
          onMenuButtonToggle: (value) {},
          onItemSelected: (value) {
            setState(() {
              selectedCategory = value;
              // buildNavigator(context);
            });

            // Action when new item is selected
          },
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 0.5),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            color: blackColor,
          ),
        ),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        Expanded(
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : ListView.builder(
            itemCount: selectedProduct.length,
            itemBuilder: (context, i) => ProductItem(
              selectedProduct[i],
            ),
          ),
        )
      ],
    );
  }

  void loadData() {
    if (_isInit && mounted) {
      setState(() {
        _isLoading = true;
      });
      try {
        Provider.of<DataProvider>(context).fetchCategories().then((_) {
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
}
