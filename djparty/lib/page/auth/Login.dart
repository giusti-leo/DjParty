import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:djparty/page/lobby/HomePage.dart';
import 'package:djparty/page/auth/ResetPassword.dart';
import 'package:djparty/page/auth/SignUp.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../utils/formFactor.dart';

DatabaseReference dbRef = FirebaseDatabase.instance.ref();
final FirebaseAuth auth = FirebaseAuth.instance;

bool isTablet = false;
bool isMobile = false;

final RoundedLoadingButtonController googleController =
    RoundedLoadingButtonController();

final RoundedLoadingButtonController facebookController =
    RoundedLoadingButtonController();
final RoundedLoadingButtonController registrationController =
    RoundedLoadingButtonController();

StreamBuilder redirectHomeOrLogin() {
  // Fast track for already authenticated users

  final ZoomDrawerController drawerController = ZoomDrawerController();

  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      ScreenType screenType = getFormFactor(context);
      if (screenType == ScreenType.Handset) {
        portraitModeOnly();
        isMobile = true;
      }
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

class Login extends StatefulWidget {
  static String routeName = 'init';
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool visible = false;
  bool err = false;
  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);

  static bool _passwordVisible = false;
  static bool gvisible = false;

  final TextEditingController _emailidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController signinController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    visible = false;
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();

  TextStyle styleHeading1 = const TextStyle(
      fontSize: 50.0, fontWeight: FontWeight.bold, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backGround,
        body: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: isMobile ? MediaQuery.of(context).size.width : 600,
            height: isMobile ? MediaQuery.of(context).size.height : 1000,
            child: Form(
              key: _formKey,
              child: _buildLoginForm(context),
            ),
          ),
        ));
  }

  Widget heading1(String text, double x, double y) {
    return Positioned(
      top: y,
      left: x,
      child: Text(text, selectionColor: Colors.white, style: styleHeading1),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: ListView(
        children: [
          const SizedBox(height: 40.0),
          SizedBox(
            height: 175.0,
            width: 200.0,
            child: isMobile
                ? Stack(
                    children: [
                      heading1('Dj Party', 0.0, 75.0),
                    ],
                  )
                : const Stack(
                    children: [
                      Positioned(
                        bottom: 10,
                        child: Text('Dj Party',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20.0),
          emailField(),
          const SizedBox(height: 5.0),
          passwordField(),
          const SizedBox(height: 10.0),
          submit(),
          const SizedBox(height: 10.0),
          Center(
            child: TextButton(
              onPressed: () {
                nextScreen(context, const ResetPassword());
              },
              child: Text(
                'Forgot Password?',
                selectionColor: mainGreen,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: mainGreen),
              ),
            ),
          ),
          Container(
            alignment: const Alignment(1.0, 0.0),
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          _buildLoginFacebookButton(context),
          const SizedBox(height: 10.0),
          _buildLoginGoogleButton(context),
          const SizedBox(height: 10.0),
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  handleToSignIn();
                },
                child: Text(
                  ' Sign up ',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: mainGreen),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget emailField() {
    return TextFormField(
      controller: _emailidController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      toolbarOptions: const ToolbarOptions(
          copy: true, paste: true, selectAll: true, cut: true),
      cursorColor: mainGreen,
      decoration: InputDecoration(
          focusColor: mainGreen,
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: mainGreen,
          ),
          //filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          labelText: 'Email',
          labelStyle: TextStyle(color: mainGreen, fontSize: 16),
          iconColor: mainGreen,
          hintText: ''),
    );
  }

  Widget submit() {
    return RoundedLoadingButton(
      onPressed: () {
        login(context, _emailidController.text, _passwordController.text);
      },
      controller: signinController,
      successColor: mainGreen,
      width: MediaQuery.of(context).size.width * 0.80,
      elevation: 0,
      borderRadius: 25,
      color: mainGreen,
      child: const Wrap(
        children: [
          Icon(
            FontAwesomeIcons.music,
            size: 20,
            color: Colors.white,
          ),
          SizedBox(
            width: 15,
          ),
          Text("Sign in",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      keyboardType: TextInputType.visiblePassword,
      style: const TextStyle(color: Colors.white),
      toolbarOptions: const ToolbarOptions(
          copy: true, paste: true, selectAll: true, cut: true),
      cursorColor: const Color.fromRGBO(30, 215, 96, 0.9),
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: mainGreen,
          ),
          suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: mainGreen,
              ),
              onPressed: () async {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
                await Future.delayed(const Duration(seconds: 5));
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              }),
          //filled: true,
          fillColor: backGround,
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: mainGreen, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(
              color: mainGreen,
              width: 1,
            ),
          ),
          labelText: 'Password',
          labelStyle: const TextStyle(
              color: Color.fromRGBO(30, 215, 96, 0.9), fontSize: 16),
          hintText: ''),
    );
  }

  Widget _buildLoginGoogleButton(BuildContext context) {
    return RoundedLoadingButton(
      onPressed: () {
        handleGoogleSignIn();
      },
      controller: googleController,
      successColor: Colors.red,
      width: MediaQuery.of(context).size.width * 0.80,
      elevation: 0,
      borderRadius: 25,
      color: Colors.red,
      child: const Wrap(
        children: [
          Icon(
            FontAwesomeIcons.google,
            size: 20,
            color: Colors.white,
          ),
          SizedBox(
            width: 15,
          ),
          Text("Sign in with Google",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLoginFacebookButton(BuildContext context) {
    return RoundedLoadingButton(
      onPressed: () {
        handleFacebookAuth();
      },
      controller: facebookController,
      successColor: Colors.blue,
      width: MediaQuery.of(context).size.width * 0.80,
      elevation: 0,
      borderRadius: 25,
      color: Colors.blue,
      child: const Wrap(
        children: [
          Icon(
            FontAwesomeIcons.facebook,
            size: 20,
            color: Colors.white,
          ),
          SizedBox(
            width: 15,
          ),
          Text("Sign in with Facebook",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  handleToSignIn() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreenReplace(context, const SignIn());
    });
  }

  // handling facebookauth
  // handling google sigin in
  Future handleFacebookAuth() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      facebookController.reset();
      return;
    }
    await sp.signInWithFacebook().then((value) {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        facebookController.reset();
        return;
      } else if (sp.errorCode == 'Stop') {
        facebookController.reset();

        return;
      }

      User loggedUser = FirebaseAuth.instance.currentUser!;
      // checking whether user exists or not
      sp.checkUserExists(loggedUser.uid).then((value) async {
        if (sp.hasError == true) {
          showInSnackBar(context, sp.errorCode.toString(), Colors.red);
          facebookController.reset();
          return;
        }
        if (value == true) {
          // user exists
          await sp
              .getUserDataFromFirestore((loggedUser.uid))
              .then((value) => sp.saveDataToSharedPreferences().then((value) {
                    sp.setSignIn().then((value) {
                      if (sp.hasError == true) {
                        showInSnackBar(
                            context, sp.errorCode.toString(), Colors.red);
                        facebookController.reset();
                        return;
                      }
                      facebookController.success();
                      handleAfterSignIn();
                    });
                  }));
        } else {
          // user does not exist
          sp.saveDataToFirestore().then((value) => sp
              .saveDataToSharedPreferences()
              .then((value) => sp.setSignIn().then((value) {
                    facebookController.success();
                    handleAfterSignIn();
                  })));
        }
      });
    });
  }

  Future login(
    BuildContext context,
    String email,
    String password,
  ) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      displayToastMessage(
          context, "Check your internet connection", Colors.red);
      signinController.reset();
      return;
    }

    if (!validity(email, password)) {
      signinController.reset();
      return;
    }

    sp.signInWithEmailPassword(email: email, password: password).then((value) {
      if (sp.hasError == true) {
        displayToastMessage(context, sp.errorCode.toString(), Colors.red);
        sp.sendEmailVerification(context);
        signinController.reset();
        return;
      } else {
        sp.getUserDataFromFirestore(sp.uid!).then((value) => sp
            .saveDataToSharedPreferences()
            .then((value) => sp.setSignIn().then((value) {
                  signinController.success();
                  handleAfterSignIn();
                })));
      }
    });
  }

  bool validity(String email, String password) {
    if (!_emailidController.text.contains('@')) {
      displayToastMessage(context, 'Invalid Email-ID', Colors.red);

      return false;
    } else if (_passwordController.text.length < 8) {
      displayToastMessage(
          context, 'Password should be a minimum of 8 characters', Colors.red);

      return false;
    }
    return true;
  }

  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showInSnackBar(context, "Check your Internet connection", Colors.red);
      googleController.reset();
      return;
    }

    await sp.signInWithGoogle().then((value) {
      if (sp.hasError == true) {
        showInSnackBar(context, sp.errorCode.toString(), Colors.red);
        googleController.reset();
        return;
      } else if (sp.errorCode == 'Stop') {
        googleController.reset();
        return;
      } else {
        User loggedUser = FirebaseAuth.instance.currentUser!;

        // checking whether user exists or not
        sp.checkUserExists(loggedUser.uid).then((value) async {
          if (value == true) {
            // user exists
            await sp.getUserDataFromFirestore(loggedUser.uid).then((value) => sp
                .saveDataToSharedPreferences()
                .then((value) => sp.setSignIn().then((value) {
                      googleController.success();
                      handleAfterSignIn();
                    })));
          } else {
            // user does not exist
            sp.saveDataToFirestore().then((value) async {
              await sp.getUserDataFromFirestore(loggedUser.uid).then((value) =>
                  sp
                      .saveDataToSharedPreferences()
                      .then((value) => sp.setSignIn().then((value) {
                            googleController.success();
                            handleAfterSignIn();
                          })));
            });
          }
        });
      }
    });
  }

  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(
          context,
          HomePage(
            loggedUser: FirebaseAuth.instance.currentUser!,
            db: FirebaseFirestore.instance,
          ));
    });
  }
}
