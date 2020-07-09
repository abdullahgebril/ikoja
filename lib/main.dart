import 'package:deliveryfood/screens/delivery_main_screen.dart';
import 'package:deliveryfood/screens/delivery_order_details_screen.dart';
import 'package:deliveryfood/screens/driver_all_orders_screen.dart';
import 'package:deliveryfood/screens/user_all_orders_screen.dart';
import 'package:deliveryfood/screens/user_order_details_screen.dart';
import 'package:deliveryfood/screens/user_order_payment_screen.dart';
import 'package:deliveryfood/utilities/customer_api.dart';
import 'package:deliveryfood/utilities/presf_util.dart';
import 'package:deliveryfood/utilities/user_fav_products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/CartItem.dart';
import 'provider/categorys_products_data_provider.dart';
import 'screens/cart_screen.dart';
import 'screens/delivery_boy_login.dart';
import 'screens/delivery_orders_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_form.dart';
import 'screens/set_address_screen.dart';
import 'screens/sign_up.dart';
import 'screens/splash_screen.dart';
import 'widgets/drawer_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PrefsUtil.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DataProvider(),
        ),
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => UserFavProductsProvider()), 
        
        ChangeNotifierProvider(create: (_) => CustomerApi()),
      ],
      child: MaterialApp(
        title: 'Ikoja',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          canvasColor: Colors.black.withOpacity(0.8),

        ),
        routes: {
          'homeScreen': (context) => HomeScreen(),
          '/favoriteScreen': (context) => FavoriteScreen(),
          '/Appdrawer': (context) => AppDrawer(),
          '/cartScreen': (context) => CartScreen(),
          '/FavoriteScreen': (context) => FavoriteScreen(),
          'LogIn': (context) => LogIn(),
          'Sign UP': (context) => SingUp(),
          '/SplashScreen': (context) => SplashScreen(),
          'deliveryBoyLogin': (context)=> DeliveryBoyLogIn(),
          'dressOrderScrenn': (context) => OrderScreen(),
          'DeliveryMainScreen': (context) => DeliveryMainScreen(),
          'DriverAllOrdersScreen': (context) => DriverAllOrdersScreen(),
          'DeliveryOrdersScreen': (context) => DeliveryOrdersScreen(),
          'DeliveryOrderDetailsScreen': (context) => DeliveryOrderDetailsScreen(),
          'UserAllOrdersScreen': (context) => UserAllOrdersScreen(),
          'UserOrderDetailsScreen': (context) => UserOrderDetailsScreen(),
          'UserOrderPaymentScreen': (context) => UserOrderPaymentScreen(),
        },
        home: SplashScreen(),
      ),
    );
  }
}
