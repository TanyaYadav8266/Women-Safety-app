import 'package:flutter/material.dart';

Color primaryColor = Color.fromRGBO(255, 33, 117, 1);

void goTo(BuildContext context, Widget nextScreen) {
  Navigator.push( 
    context, MaterialPageRoute(
      builder:(context) => nextScreen,
      ));
}
 