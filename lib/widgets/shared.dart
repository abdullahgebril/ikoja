import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Container appBackground(double height) {
  return Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.black54
     // image: DecorationImage(

//        image: AssetImage('assets/images/burgger.jpg'),
//        fit: BoxFit.cover,
//        colorFilter: new ColorFilter.mode(
//            Colors.black.withOpacity(0.2), BlendMode.dstATop),// ),
    ),
  );
}
