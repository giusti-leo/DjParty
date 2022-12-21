import 'package:djparty/page/Home.dart';
import 'package:djparty/page/SignInPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: '/', routes: {
      'homepage': (context) => HomePage(),
      'login': (context) => const SignInPage(),
    });
  }

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'App name',
        home: Builder(builder: (BuildContext context) {
          return Scaffold(
              body: FutureBuilder(
                  future: _initializeFirebase(),
                  builder: (context, shapshot) {
                    if (shapshot.connectionState == ConnectionState.done) {
                      return const Home();
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }));
        }));
  }
}
