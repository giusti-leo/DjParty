import 'package:djparty/page/Home.dart';
import 'package:djparty/page/HomePage.dart';
import 'package:djparty/page/Login.dart';
import 'package:djparty/page/ResetPassword.dart';
import 'package:djparty/services/FirebaseAuthMethods.dart';
import 'package:djparty/services/InternetProvider.dart';
import 'package:djparty/services/SignInProvider.dart';
import 'package:djparty/utils/nextScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:djparty/animations/ScaleRoute.dart';

import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SignIn extends StatefulWidget {
  static String routeName = '/login-email-password';
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  static bool _passwordVisible = false;
  static bool visible = false;
  static bool gvisible = false;

  Color mainGreen = const Color.fromARGB(228, 53, 191, 101);
  Color backGround = const Color.fromARGB(255, 35, 34, 34);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController signinController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    visible = false;
    gvisible = false;
  }

  handleStepBack() {
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      nextScreenReplace(context, const Login());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backGround,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(128, 53, 74, 62),
          title: const Text('Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white)),
          centerTitle: true,
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
            onTap: () {
              handleStepBack();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 10.0, bottom: 30.0),
                  child: TextFormField(
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
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: mainGreen,
                            ),
                            onPressed: () async {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                              await Future.delayed(const Duration(seconds: 3));
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            }),
                        //filled: true,
                        fillColor: backGround,
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: mainGreen, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                            color: mainGreen,
                            width: 1,
                          ),
                        ),
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                            color: Color.fromRGBO(30, 215, 96, 0.9),
                            fontSize: 16),
                        hintText: ''),
                  ),
                ),
                RoundedLoadingButton(
                  onPressed: () {
                    login(context, _emailidController.text,
                        _passwordController.text);
                  },
                  controller: signinController,
                  successColor: mainGreen,
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: mainGreen,
                  child: Wrap(
                    children: const [
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
                ),
                Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: visible,
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Container(
                            color: Colors.greenAccent,
                            width: 320,
                            margin: const EdgeInsets.only(),
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              backgroundColor: backGround,
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            )))),
                SizedBox(
                  height: 70,
                  width: 300,
                  child: TextButton(
                    onPressed: () {
                      nextScreen(context, const ResetPassword());
                    },
                    child: Text(
                      'Forgot Password?',
                      selectionColor: mainGreen,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: gvisible,
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Container(
                            width: 320,
                            margin: const EdgeInsets.only(),
                            child: const LinearProgressIndicator(
                              minHeight: 2,
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const HomePage());
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

  @override
  void dispose() {
    _emailidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
