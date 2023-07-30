import 'dart:async';

//import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/HomePage.dart';
import 'package:djparty/page/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // init state
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      redirectHomeOrLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

/*  @override
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
            nextScreen: Container(),
            splashTransition: SplashTransition.fadeTransition,
            backgroundColor: Colors.black));
  }*/
}

StreamBuilder redirectHomeOrLogin() {
  // Fast track for already authenticated users

  final ZoomDrawerController drawerController = ZoomDrawerController();

  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.active) {
        return const Center(child: CircularProgressIndicator());
      }

      final hasUser = snapshot.hasData;
      if (hasUser && FirebaseAuth.instance.currentUser!.emailVerified) {
        return HomePage(
          loggedUser: FirebaseAuth.instance.currentUser!,
          db: FirebaseFirestore.instance,
        );
      } else {
        return const Login();
      }
    },
  );
}
