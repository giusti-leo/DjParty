import 'package:djparty/page/Home.dart';
import 'package:djparty/page/Login.dart';
import 'package:djparty/page/ResetPassword.dart';
import 'package:djparty/services/FirebaseAuthMethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:djparty/animations/ScaleRoute.dart';

import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    visible = false;
    gvisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        home: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.black12,
          appBar: AppBar(
            backgroundColor: Colors.black,
            shadowColor: Color.fromRGBO(30, 215, 96, 0.9),
            title: const Text('Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color.fromRGBO(30, 215, 96, 0.9))),
            centerTitle: true,
            leading: GestureDetector(
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color.fromRGBO(30, 215, 96, 0.9),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Login()));
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
                      decoration: const InputDecoration(
                          focusColor: Color.fromRGBO(30, 215, 96, 0.9),
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: Color.fromRGBO(30, 215, 96, 0.9),
                          ),
                          //filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(30, 215, 96, 0.9),
                                width: 3),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(30, 215, 96, 0.9),
                                width: 3),
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color: Color.fromRGBO(30, 215, 96, 0.9),
                              fontSize: 16),
                          iconColor: Color.fromRGBO(30, 215, 96, 0.9),
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
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color.fromRGBO(30, 215, 96, 0.9),
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color.fromRGBO(30, 215, 96, 0.9),
                              ),
                              onPressed: () async {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                                await Future.delayed(
                                    const Duration(seconds: 3));
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              }),
                          //filled: true,
                          fillColor: Colors.black12,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(30, 215, 96, 0.9),
                                width: 3),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(30, 215, 96, 0.9),
                              width: 2,
                            ),
                          ),
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                              color: Color.fromRGBO(30, 215, 96, 0.9),
                              fontSize: 16),
                          hintText: ''),
                    ),
                  ),
                  SizedBox(
                    height: 70,
                    width: 350,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_emailidController.text.contains('@')) {
                          displayToastMessage('Invalid Email-ID', context);
                        } else if (_passwordController.text.length < 8) {
                          displayToastMessage(
                              'Password should be a minimum of 8 characters',
                              context);
                        } else {
                          context.read<FirebaseAuthMethods>().loginWithEmail(
                                email: _emailidController.text,
                                password: _passwordController.text,
                                context: context,
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(30, 215, 96, 0.9),
                        surfaceTintColor: Color.fromRGBO(30, 215, 96, 0.9),
                        foregroundColor: Color.fromRGBO(30, 215, 96, 0.9),
                        shadowColor: Color.fromRGBO(30, 215, 96, 0.9),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: const BorderSide(
                            color: Color.fromARGB(184, 255, 255, 255),
                            width: 5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        selectionColor: Colors.white,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
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
                              child: const LinearProgressIndicator(
                                minHeight: 2,
                                backgroundColor: Colors.black12,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              )))),
                  SizedBox(
                    height: 50,
                    width: 300,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, ResetPassword.routeName);
                      },
                      child: const Text(
                        'Forgot Password?',
                        selectionColor: Colors.white,
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromRGBO(30, 215, 96, 0.9)),
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
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              )))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  displayToastMessage(String msg, BuildContext context) {
    Fluttertoast.showToast(msg: msg);
  }

  void showInSnackBar(String value, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
