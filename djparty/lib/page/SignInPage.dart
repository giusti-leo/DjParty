import 'package:djparty/page/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:djparty/animations/ScaleRoute.dart';

import 'package:flutter/scheduler.dart';

import 'RegistrationPage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 50.0),
                    child: Center(
                      child: Container(
                          width: 200,
                          height: 150,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0)),
                          child:
                              Image.asset('assets/images/logo.jpg', scale: 4)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: _emailidController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          focusColor: Colors.greenAccent,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: Colors.greenAccent,
                          ),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 1.5),
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color: Colors.greenAccent, fontSize: 16),
                          iconColor: Colors.greenAccent,
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
                      style: const TextStyle(color: Colors.greenAccent),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.greenAccent,
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.greenAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              }),
                          filled: true,
                          fillColor: Colors.black12,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 1.5),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(
                              color: Colors.greenAccent,
                              width: 2,
                            ),
                          ),
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                              color: Colors.greenAccent, fontSize: 16),
                          hintText: ''),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 350,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_emailidController.text.contains('@')) {
                          displayToastMessage('Invalid Email-ID', context);
                          return;
                        } else if (_passwordController.text.length < 8) {
                          displayToastMessage(
                              'Password should be a minimum of 8 characters',
                              context);
                          return;
                        } else {
                          setState(() {
                            visible = load(visible);
                          });
                          login();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        surfaceTintColor: Colors.greenAccent,
                        foregroundColor: Colors.greenAccent,
                        shadowColor: Colors.greenAccent,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: const BorderSide(
                            color: Colors.greenAccent,
                            width: 5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        selectionColor: Colors.greenAccent,
                        style: TextStyle(fontSize: 20),
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
                    height: 30,
                    width: 300,
                    child: TextButton(
                      onPressed: () {
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const Register()));
                          //ResetPass()));
                        });
                      },
                      child: const Text(
                        'Forgot Password?',
                        selectionColor: Colors.white,
                        style:
                            TextStyle(fontSize: 14, color: Colors.greenAccent),
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
                  SizedBox(
                    height: 30,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const Register()));
                      },
                      child: const Text(
                        'New User? Create Account',
                        selectionColor: Colors.white,
                        style:
                            TextStyle(fontSize: 14, color: Colors.greenAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> login() async {
    final formState = _formKey.currentState;
    if (formState!.validate()) {
      formState.save();
      try {
        await auth.signInWithEmailAndPassword(
            email: _emailidController.text.trim(),
            password: _passwordController.text.trim());

        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => HomePage()));
          visible = !visible;
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          visible = load(visible);
        });
        displayToastMessage(e.code, context);
      }
    }
  }

  bool load(visible) {
    return visible = !visible;
  }

  @override
  void dispose() {
    _emailidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
