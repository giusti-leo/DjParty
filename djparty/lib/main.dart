import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/auth/Login.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/services/SpotifyRequests.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';

String initialroute = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Main());
}

class Main extends StatelessWidget {
  static String routeName = 'main';

  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: ((context) => SignInProvider()),
          ),
          ChangeNotifierProvider(
            create: ((context) => InternetProvider()),
          ),
          ChangeNotifierProvider(
            create: ((context) => FirebaseRequests(
                  db: FirebaseFirestore.instance,
                )),
          ),
          ChangeNotifierProvider(
            create: ((context) => SpotifyRequests()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: redirectHomeOrLogin(),
        ),
      ),
    );
  }
}
