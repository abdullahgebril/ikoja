import 'dart:async';
import 'dart:convert';

import 'package:deliveryfood/enums/PaymentMethod.dart';
import 'package:deliveryfood/model/CartItem.dart';
import 'package:deliveryfood/model/CustomerOrder.dart';
import 'package:deliveryfood/shared/shared.dart';
import 'package:deliveryfood/utilities/cart_pref.dart';
import 'package:deliveryfood/utilities/customer_api.dart';
import 'package:deliveryfood/utilities/screen_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../model/User.dart';
import '../utilities/user_prefs.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();

  String name;
  String phone;
  String email = "";
  String coupon;
  String notes;
  User user;

  final _phoneController = TextEditingController();
  final _couponController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  /// Variables to manage location
  GoogleMapController _mapController;
  Location _locationService = Location();
  StreamSubscription<LocationData> _locationSubscription;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  LatLng _selectedLocation;
  String error;

  CustomerApi dbHelper = CustomerApi();
  CustomerOrder customer;

  /// Variable to detect the payment method
  PaymentMethod _paymentMethod = PaymentMethod.NONE;

  void getUser() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = json.decode(UserPrefs.getUserAsString());

    /**
     * Shady
     * setState to detect the changes for variable as user data.
     */
    setState(() {
      user = User.fromJson(value);
      _nameController.text = user.name;
      _phoneController.text = user.phone;
    });
  }

  Future _makeOrder(CustomerOrder customerOrder) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
                onWillPop: () => Future.value(false),
                child: Dialog(child: Container(height: 100, child: Center(child: CircularProgressIndicator()))));
          });

      await dbHelper.addOrder(customerOrder).then((completeOrder) async {
        Navigator.pop(context);

        CartPref.clearCarItems();

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                  onWillPop: () => Future.value(false),
                  child: AlertDialog(
                    title: Text("Order Placed"),
                    content: Text("Your order successfully placed. Follow your order progress."),
                    actions: [
                      FlatButton(
                        child: Text("Follow Progress"),
                        onPressed: () {
                          //print(completeOrder.id);
                          Navigator.pop(context);
                          Navigator.of(context).pushNamedAndRemoveUntil('homeScreen', (Route<dynamic> route) => false);
                          Navigator.of(context).pushNamed('UserOrderDetailsScreen', arguments: completeOrder);
                        },
                      )
                    ],
                  ));
            });
      });
    } catch (error) {
      Navigator.pop(context);

      var message = "Error happened. Please try again.";

      if (error.toString().contains("user already used coupon"))
        message = "Sorry, this coupon has been used before. You can't use it twise.";
      else if (error.toString().contains("coupon doesn't exist"))
        message = "Sorry, this coupon doesn't exist.";
      else if (error.toString().contains("coupon is outdated")) message = "Sorry, this coupon expired.";

      showErrorDialog(context, message);
    }
  }

  void initState() {
    super.initState();
    getUser();
  }

  void dispose() {
    super.dispose();
    _phoneController.dispose();
    _couponController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    _locationSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);

    return Scaffold(
      /// This line for keep content above keyboard.
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/burgger.jpg'),
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
            )),
          ),
          Positioned(
              top: screenHeight * 0.05,
              left: screenWidth * 0.03,
              child: Container(
                  height: screenHeight * 0.95,
                  width: screenWidth * 0.95,
                  child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          )),
                      SizedBox(width: 5),
                      Text(
                        'Set Delivery Address',
                        style: textStyle,
                      )
                    ]),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Container(
                      height: screenHeight * 0.87,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                  child: Column(
                                children: [
                                  TextFormField(
                                    style: textStyle.copyWith(color: Colors.black),
                                    cursorColor: Color(0xFF9b9b9b),
                                    keyboardType: TextInputType.text,
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                        fillColor: Colors.grey,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderSide: new BorderSide(
                                            color: Colors.blueAccent,
                                            width: 1.0,
                                          ),
                                        ),
                                        hintText: 'Please enter your name',
                                        hintStyle: textStyle.copyWith(color: Colors.white70)),
                                    validator: (nameValue) {
                                      if (nameValue.isEmpty || nameValue.trim().length < 3 || !nameValue.trim().contains(" ")) {
                                        return 'Please enter your full name: Ahmed Mohamed';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 200,
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(target: LatLng(26.740335, 31.5785317), zoom: 5),
                                      onMapCreated: _onMapCreated,
                                      myLocationEnabled: true,
                                      zoomGesturesEnabled: true,
                                      scrollGesturesEnabled: true,
                                      onCameraMoveStarted: () {
                                        _locationSubscription?.cancel();
                                        _getUserLocation();
                                      },
                                      onTap: (latLng) {
                                        _locationSubscription?.cancel();
                                        _getUserLocation();
                                      },
                                      onCameraIdle: () async {
                                        final coordinates = Coordinates(_selectedLocation.latitude, _selectedLocation.longitude);
                                        var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
                                        var first = addresses.first;
                                        var address = "${first.featureName} : ${first.addressLine}";
                                        //print(address);
                                        setState(() => _addressController.text = address);
                                      },
                                      onCameraMove: (position) async {
                                        if (mounted) setState(() => _selectedLocation = position.target);
                                      },
                                      // Add little blue dot for device location, requires permission from user
                                      mapType: MapType.normal,
                                      markers: Set<Marker>.of(
                                        <Marker>[
                                          Marker(
                                            markerId: MarkerId("SelectedPlace"),
                                            position: (_selectedLocation != null)
                                                ? _selectedLocation
                                                : LatLng(
                                                    0,
                                                    0,
                                                  ),
                                            infoWindow: const InfoWindow(title: 'Selected Place'),
                                          )
                                        ],
                                      ),
                                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                                        Factory<OneSequenceGestureRecognizer>(
                                          () => EagerGestureRecognizer(),
                                        ),
                                      ].toSet(),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    style: textStyle.copyWith(color: Colors.black),
                                    cursorColor: Color(0xFF9b9b9b),
                                    controller: _addressController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        fillColor: Colors.grey,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderSide: new BorderSide(
                                            color: Colors.blueAccent,
                                            width: 1.0,
                                          ),
                                        ),
                                        hintText: "Please enter your address",
                                        hintStyle: textStyle.copyWith(color: Colors.white70)),
                                    validator: (value) {
                                      if (value.isEmpty || value.length < 3) {
                                        return 'Please enter your address';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    style: textStyle.copyWith(color: Colors.black),
                                    cursorColor: Color(0xFF9b9b9b),
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        fillColor: Colors.grey,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderSide: new BorderSide(
                                            color: Colors.blueAccent,
                                            width: 1.0,
                                          ),
                                        ),
                                        hintText: "Please set your email.",
                                        hintStyle: textStyle.copyWith(color: Colors.white70)),
                                    validator: (emailValue) {
                                      Pattern pattern =
                                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                      RegExp regex = RegExp(pattern);

                                      if ((_paymentMethod != null && _paymentMethod == PaymentMethod.VISA) &&
                                          (emailValue.isEmpty || !regex.hasMatch(emailValue))) {
                                        return 'Please enter your email correctly: test@test.com';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    style: textStyle.copyWith(color: Colors.black),
                                    cursorColor: Color(0xFF9b9b9b),
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 11,
                                    decoration: InputDecoration(
                                        fillColor: Colors.grey,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderSide: new BorderSide(
                                            color: Colors.blueAccent,
                                            width: 1.0,
                                          ),
                                        ),
                                        hintText: "Please enter your phone",
                                        hintStyle: textStyle.copyWith(color: Colors.white70)),
                                    validator: (phoneValue) {
                                      if (phoneValue.isEmpty || phoneValue.length != 11) {
                                        return 'Please enter your phone correctly';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    style: textStyle.copyWith(color: Colors.black),
                                    cursorColor: Color(0xFF9b9b9b),
                                    controller: _couponController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        fillColor: Colors.orangeAccent,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderSide: new BorderSide(
                                            color: Colors.blueAccent,
                                            width: 1.0,
                                          ),
                                        ),
                                        hintText: "COUPON",
                                        hintStyle: textStyle.copyWith(color: Colors.white70)),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    style: textStyle.copyWith(color: Colors.black),
                                    cursorColor: Color(0xFF9b9b9b),
                                    keyboardType: TextInputType.multiline,
                                    controller: _noteController,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                        fillColor: Colors.grey,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderSide: new BorderSide(
                                            color: Colors.blueAccent,
                                            width: 1.0,
                                          ),
                                        ),
                                        hintText: "Please set your notes",
                                        hintStyle: textStyle.copyWith(color: Colors.white70)),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(flex: 1, child: Text("Payment Method", style: TextStyle(fontSize: 18))),
                                      Row(children: <Widget>[
                                        Radio(
                                          value: PaymentMethod.CASH,
                                          groupValue: _paymentMethod,
                                          onChanged: (value) => setState(() => _paymentMethod = value),
                                        ),
                                        Text("Cash", style: TextStyle(fontSize: 14))
                                      ]),
                                      Row(children: <Widget>[
                                        Radio(
                                          value: PaymentMethod.VISA,
                                          groupValue: _paymentMethod,
                                          onChanged: (value) => setState(() => _paymentMethod = value),
                                        ),
                                        Text("Visa", style: TextStyle(fontSize: 14))
                                      ])
                                    ],
                                  )
                                ],
                              )),
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: RaisedButton(
                                color: Colors.blue,
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                                onPressed: () async {
                                  var isValid = _formKey.currentState.validate();

                                  if (!isValid || _paymentMethod == PaymentMethod.NONE) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Error"),
                                            content:
                                                Text(!isValid ? "Please check the error." : "Please choose the payment method."),
                                            actions: [
                                              FlatButton(
                                                child: Text("OK"),
                                                onPressed: () => Navigator.pop(context),
                                              )
                                            ],
                                          );
                                        });
                                    return;
                                  }

                                  String customerName = _nameController.text.trim();
                                  String customerPhone = _phoneController.text.trim();
                                  String orderAddress = _addressController.text.trim();
                                  LatLng latLng = _selectedLocation;
                                  String customerEmail = _emailController.text.trim();
                                  PaymentMethod paymentMethod = _paymentMethod;
                                  List<CartItem> products = CartPref.getCartItems();
                                  String coupon = _couponController.text.trim();

                                  CustomerOrder customerOrder = CustomerOrder(
                                      user: user,
                                      customerName: customerName,
                                      customerPhone: customerPhone,
                                      orderAddress: orderAddress,
                                      orderLatLng: latLng,
                                      customerEmail: customerEmail,
                                      orderPaymentMethod: paymentMethod,
                                      productList: products,
                                      couponCode: coupon);

                                  _makeOrder(customerOrder);
                                },
                                child: Center(
                                    child: FittedBox(
                                  child: Text(
                                    'Place Order',
                                    style: textStyle.copyWith(color: Colors.white),
                                  ),
                                )),
                              ))
                        ],
                      ),
                    ),
                  ]))),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
    _getUserLocation();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _getUserLocation() async {
    await _locationService.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);

    LocationData location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      //print("Service status: $serviceStatus");
      if (serviceStatus) {
        _permissionStatus = await _locationService.hasPermission();
        //print("Permission: $_permissionStatus");
        if (_permissionStatus == PermissionStatus.granted) {
          location = await _locationService.getLocation();

          _locationSubscription = _locationService.onLocationChanged.listen((LocationData locationData) {
            if (_mapController == null) return;

            if (_selectedLocation == null) {
              if (mounted) setState(() => _selectedLocation = LatLng(location.latitude, location.longitude));
              _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(locationData.latitude, locationData.longitude),
                zoom: 18.0,
              )));
            }
          });
        } else {
          _permissionStatus = await _locationService.requestPermission();
          //print("Permission after request: $_permissionStatus");
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        //print("Service status activated after request: $serviceStatusResult");
        if (serviceStatusResult) {
          _getUserLocation();
        }
      }
    } on PlatformException catch (e) {
      //print(e);
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      location = null;
    } catch (e) {
      //print(e);
    }
  }
}
