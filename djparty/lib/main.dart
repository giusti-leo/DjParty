// ignore_for_file: avoid_print

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:djparty/page/SignInPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:djparty/page/HomePage.dart';

String initialroute = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp firebaseApp = await Firebase.initializeApp();
  await isUserLoggedIn();
  runApp(const Main());
}

Future<void> isUserLoggedIn() async {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
      initialroute = 'login';
    } else {
      print('User is signed in!');
      print('User: ');
      print(user);
      print('\n');
      initialroute = 'homepage';
      print(initialroute);
    }
  });
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _Splashscreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _Splashscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'swd',
        home: AnimatedSplashScreen(
            duration: 3000,
            splash: Image.asset('assets/images/logo.jpg'),
            nextScreen: const SecondScreen(),
            splashTransition: SplashTransition.fadeTransition,
            backgroundColor: Colors.black));
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const SignInPage(),
        initialRoute: initialroute,
        routes: {
          'homepage': (context) => HomePage(),
          'login': (context) => const SignInPage(),
        });
  }
}
