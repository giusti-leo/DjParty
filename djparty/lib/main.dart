import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:djparty/page/GenerateShare.dart';
import 'package:djparty/page/Home.dart';
import 'package:djparty/page/Login.dart';
import 'package:djparty/page/ResetPassword.dart';
import 'package:djparty/page/SignIn.dart';
import 'package:djparty/page/SignUp.dart';
import 'package:djparty/services/FirebaseAuthMethods.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:djparty/page/HomePage.dart';
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
        title: '',
        home: AnimatedSplashScreen(
            splashIconSize: 400,
            duration: 1000,
            splash: Image.asset(
              'assets/images/logo.jpg',
              width: 10000,
              height: 10000,
              colorBlendMode: BlendMode.hardLight,
            ),
            nextScreen: connection(context),
            splashTransition: SplashTransition.fadeTransition,
            backgroundColor: Colors.black));
  }

  Widget connection(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthMethods>(
          create: (_) => FirebaseAuthMethods(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<FirebaseAuthMethods>().authState,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Dj Party',
        home: const AuthWrapper(),
        routes: {
          SignUp.routeName: (context) => const SignUp(),
          SignIn.routeName: (context) => const SignIn(),
          Home.routeName: (context) => const Home(),
          GeneratorScreen.routeName: (context) => GeneratorScreen(),
          ResetPassword.routeName: ((context) => const ResetPassword())
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const Home();
    }
    return const Login();
  }
}
