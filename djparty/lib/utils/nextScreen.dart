import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

displayToastMessage(BuildContext context, String msg, Color color) {
  Fluttertoast.showToast(msg: msg, textColor: color);
}

void showInSnackBar(BuildContext context, String value, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
    value,
    style: TextStyle(color: color),
  )));
}
