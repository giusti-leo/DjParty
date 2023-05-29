import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:djparty/page/EditProfile.dart';
import 'package:djparty/page/GenerateShare.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/HomePage.dart';
import 'package:djparty/page/Login.dart';
import 'package:djparty/page/ResetPassword.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:djparty/page/SplashScreen.dart';
import 'package:djparty/page/UserProfile.dart';
import 'package:djparty/page/spotifyPlayer.dart';
import 'package:djparty/services/FirebaseAuthMethods.dart';
import 'package:djparty/services/FirebaseRequests.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/page/SearchItemScreen.dart';
import 'package:djparty/services/SpotifyRequests.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:djparty/page/PlaylistPage.dart';
import 'package:djparty/page/PartyPlaylist.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: ((context) => SignInProvider()),
          ),
          ChangeNotifierProvider(
            create: ((context) => InternetProvider()),
          ),
          ChangeNotifierProvider(
            create: ((context) => FirebaseRequests()),
          ),
          ChangeNotifierProvider(
            create: ((context) => SpotifyRequests()),
          ),
        ],
        child: MaterialApp(
          home: const SplashScreen(),
          debugShowCheckedModeBanner: true,
          routes: {
            SignIn.routeName: (context) => const Login(),
            HomePage.routeName: (context) => const HomePage(),
          },
        ),
      ),
    );
  }
}
