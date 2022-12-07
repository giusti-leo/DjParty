import 'package:flutter/material.dart';
import 'package:djparty/page/HomePage.dart';

void main() => {
  WidgetsFlutterBinding.ensureInitialized(),
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Roboto', hintColor: Color.fromARGB(255, 8, 127, 16)),
      home: HomePage(),
    ))
    };

