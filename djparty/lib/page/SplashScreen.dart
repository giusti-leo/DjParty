import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/Login.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // init state
  @override
  void initState() {
    final sp = context.read<SignInProvider>();
    super.initState();
    // create a timer of 2 seconds
    Timer(const Duration(seconds: 2), () {
      sp.isSignedIn == false
          ? nextScreenReplace(context, const Login())
          : nextScreenReplace(context, const Home());
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double heigth = MediaQuery.of(context).size.height;
    return MaterialApp(
        title: '',
        home: AnimatedSplashScreen(
            splashIconSize: 400,
            duration: 1000,
            splash: Image.asset(
              'assets/images/logo.jpg',
              width: width,
              height: heigth,
              colorBlendMode: BlendMode.hardLight,
            ),
            nextScreen: splashScreen(),
            splashTransition: SplashTransition.fadeTransition,
            backgroundColor: Colors.black));
  }

  Widget splashScreen() {
    double width = MediaQuery.of(context).size.width;
    double heigth = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Image(
          image: AssetImage('assets/images/logo.jpg'),
          width: width,
          height: heigth,
        ),
      ),
    );
  }
}
